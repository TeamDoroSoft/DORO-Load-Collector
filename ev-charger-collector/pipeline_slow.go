// pipeline_slow.go는 --mode=slow(기본값) 파이프라인이다. 기존(파일 분할 이전) main()의
// 본문을 그대로 옮긴 것으로, 동작은 100% 동일하게 유지한다: fetch→validate→normalize→
// RDS upsert(신규 station/charger 삽입 포함, 이력 append)→커밋된 station만 Redis 갱신.
// --recover-date 지정 시에는 API 수집(collectAll) 대신 S3에서 원본을 되읽어
// (RecoverRawPages) 이후 파이프라인(validate→normalize→적재)을 그대로 재사용하는 수동
// 복구 모드로 동작한다.
package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"ev-charger-collector/internal/db"
	"ev-charger-collector/internal/keypool"
	"ev-charger-collector/internal/model"
	"ev-charger-collector/internal/normalize"
	"ev-charger-collector/internal/storage"
	"ev-charger-collector/internal/validate"
)

// slowDefaultTimeout은 정기 slow 실행의 기본 마감시간이다. cron 주기(1~6시간, 배포 시
// 결정)보다 짧게 잡아 다음 실행과 겹치지 않게 하고, systemd SIGTERM 없이도 폭주 실행을
// 스스로 끊는다. --timeout 플래그로 배포 시 조정 가능하다(0이면 이 기본값 사용).
const slowDefaultTimeout = 9*time.Minute + 30*time.Second

// recoverTimeout은 수동 S3 복구 모드(--recover-date)의 마감시간이다. 하루치 백로그를
// S3에서 되읽어 재적재하는 작업은 정기 실행용 기본값으로는 부족할 수 있어 훨씬 길게
// 둔다. 복구는 정기 실행과 겹칠 일이 없으므로 이 완화가 안전하며, SIGTERM/SIGINT로는
// 여전히 즉시 취소된다.
const recoverTimeout = 30 * time.Minute

// slowConfig는 runSlow에 필요한 입력을 모은다.
type slowConfig struct {
	Pool         *keypool.Pool
	Zcode        string
	NumOfRows    int
	OutputDir    string
	RecoverDate  string
	RecoverZcode string
	Timeout      time.Duration
}

