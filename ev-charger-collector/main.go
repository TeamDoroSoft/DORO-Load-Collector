// Command ev-charger-collector는 한국환경공단 EvCharger(getChargerInfo) API를
// 페이지네이션 전량 수집한 뒤, 원본 보존(로컬/S3) → 검증 → 정규화 → RDS 적재 →
// Redis 캐시 갱신까지 한 프로세스에서 순차 처리하는 배치 도구다(Kafka 미사용).
//
// 오케스트레이션 순서(deployment-v2 §2):
//
//	flock 획득 → env 검증 → 클라이언트 초기화 → 시드 ID 조회 → collectAll →
//	PersistRawPages → validate → PersistErrorItems → normalize →
//	station별 UpsertStation + 성공 시 즉시 cache refresh → RefreshLastRun → 요약 로그
package main

import (
	"bytes"
	"context"
	"encoding/xml"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"ev-charger-collector/internal/cache"
	"ev-charger-collector/internal/db"
	"ev-charger-collector/internal/model"
	"ev-charger-collector/internal/normalize"
	"ev-charger-collector/internal/storage"
	"ev-charger-collector/internal/validate"
)

// apiEndpoint는 환경부 getChargerInfo 엔드포인트다. 유닛 테스트에서 httptest
// 서버 URL로 교체할 수 있도록 const가 아닌 var로 둔다(런타임에는 변경하지 않는다).
var apiEndpoint = "http://apis.data.go.kr/B552584/EvCharger/getChargerInfo"

const (
	// requestTimeout은 전국 9000건+ 규모의 대용량 페이지 응답을 고려해 30초로 둔다
	// (기존 15초는 대형 페이지에서 여유가 부족). ctx 취소(SIGTERM/전체 마감시간)와
	// 별개로 개별 HTTP 요청 자체의 상한선 역할을 한다.
	requestTimeout = 30 * time.Second
	maxRetries     = 5
	baseBackoff    = 1 * time.Second
)

// overallTimeout은 실행 전체의 마감시간이다. cron 주기(15분)보다 짧게 잡아
// 다음 실행과 겹치지 않게 하고, systemd SIGTERM 없이도 폭주 실행을 스스로 끊는다.
const overallTimeout = 9*time.Minute + 30*time.Second

var httpClient = &http.Client{Timeout: requestTimeout}

const interPageDelay = 300 * time.Millisecond

// lockPath는 cron 겹침 방지용 flock 파일 경로다(배포 환경 고정).
const lockPath = "/var/run/ev-charger-collector.lock"

// authFailure는 서비스키 오류 등 재시도해도 해결되지 않는 실패를 나타낸다.
type authFailure struct{ msg string }

func (e *authFailure) Error() string { return e.msg }

// rawResponse는 doRequest 한 번의 결과다. raw에는 원본 XML 바이트가 그대로
// 보존되고(preserve_raw 유지), resp는 스트리밍 디코딩 결과, decErr는 디코딩 오류다.
type rawResponse struct {
	raw    []byte
	status int
	resp   *model.Response
	decErr error
}

