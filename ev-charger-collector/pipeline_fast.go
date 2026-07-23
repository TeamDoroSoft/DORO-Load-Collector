// pipeline_fast.go는 --mode=fast 파이프라인이다. RDS에는 전혀 쓰지 않고(읽기 전용
// 프리로드만) Redis 캐시만 자주 갱신하는 것이 유일한 목적이다. RDS에 없는 신규
// station/charger는 완전히 무시하고 다음 slow path까지 기다린다(화면 반영이 최대
// slow path 주기만큼 늦어지는 걸 감수하는 설계 결정 §1).
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
	"ev-charger-collector/internal/validate"
)

// fastDefaultTimeout은 fast 실행의 기본 마감시간이다(수 분~수십 분 주기로 자주 돌리는
// 것을 전제). --timeout 플래그로 배포 시 조정 가능하다(0이면 이 기본값 사용).
const fastDefaultTimeout = 4 * time.Minute

// fastConfig는 runFast에 필요한 입력을 모은다.
type fastConfig struct {
	Pool      *keypool.Pool
	Zcode     string
	NumOfRows int
	OutputDir string
	Timeout   time.Duration
}

// runFast는 fast path(캐시 전용, 잦은 주기) 파이프라인을 실행한다.
func runFast(cfg fastConfig) {
	// 1) fast 전용 flock(slow/archive와 별도 — 서로 막지 않고 동시 실행 가능).
	lockPath := lockPathForMode("fast")
	release, ok := acquireLock(lockPath)
	if !ok {
		log.Printf("이전 fast 실행이 진행 중이라 이번 실행을 스킵한다(flock=%s)", lockPath)
		os.Exit(0)
	}
	defer release()

	// 2) fast path의 유일한 목적은 Redis 캐시 갱신이므로, REDIS_HOST가 없으면 DB 연결이나
	// API 호출(쿼터 소모) 없이 가장 먼저 스킵한다.
	cacheClient := newCache()
	if cacheClient == nil {
		log.Printf("[warn] REDIS_HOST 미설정 — fast path는 캐시 갱신이 유일한 목적이므로 이번 실행을 건너뛴다.")
		return
	}
	defer cacheClient.Close()

	// 3) env 검증(서비스키 풀은 main()에서 이미 구성돼 넘어옴).
	dbCfg, missing := dbConfigFromEnv()
	if len(missing) > 0 {
		log.Fatalf("필수 DB 환경변수 누락: %v", missing)
	}

	baseCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()
	ctx, cancel := context.WithTimeout(baseCtx, cfg.Timeout)
	defer cancel()

	// 4) DB는 읽기 전용(PreloadStationChargerMap)으로만 쓴다 — UpsertStation 등 쓰기는
	// 절대 호출하지 않는다.
	database, err := db.Open(dbCfg)
	if err != nil {
		log.Fatalf("DB 연결 실패: %v", err)
	}
	defer database.Close()
	if err := database.Ping(ctx); err != nil {
		log.Fatalf("DB Ping 실패: %v", err)
	}

	stor := newStorage(ctx, cfg.OutputDir)

	sourceID, err := database.GetKevInfoSourceID(ctx)
	if err != nil {
		log.Fatalf("시드 조회 실패(KEV_INFO data_source): %v", err)
	}

	collectedAt := time.Now().UTC()
	var stats model.PipelineStats

	// 5) 수집. slow와 동일하게 페이지별 원본을 보존한다(CLAUDE.md "원본 보존" 필수
	// 규칙은 fast/slow 공통이다) — mode="fast"로 체크포인트를 분리해 slow와 서로
	// 덮어쓰지 않는다.
	pages, err := collectAll(ctx, cfg.Pool, cfg.Zcode, cfg.NumOfRows, cfg.OutputDir, "fast", stor)
	stats.Status = classifyCollectStatus(err)
	if err != nil {
		if len(pages) == 0 && stats.Status != model.StatusEmptyResponse {
			log.Fatalf("수집 실패: %v", err)
		}
		log.Printf("[warn] 부분 수집으로 종료됨(status=%s, 원인: %v), %d페이지 처리함(완전 수집 아님)", stats.Status, err, len(pages))
	}

	var allItems []model.RawItem
	for _, p := range pages {
		allItems = append(allItems, p.Items...)
	}
	stats.CollectedItems = len(allItems)

	if err := stor.PersistItemsJSON(ctx, pages, true); err != nil {
		log.Printf("[warn] 집계 JSON 저장 실패(비치명적): %v", err)
	}

	// 6) 검증·정규화(slow와 동일 헬퍼 재사용).
	valid, invalid := validate.Validate(allItems, collectedAt)
	stats.ValidItems = len(valid)
	stats.InvalidItems = len(invalid)
	if err := stor.PersistErrorItems(ctx, invalid); err != nil {
		log.Printf("[warn] 오류 item 저장 실패(비치명적): %v", err)
	}

	stations := normalize.Normalize(valid, collectedAt)
	stats.NormalizedStns = len(stations)

	// 7) station/charger 매핑 프리로드. 실패 시 프로세스를 죽이지 않고(exit 0) 이번
	// 실행만 건너뛴다(수 분 뒤 다음 주기에 자연 복구). 로그에 grep 가능한 고유 문자열
	// (fast_path_preload_failed)을 남겨 CloudWatch Logs 메트릭 필터+알람으로 감지한다.
	scMap, err := database.PreloadStationChargerMap(ctx, sourceID)
	if err != nil {
		log.Printf("[warn] fast_path_preload_failed: %v", err)
		return
	}
	log.Printf("station/charger 매핑 프리로드 완료: station=%d charger=%d", scMap.StationCount(), scMap.ChargerCount())

	// 8) station별 캐시 갱신. RDS에 없는(프리로드 매핑에 없는) 신규 station/charger는
	// 완전히 무시한다 — slow path가 다음에 그 station을 upsert할 때까지 기다린다.
	budgetExceeded := false
	for _, st := range stations {
		if err := ctx.Err(); err != nil {
			budgetExceeded = true
			log.Printf("[warn] 파이프라인 예산 초과/취소 감지 — 남은 station 스킵하고 부분 완료로 종료: %v", err)
			break
		}

		stationID, ok := scMap.StationID(st.SourceStationID)
		if !ok {
			// RDS에 아직 없는 신규 station — 이번 fast 주기에서는 완전히 무시한다.
			stats.SkippedNewStations++
			continue
		}

		var matched []db.UpsertedCharger
		for _, ch := range st.Chargers {
			chargerID, ok := scMap.ChargerID(stationID, ch.ExternalChargerID)
			if !ok {
				// 기존 station 하위의 신규 charger — 이 charger만 스킵(station 자체는 계속 처리).
				stats.SkippedNewChargers++
				continue
			}
			matched = append(matched, db.UpsertedCharger{ChargerID: chargerID, Norm: ch})
		}

		// UpsertedStns를 fast path에서는 "캐시 갱신을 시도한(=RDS에 이미 존재가 확인된)
		// station 수"로 재해석해 재사용한다(slow의 "성공적으로 upsert한 station 수"와
		// 다른 의미이지만, "이번 실행에서 정상 처리된 station 수"라는 공통 성격은 같다).
		res := db.UpsertResult{StationID: stationID, Chargers: matched}
		refreshStationCache(ctx, cacheClient, res, st, &stats)
		stats.UpsertedStns++
	}
	if budgetExceeded {
		stats.Status = model.StatusBudgetExceeded
	}

	// 9) 마지막 실행 기록. mode="fast"이므로 공용 collector:last_run과
	// collector:last_run:fast 둘 다 갱신된다(cache.RefreshLastRun 참고).
	finishedAt := time.Now().UTC()
	lastRunCtx, lastRunCancel := context.WithTimeout(context.Background(), 5*time.Second)
	if err := cacheClient.RefreshLastRun(lastRunCtx, finishedAt, stats, "fast"); err != nil {
		log.Printf("[warn] collector:last_run 갱신 실패(비치명적): %v", err)
	}
	lastRunCancel()

	if budgetExceeded {
		log.Printf("[warn] 부분 완료: 전체 마감시간(timeout) 초과로 남은 station을 스킵했다(처리분은 정상 캐시 유지).")
	}
	log.Printf("pipeline_summary mode=fast collected=%d valid=%d invalid=%d normalized_stations=%d matched=%d skipped_new_stations=%d skipped_new_chargers=%d cache_refreshed=%d cache_failed=%d finished_at=%s status=%s",
		stats.CollectedItems, stats.ValidItems, stats.InvalidItems, stats.NormalizedStns,
		stats.UpsertedStns, stats.SkippedNewStations, stats.SkippedNewChargers,
		stats.CacheRefreshed, stats.CacheFailedStns, finishedAt.Format(time.RFC3339), stats.Status)
}