// runSlow는 slow path(진실의 원천, 느긋한 주기) 파이프라인을 실행한다.
func runSlow(cfg slowConfig) {
	// 1) cron/systemd timer 겹침 방지 flock.
	lockPath := lockPathForMode("slow")
	release, ok := acquireLock(lockPath)
	if !ok {
		log.Printf("이전 실행이 진행 중이라 이번 실행을 스킵한다(flock=%s)", lockPath)
		os.Exit(0)
	}
	defer release()

	// 2) env 검증(서비스키 풀은 main()에서 이미 구성돼 넘어옴).
	dbCfg, missing := dbConfigFromEnv()
	if len(missing) > 0 {
		log.Fatalf("필수 DB 환경변수 누락: %v", missing)
	}

	// SIGTERM/SIGINT(systemd stop 등)와 전체 마감시간을 함께 건 ctx를 만든다.
	// 취소 시 진행 중이던 station 트랜잭션은 BeginTx(ctx) 경계에서 자동 롤백되고
	// (이미 커밋된 station은 안전), collectAll 루프도 즉시 중단된다.
	baseCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()
	ctx, cancel := context.WithTimeout(baseCtx, cfg.Timeout)
	defer cancel()

	// 3) 클라이언트 초기화.
	database, err := db.Open(dbCfg)
	if err != nil {
		log.Fatalf("DB 연결 실패: %v", err)
	}
	defer database.Close()
	if err := database.Ping(ctx); err != nil {
		log.Fatalf("DB Ping 실패: %v", err)
	}

	stor := newStorage(ctx, cfg.OutputDir)
	cacheClient := newCache()
	if cacheClient != nil {
		defer cacheClient.Close()
	}

	// 4) 시드 ID 조회(없으면 마이그레이션 누락으로 중단).
	sourceID, err := database.GetKevInfoSourceID(ctx)
	if err != nil {
		log.Fatalf("시드 조회 실패(KEV_INFO data_source): %v", err)
	}
	// 이 network_id는 station의 busiId가 없어 실제 operator를 해석할 수 없을 때만
	// 쓰는 미분류(UNVERIFIED) fallback이다. busiId가 있으면 UpsertStation이
	// station별로 실제 operator 기반 network_id를 해석해 사용한다.
	fallbackNetworkID, err := database.GetUnverifiedNetworkID(ctx)
	if err != nil {
		log.Fatalf("시드 조회 실패(미분류 charging_network fallback): %v", err)
	}

	collectedAt := time.Now().UTC()
	var stats model.PipelineStats

	// 5) 수집(정상: API 페이지네이션 / 복구: S3 원본 재적재).
	var pages []storage.RawPage
	if cfg.RecoverDate != "" {
		// 복구 모드: API를 호출하지 않고 S3에 보존된 원본을 되읽는다. S3_BUCKET 필수.
		bucket := os.Getenv("S3_BUCKET")
		if bucket == "" {
			log.Fatal("복구 모드에는 환경변수 S3_BUCKET이 필수입니다.")
		}
		downloader, derr := storage.NewS3Downloader(ctx)
		if derr != nil {
			log.Fatalf("S3 다운로더 초기화 실패: %v", derr)
		}
		pages, err = stor.RecoverRawPages(ctx, downloader, bucket, cfg.RecoverZcode, cfg.RecoverDate)
		if err != nil {
			log.Fatalf("S3 복구 실패: %v", err)
		}
		stats.Status = model.StatusRecovered
		log.Printf("S3 복구 모드: date=%s zcode=%q, %d페이지 복원", cfg.RecoverDate, cfg.RecoverZcode, len(pages))
	} else {
		// 정상 수집. collectAll은 에러 발생 시에도 그때까지 모은 페이지를 함께 반환한다.
		// 페이지별 원본 저장은 collectAll 내부에서 이미 끝난다. 일일 호출 한도 초과 등으로
		// 중간에 끊겨도 이미 받은 수만 건을 통째로 버리지 않고 파이프라인에 태워 부분 적재한다.
		pages, err = collectAll(ctx, cfg.Pool, cfg.Zcode, cfg.NumOfRows, cfg.OutputDir, "slow", stor)
		stats.Status = classifyCollectStatus(err)
		if err != nil {
			// 빈 응답(쿼터 소진)으로 0페이지가 된 경우는 치명적 종료가 아니라 상태 신호를 남기고
			// 나머지 단계(last_run 갱신·요약 로그)까지 도달해야 한다. 그 외 원인으로 한 페이지도
			// 없으면 기존처럼 중단한다.
			if len(pages) == 0 && stats.Status != model.StatusEmptyResponse {
				log.Fatalf("수집 실패: %v", err)
			}
			log.Printf("[warn] 부분 수집으로 종료됨(status=%s, 원인: %v), %d페이지 처리함(완전 수집 아님)", stats.Status, err, len(pages))
		}
	}
	var allItems []model.RawItem
	for _, p := range pages {
		allItems = append(allItems, p.Items...)
	}
	stats.CollectedItems = len(allItems)

	// 6) 집계 JSON 저장(디버그용, 비치명적). 원본 보존은 정상 수집 시 collectAll 내부에서
	// 페이지별로 이미 끝났고, 복구 모드에서는 S3 재저장이 중복 데이터를 만들므로 하지 않는다.
	// 따라서 복구 모드(RecoverDate != "")에서는 uploadToS3=false로 넘겨 로컬 저장만 한다.
	if err := stor.PersistItemsJSON(ctx, pages, cfg.RecoverDate == ""); err != nil {
		log.Printf("[warn] 집계 JSON 저장 실패(비치명적): %v", err)
	}

	// 7) 검증.
	valid, invalid := validate.Validate(allItems, collectedAt)
	stats.ValidItems = len(valid)
	stats.InvalidItems = len(invalid)
	if err := stor.PersistErrorItems(ctx, invalid); err != nil {
		log.Printf("[warn] 오류 item 저장 실패(비치명적): %v", err)
	}

	// 8) 정규화.
	stations := normalize.Normalize(valid, collectedAt)
	stats.NormalizedStns = len(stations)

	// 9) station별 적재 + 성공 시 즉시 캐시 갱신.
	// 루프 진입 전 operator_code→network_id 매핑을 한 번에 프리로드해, station마다
	// operator/charging_network를 DB에서 왕복 조회(N+1)하던 비용을 제거한다. 프리로드가
	// 실패해도 치명적이지 않다 — netCache가 nil이면 기존처럼 station별로 DB 조회한다.
	netCache, err := database.PreloadOperatorNetworkMap(ctx)
	if err != nil {
		log.Printf("[warn] operator→network 매핑 프리로드 실패(비치명적, station별 조회로 진행): %v", err)
		netCache = nil
	} else {
		log.Printf("operator→network 매핑 프리로드 완료: %d건", len(netCache))
	}

	// budgetExceeded는 전체 마감시간(cfg.Timeout) 초과/취소로 루프를 중도 종료했는지
	// 나타낸다. 이 경우 이미 처리된 station 결과는 유지한 채 부분 완료로 마무리한다.
	budgetExceeded := false
	for _, st := range stations {
		res, err := database.UpsertStation(ctx, sourceID, fallbackNetworkID, netCache, st)
		if err != nil {
			stats.FailedStns++
			log.Printf("[warn] station 적재 실패(source_station_id=%s): %v", st.SourceStationID, err)
			// 공유 파이프라인 ctx가 만료/취소됐으면(전체 마감시간 초과 또는 SIGTERM),
			// 이는 "예산 초과"이지 DB 장애가 아니다. 남은 station을 스킵하고 루프를
			// 우아하게 빠져나가 나머지 단계(last_run 갱신)까지 정상 진행한다.
			if ctx.Err() != nil {
				budgetExceeded = true
				log.Printf("[warn] 파이프라인 예산 초과/취소 감지 — 남은 station 스킵하고 부분 완료로 종료: %v", ctx.Err())
				break
			}
			// 예산 문제가 아니면 실제 연결 장애인지 판정한다. 이때 만료됐을 수 있는
			// 공유 ctx를 재사용하면 Ping이 무조건 deadline exceeded를 반환해 오진하므로,
			// 그 시점에 새로 만든 짧은 fresh context로 헬스체크한다.
			pingCtx, pingCancel := context.WithTimeout(context.Background(), 5*time.Second)
			pingErr := database.Ping(pingCtx)
			pingCancel()
			if pingErr != nil {
				log.Fatalf("DB 연결 장애로 전체 중단: %v", pingErr)
			}
			continue
		}
		stats.UpsertedStns++
		refreshStationCache(ctx, cacheClient, res, st, &stats)
	}

	// station 적재 중 예산 초과로 중도 종료했다면 이를 최종 상태로 확정한다("가장 나중에
	// 확정된 사유"를 우선). 수집 단계에서 매긴 상태를 덮어써 부분 완료임을 명확히 신호한다.
	if budgetExceeded {
		stats.Status = model.StatusBudgetExceeded
	}

	// 10) 마지막 실행 기록.
	// 예산 초과로 공유 ctx가 이미 만료됐을 수 있으므로, last_run 갱신은 그 시점에
	// 새로 만든 짧은 fresh context로 수행한다 — 부분 완료 결과라도 "마지막 수집 시간"이
	// 정상 기록되게 한다(만료된 ctx면 갱신 자체가 deadline exceeded로 실패한다).
	finishedAt := time.Now().UTC()
	if cacheClient != nil {
		lastRunCtx, lastRunCancel := context.WithTimeout(context.Background(), 5*time.Second)
		if err := cacheClient.RefreshLastRun(lastRunCtx, finishedAt, stats, "slow"); err != nil {
			log.Printf("[warn] collector:last_run 갱신 실패(비치명적): %v", err)
		}
		lastRunCancel()
	}

	// 11) 구조화 요약 로그(CloudWatch Logs Insights 집계용).
	// budgetExceeded면 전량 처리가 아니라 부분 완료임을 명시한다(종료 코드는 정상).
	if budgetExceeded {
		log.Printf("[warn] 부분 완료: 전체 마감시간(timeout) 초과로 남은 station을 스킵했다(처리분은 정상 커밋/캐시 유지).")
	}
	// 새 status 필드는 기존 필드 순서를 그대로 둔 채 맨 뒤에만 추가한다(CloudWatch Logs
	// Insights 기존 쿼리 호환 유지). status로 이번 실행이 완주(complete)인지 부분/중단인지 구분.
	log.Printf("pipeline_summary mode=slow collected=%d valid=%d invalid=%d normalized_stations=%d upserted=%d failed=%d cache_refreshed=%d cache_failed=%d finished_at=%s status=%s",
		stats.CollectedItems, stats.ValidItems, stats.InvalidItems, stats.NormalizedStns,
		stats.UpsertedStns, stats.FailedStns, stats.CacheRefreshed, stats.CacheFailedStns,
		finishedAt.Format(time.RFC3339), stats.Status)
}