// doRequest는 ctx가 걸린 HTTP 요청을 보내고, io.TeeReader로 응답 본문을 흘려보내며
// xml.Decoder로 스트리밍 디코딩하는 동시에 원본 바이트를 buffer에 그대로 보존한다.
// 디코딩이 응답 전체를 읽지 않고 끝나더라도(예: 서비스에러 봉투로 루트 불일치),
// 남은 바이트를 io.Discard로 마저 흘려 buffer(원본)가 항상 완전하게 채워지도록 한다.
func doRequest(ctx context.Context, serviceKey, zcode string, pageNo, numOfRows int) (*rawResponse, error) {
	q := url.Values{}
	// serviceKey는 디코딩된 원본 값을 그대로 넘긴다. url.Values.Encode()가
	// 한 번만 퍼센트 인코딩하므로, 이미 인코딩된 키를 넣으면 이중 인코딩되어
	// 인증에 실패한다(data.go.kr 흔한 실수).
	q.Set("serviceKey", serviceKey)
	q.Set("pageNo", strconv.Itoa(pageNo))
	q.Set("numOfRows", strconv.Itoa(numOfRows))
	q.Set("type", "xml")
	// zcode(시도코드)가 지정된 경우에만 지역 필터 파라미터를 추가한다.
	// 빈 문자열이면 파라미터를 아예 넣지 않아 기존 전국 수집 동작을 그대로 보존한다.
	if zcode != "" {
		q.Set("zcode", zcode)
	}

	reqURL := apiEndpoint + "?" + q.Encode()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, reqURL, nil)
	if err != nil {
		return nil, err
	}

	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// TeeReader: 디코더가 읽는 만큼 buf에 원본 바이트가 그대로 복사된다.
	var buf bytes.Buffer
	tee := io.TeeReader(resp.Body, &buf)

	var parsed model.Response
	decErr := xml.NewDecoder(tee).Decode(&parsed)
	// 원본 보존과 서비스에러 판별을 위해 남은 바이트를 끝까지 흘려 buf를 완성한다.
	if _, drainErr := io.Copy(io.Discard, tee); drainErr != nil {
		return nil, drainErr
	}

	return &rawResponse{
		raw:    buf.Bytes(),
		status: resp.StatusCode,
		resp:   &parsed,
		decErr: decErr,
	}, nil
}

// fetchPage는 pageNo 한 페이지를 재시도 정책과 함께 호출해 원본 XML 바이트와
// 파싱된 Response를 반환한다. 인증/서비스 레벨 오류는 재시도 없이 즉시 실패시키고,
// 트래픽 제한·네트워크·5xx류 일시 오류는 지수 백오프로 재시도한다. ctx가 취소되면
// 재시도하지 않고 즉시 중단한다.
func fetchPage(ctx context.Context, serviceKey, zcode string, pageNo, numOfRows int) ([]byte, *model.Response, error) {
	var lastErr error
	for attempt := 0; attempt < maxRetries; attempt++ {
		// ctx 취소(SIGTERM/전체 마감)면 재시도 없이 즉시 중단.
		if err := ctx.Err(); err != nil {
			return nil, nil, err
		}
		if attempt > 0 {
			backoff := baseBackoff * time.Duration(1<<uint(attempt-1))
			log.Printf("재시도 대기 %s (page=%d, attempt=%d/%d, 원인=%v)", backoff, pageNo, attempt+1, maxRetries, lastErr)
			if err := sleepCtx(ctx, backoff); err != nil {
				return nil, nil, err
			}
		}

		rr, err := doRequest(ctx, serviceKey, zcode, pageNo, numOfRows)
		if err != nil {
			// ctx 취소로 인한 요청 실패면 재시도하지 않는다.
			if ctx.Err() != nil {
				return nil, nil, ctx.Err()
			}
			lastErr = err
			continue
		}
		if rr.status >= 500 {
			lastErr = fmt.Errorf("HTTP %d", rr.status)
			continue
		}

		// 서비스 레벨 오류 봉투(OpenAPI_ServiceResponse)인지 보존된 원본 바이트로 확인한다.
		// 정상/도메인 응답과 XML 루트 구조 자체가 다르므로 별도 파싱을 시도한다.
		var svcErr model.ServiceErrorResponse
		if xml.Unmarshal(rr.raw, &svcErr) == nil && svcErr.CmmMsgHeader.ErrMsg != "" {
			return nil, nil, &authFailure{msg: fmt.Sprintf("서비스 레벨 오류: %s (%s)", svcErr.CmmMsgHeader.ErrMsg, svcErr.CmmMsgHeader.ReturnReasonCode)}
		}

		if rr.decErr != nil {
			lastErr = fmt.Errorf("XML 파싱 실패: %w", rr.decErr)
			continue
		}

		switch rr.resp.Header.ResultCode {
		case "00", "0":
			return rr.raw, rr.resp, nil
		case "22", "LIMITED_NUMBER_OF_SERVICE_REQUESTS_EXCEEDS_ERROR":
			// 트래픽 제한류 - 재시도 대상
			lastErr = fmt.Errorf("트래픽 제한 응답: %s", rr.resp.Header.ResultMsg)
			continue
		default:
			// SERVICE_KEY_IS_NOT_REGISTERED_ERROR 등 인증/요청 오류류는 재시도 불필요
			return nil, nil, &authFailure{msg: fmt.Sprintf("resultCode=%s resultMsg=%s", rr.resp.Header.ResultCode, rr.resp.Header.ResultMsg)}
		}
	}
	return nil, nil, fmt.Errorf("최대 재시도(%d회) 초과: %w", maxRetries, lastErr)
}

// sleepCtx는 d만큼 대기하되 ctx가 취소되면 즉시 반환한다(취소 전파용).
func sleepCtx(ctx context.Context, d time.Duration) error {
	t := time.NewTimer(d)
	defer t.Stop()
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-t.C:
		return nil
	}
}

// collectAll은 pageNo=1부터 빈 페이지가 올 때까지 반복 호출해
// 데이터를 수집한다. zcode가 비어 있으면 전국 전체를, 시도코드가 지정되면
// 해당 시도 범위만 수집한다. 페이지별 원본 XML을 그대로 보존할 수 있도록
// 페이지 단위 결과를 모두 반환한다. ctx가 취소되면 루프를 즉시 중단한다.
func collectAll(ctx context.Context, serviceKey, zcode string, numOfRows int) ([]storage.RawPage, error) {
	var pages []storage.RawPage
	collected := 0
	pageNo := 1

	for {
		if err := ctx.Err(); err != nil {
			return pages, err
		}
		if pageNo > 1 {
			if err := sleepCtx(ctx, interPageDelay); err != nil {
				return pages, err
			}
		}

		rawXML, resp, err := fetchPage(ctx, serviceKey, zcode, pageNo, numOfRows)
		if err != nil {
			return pages, err
		}

		items := resp.Body.Items.Item
		collected += len(items)
		log.Printf("page=%d 수집=%d건 (누적 %d/%d)", pageNo, len(items), collected, resp.Body.TotalCount)

		pages = append(pages, storage.RawPage{PageNo: pageNo, RawXML: rawXML, Items: items})

		// totalCount가 0 이하로 오는 소스(예: zcode=11)가 있어 신뢰할 수 없으므로,
		// 양수일 때만 조기 종료 판단에 쓰고 그 외엔 빈 페이지로만 종료한다.
		if (resp.Body.TotalCount > 0 && collected >= resp.Body.TotalCount) || len(items) == 0 {
			break
		}
		pageNo++
	}

	log.Printf("전체 수집 완료: 총 %d건, %d페이지", collected, len(pages))
	return pages, nil
}

// acquireLock은 path에 배타적 non-blocking flock을 건다.
// 이미 다른 프로세스가 잡고 있으면 ok=false를 반환한다(겹침 스킵 신호).
// 반환된 release를 호출하면 락 파일을 닫아 커널이 락을 해제한다. 프로세스가
// 비정상 종료해도 커널이 자동 해제하므로 stale lock 문제가 없다.
func acquireLock(path string) (release func(), ok bool) {
	f, err := os.OpenFile(path, os.O_CREATE|os.O_RDWR, 0o644)
	if err != nil {
		log.Printf("락 파일 열기 실패(%s): %v", path, err)
		return func() {}, false
	}
	if err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX|syscall.LOCK_NB); err != nil {
		// EWOULDBLOCK 등: 이미 다른 실행이 락을 보유 중.
		_ = f.Close()
		return func() {}, false
	}
	return func() {
		_ = syscall.Flock(int(f.Fd()), syscall.LOCK_UN)
		_ = f.Close()
	}, true
}

// dbConfigFromEnv는 필수 DB 환경변수를 읽는다. 누락 항목이 있으면 그 목록을 반환한다.
func dbConfigFromEnv() (db.Config, []string) {
	cfg := db.Config{
		Host:     os.Getenv("DB_HOST"),
		Port:     os.Getenv("DB_PORT"),
		User:     os.Getenv("DB_USER"),
		Password: os.Getenv("DB_PASSWORD"),
		Name:     os.Getenv("DB_NAME"),
	}
	var missing []string
	if cfg.Host == "" {
		missing = append(missing, "DB_HOST")
	}
	if cfg.Port == "" {
		missing = append(missing, "DB_PORT")
	}
	if cfg.User == "" {
		missing = append(missing, "DB_USER")
	}
	if cfg.Name == "" {
		missing = append(missing, "DB_NAME")
	}
	// DB_PASSWORD는 빈 값도 허용(로컬 dev 등)하므로 필수 목록에 넣지 않는다.
	return cfg, missing
}

func main() {
	numOfRows := flag.Int("num-of-rows", 100, "페이지당 조회 건수")
	outputDir := flag.String("output-dir", "./output", "결과 저장 디렉터리")
	flag.Parse()

	// 1) cron 겹침 방지 flock.
	release, ok := acquireLock(lockPath)
	if !ok {
		log.Printf("이전 실행이 진행 중이라 이번 실행을 스킵한다(flock=%s)", lockPath)
		os.Exit(0)
	}
	defer release()

	// 2) env 검증.
	serviceKey := os.Getenv("EVCHARGER_SERVICE_KEY")
	if serviceKey == "" {
		log.Fatal("환경변수 EVCHARGER_SERVICE_KEY가 설정되지 않았습니다.")
	}
	// EVCHARGER_ZCODE는 선택적 시도(zcode) 필터다. 미설정 시 빈 문자열이 되어
	// 기존과 동일하게 전국 전체를 수집한다(예: "11"이면 서울시 전체만 수집).
	zcode := os.Getenv("EVCHARGER_ZCODE")
	dbCfg, missing := dbConfigFromEnv()
	if len(missing) > 0 {
		log.Fatalf("필수 DB 환경변수 누락: %v", missing)
	}

	// SIGTERM/SIGINT(systemd stop 등)와 전체 마감시간을 함께 건 ctx를 만든다.
	// 취소 시 진행 중이던 station 트랜잭션은 BeginTx(ctx) 경계에서 자동 롤백되고
	// (이미 커밋된 station은 안전), collectAll 루프도 즉시 중단된다.
	baseCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()
	ctx, cancel := context.WithTimeout(baseCtx, overallTimeout)
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

	stor := newStorage(ctx, *outputDir)
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

	// 5) 수집.
	// collectAll은 에러 발생 시에도 그때까지 모은 페이지를 함께 반환한다.
	// 일일 호출 한도 초과 등으로 중간에 끊겨도 이미 받은 수만 건을 통째로
	// 버리지 않고 파이프라인에 태워 부분 적재한다(개별 station 실패를 스킵하며
	// 계속 진행하는 이 프로세스의 부분 성공 철학과 일치). 한 페이지도 없을 때만 중단.
	pages, err := collectAll(ctx, serviceKey, zcode, *numOfRows)
	if err != nil {
		if len(pages) == 0 {
			log.Fatalf("수집 실패: %v", err)
		}
		log.Printf("[warn] 부분 수집으로 종료됨(원인: %v), %d페이지만 처리함(완전 수집 아님)", err, len(pages))
	}
	var allItems []model.RawItem
	for _, p := range pages {
		allItems = append(allItems, p.Items...)
	}
	stats.CollectedItems = len(allItems)

	// 6) 원본 보존(실패 시 전체 중단).
	if err := stor.PersistRawPages(ctx, pages); err != nil {
		log.Fatalf("원본 보존 실패: %v", err)
	}
	if err := stor.PersistItemsJSON(pages); err != nil {
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
	for _, st := range stations {
		res, err := database.UpsertStation(ctx, sourceID, fallbackNetworkID, st)
		if err != nil {
			stats.FailedStns++
			log.Printf("[warn] station 적재 실패(source_station_id=%s): %v", st.SourceStationID, err)
			// 연결 자체 장애면 전체 중단, 아니면 스킵하고 계속.
			if pingErr := database.Ping(ctx); pingErr != nil {
				log.Fatalf("DB 연결 장애로 전체 중단: %v", pingErr)
			}
			continue
		}
		stats.UpsertedStns++
		refreshStationCache(ctx, cacheClient, res, st, &stats)
	}

	// 10) 마지막 실행 기록.
	finishedAt := time.Now().UTC()
	if cacheClient != nil {
		if err := cacheClient.RefreshLastRun(ctx, finishedAt, stats); err != nil {
			log.Printf("[warn] collector:last_run 갱신 실패(비치명적): %v", err)
		}
	}

	// 11) 구조화 요약 로그(CloudWatch Logs Insights 집계용).
	log.Printf("pipeline_summary collected=%d valid=%d invalid=%d normalized_stations=%d upserted=%d failed=%d cache_refreshed=%d cache_failed=%d finished_at=%s",
		stats.CollectedItems, stats.ValidItems, stats.InvalidItems, stats.NormalizedStns,
		stats.UpsertedStns, stats.FailedStns, stats.CacheRefreshed, stats.CacheFailedStns,
		finishedAt.Format(time.RFC3339))
}

// newStorage는 S3_BUCKET 유무에 따라 S3 업로더를 붙인 Storage를 만든다.
func newStorage(ctx context.Context, outputDir string) *storage.Storage {
	cfg := storage.Config{
		OutputDir: outputDir,
		S3Bucket:  os.Getenv("S3_BUCKET"),
		S3Prefix:  os.Getenv("S3_PREFIX"),
	}
	var uploader storage.S3Uploader
	if cfg.S3Bucket != "" {
		up, err := storage.NewS3Uploader(ctx)
		if err != nil {
			log.Fatalf("S3 업로더 초기화 실패: %v", err)
		}
		uploader = up
	} else {
		log.Printf("S3_BUCKET 미설정 — S3 업로드를 건너뛰고 로컬 저장만 수행한다.")
	}
	return storage.New(cfg, uploader)
}

// newCache는 REDIS_HOST가 설정된 경우에만 캐시 클라이언트를 만든다.
func newCache() *cache.Client {
	host := os.Getenv("REDIS_HOST")
	if host == "" {
		log.Printf("REDIS_HOST 미설정 — 캐시 갱신 단계를 건너뛴다.")
		return nil
	}
	port := os.Getenv("REDIS_PORT")
	if port == "" {
		port = "6379"
	}
	return cache.NewClient(host, port, os.Getenv("REDIS_AUTH_TOKEN"))
}

// refreshStationCache는 한 station의 커밋 성공 직후 그 station의 캐시를 갱신한다.
// Redis 실패는 파이프라인을 막지 않고 통계에만 반영한다.
func refreshStationCache(ctx context.Context, c *cache.Client, res db.UpsertResult, st model.NormalizedStation, stats *model.PipelineStats) {
	if c == nil {
		return
	}
	failed := false
	for _, uc := range res.Chargers {
		if err := c.RefreshChargerStatus(ctx, uc.ChargerID, uc.Norm.Status); err != nil {
			failed = true
		}
	}
	if err := c.RefreshStationAvailability(ctx, res.StationID, st.Chargers); err != nil {
		failed = true
	}
	if err := c.RefreshConnectorBreakdown(ctx, res.StationID, st.Chargers); err != nil {
		failed = true
	}
	if failed {
		stats.CacheFailedStns++
	} else {
		stats.CacheRefreshed++
	}
}
