// fetch.go는 환경부 EvCharger API 호출(재시도·서비스키 풀 전환 포함)과 페이지네이션
// 전량 수집, 재개용 체크포인트 관리를 담당한다.
package main

import (
	"bytes"
	"context"
	"encoding/json"
	"encoding/xml"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"ev-charger-collector/internal/keypool"
	"ev-charger-collector/internal/model"
	"ev-charger-collector/internal/storage"
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

var httpClient = &http.Client{Timeout: requestTimeout}

const interPageDelay = 300 * time.Millisecond

// authFailure는 서비스키 오류 등 재시도해도 해결되지 않는 실패를 나타낸다.
type authFailure struct{ msg string }

func (e *authFailure) Error() string { return e.msg }

// errEmptyResponse는 응답 바디가 완전히 비어 XML 디코딩이 io.EOF로 실패한 경우를 나타내는
// 센티널 에러다. 공공데이터포털 서비스키의 일일 호출 한도(1,000회)가 소진되면 서버가 빈
// 바디를 돌려주는데, 이는 재시도해도 회복되지 않는다. keypool 도입 이후에는 "이 키가
// 소진됨"을 뜻할 뿐이라 fetchPage가 먼저 풀의 다음 키로 전환을 시도하고, 풀 전체가
// 소진됐을 때만 최종적으로 이 에러를 반환한다(의미가 "풀 전체 소진"으로 확장됨).
var errEmptyResponse = errors.New("빈 응답(일일 호출 한도 소진 추정)")

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

// fetchPageWithKey는 단일 서비스키로 pageNo 한 페이지를 재시도 정책과 함께 호출한다.
// 인증/서비스 레벨 오류는 재시도 없이 즉시 실패시키고, 트래픽 제한·네트워크·5xx류
// 일시 오류는 지수 백오프로 재시도한다. ctx가 취소되면 재시도하지 않고 즉시 중단한다.
// 빈 응답(errEmptyResponse)도 재시도 대상이 아니다 — 이 키의 쿼터 소진으로 보고 즉시
// 반환하며, 다음 키로 전환할지는 호출측(fetchPage)이 판단한다.
func fetchPageWithKey(ctx context.Context, serviceKey, zcode string, pageNo, numOfRows int) ([]byte, *model.Response, error) {
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
			// 응답 바디가 완전히 비어 io.EOF로 디코딩이 실패한 경우는 재시도 대상이 아니다
			// (일일 호출 한도 소진 등). 5회 재시도(총 15초)를 낭비하지 않고 즉시 중단한다.
			// non-empty지만 malformed한 XML은 기존처럼 재시도 유지.
			if len(rr.raw) == 0 && errors.Is(rr.decErr, io.EOF) {
				return nil, nil, fmt.Errorf("%w (page=%d)", errEmptyResponse, pageNo)
			}
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

// fetchPage는 keypool.Pool에서 현재 키를 가져와 pageNo 한 페이지를 호출한다. 빈 응답
// (errEmptyResponse, 이 키의 쿼터 소진 추정)을 만나면 풀에 아직 안 써본 키가 있는 한
// Advance로 다음 키로 전환해 같은 페이지를 재시도한다. 풀 전체를 다 써봐도 빈 응답이면
// 그때만 errEmptyResponse를 최종 반환한다(기존과 동일한 의미, "풀 전체 소진"으로 확장).
// authFailure(서비스 레벨 오류)는 키 전환으로 해결되지 않는 설정 실수일 수 있으므로
// 건드리지 않고 즉시 그대로 반환한다(설정 실수를 자동으로 감추지 않기 위함).
func fetchPage(ctx context.Context, pool *keypool.Pool, zcode string, pageNo, numOfRows int) ([]byte, *model.Response, error) {
	idx, key, err := pool.Current(ctx)
	if err != nil {
		return nil, nil, fmt.Errorf("keypool 조회 실패: %w", err)
	}

	triedKeys := 0
	poolSize := pool.Size()
	for {
		raw, resp, ferr := fetchPageWithKey(ctx, key, zcode, pageNo, numOfRows)
		if ferr == nil {
			return raw, resp, nil
		}
		if !errors.Is(ferr, errEmptyResponse) {
			return nil, nil, ferr
		}

		triedKeys++
		if triedKeys >= poolSize {
			// 풀에 있는 키를 모두 시도했는데도 빈 응답 — 풀 전체 소진으로 최종 반환.
			return nil, nil, ferr
		}

		newIdx, newKey, aerr := pool.Advance(ctx, idx)
		if aerr != nil {
			return nil, nil, fmt.Errorf("keypool 전환 실패: %w", aerr)
		}
		log.Printf("[fetch] 빈 응답(쿼터 소진 추정) — 다음 키로 전환(idx=%d -> %d, 풀 크기=%d), page=%d 재시도", idx, newIdx, poolSize, pageNo)
		idx, key = newIdx, newKey
	}
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

// checkpointFileName은 --output-dir 아래에 두는 페이지네이션 재개용 체크포인트
// 파일 이름이다. mode(fast/slow/archive)별로 파일을 분리해, fast/slow가 같은
// --output-dir를 공유해도 서로 체크포인트를 덮어쓰지 않게 한다. 일일 호출 한도
// 소진 등으로 수집이 중간에 끊겼을 때, 다음 실행이 이미 끝낸 페이지를 처음부터
// 다시 요청해 새 키의 쿼터까지 낭비하지 않도록 한다.
func checkpointFileName(mode string) string {
	return fmt.Sprintf("collector_checkpoint_%s.json", mode)
}

// checkpoint는 수집 진행 상태를 최소한으로 담는다. zcode가 이번 실행과 일치할 때만
// lastCompletedPage 다음 페이지부터 재개하고, 자연 종료(빈 페이지 도달 등) 시 삭제한다.
type checkpoint struct {
	Zcode             string `json:"zcode"`
	LastCompletedPage int    `json:"lastCompletedPage"`
	UpdatedAt         string `json:"updatedAt"`
}

// checkpointPath는 output-dir 안의 mode별 체크포인트 파일 경로를 만든다.
func checkpointPath(outputDir, mode string) string {
	return filepath.Join(outputDir, checkpointFileName(mode))
}

// readCheckpoint는 체크포인트 파일을 읽어 파싱한다. 파일이 없거나 파싱 실패 시
// 에러를 반환하며, 호출측이 안전하게 pageNo=1 폴백을 판단한다.
func readCheckpoint(path string) (*checkpoint, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var ckpt checkpoint
	if err := json.Unmarshal(data, &ckpt); err != nil {
		return nil, err
	}
	return &ckpt, nil
}

// writeCheckpoint는 방금 성공적으로 수집한 pageNo를 zcode와 함께 파일에 덮어쓴다.
// output-dir이 아직 없을 수 있으므로 상위 디렉터리를 먼저 보장한다.
func writeCheckpoint(path, zcode string, pageNo int) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	data, err := json.MarshalIndent(&checkpoint{
		Zcode:             zcode,
		LastCompletedPage: pageNo,
		UpdatedAt:         time.Now().UTC().Format(time.RFC3339),
	}, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(path, data, 0o644)
}

// clearCheckpoint는 체크포인트 파일을 삭제한다. 이미 없으면 성공으로 취급한다.
func clearCheckpoint(path string) error {
	if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
		return err
	}
	return nil
}

// resumePage는 체크포인트를 참고해 이번 실행이 시작할 pageNo를 결정한다.
// 파일이 있고 zcode가 일치하면 lastCompletedPage+1부터 재개하고, 파일이 없거나
// zcode가 다르거나 파싱에 실패하면 안전하게 1부터 시작한다(기존 동작 유지).
func resumePage(path, zcode string) int {
	ckpt, err := readCheckpoint(path)
	if err != nil {
		if !os.IsNotExist(err) {
			log.Printf("[warn] 체크포인트 읽기 실패 — 1페이지부터 시작: %v", err)
		}
		return 1
	}
	if ckpt.Zcode != zcode {
		log.Printf("체크포인트 zcode 불일치(파일=%q, 이번=%q) — 1페이지부터 새로 수집", ckpt.Zcode, zcode)
		return 1
	}
	if ckpt.LastCompletedPage < 1 {
		return 1
	}
	start := ckpt.LastCompletedPage + 1
	log.Printf("체크포인트 발견(zcode=%q, lastCompletedPage=%d) — page=%d부터 재개", ckpt.Zcode, ckpt.LastCompletedPage, start)
	return start
}

// collectAll은 pageNo=1(또는 체크포인트가 있으면 그 다음 페이지)부터 빈 페이지가
// 올 때까지 반복 호출해 데이터를 수집한다. zcode가 비어 있으면 전국 전체를,
// 시도코드가 지정되면 해당 시도 범위만 수집한다. 페이지별 원본 XML을 그대로
// 보존할 수 있도록 페이지 단위 결과를 모두 반환한다. ctx가 취소되면 루프를 즉시
// 중단한다. outputDir에는 재개용 체크포인트 파일을 두어, 쿼터 소진 등으로 중간에
// 끊겨도 다음 실행이 끝낸 지점부터 이어받게 하고 자연 종료 시엔 초기화한다.
// mode는 체크포인트 파일명 분리에만 쓰인다(fast/slow가 같은 outputDir를 써도 서로
// 덮어쓰지 않게).
func collectAll(ctx context.Context, pool *keypool.Pool, zcode string, numOfRows int, outputDir, mode string, stor *storage.Storage) ([]storage.RawPage, error) {
	ckptPath := checkpointPath(outputDir, mode)
	var pages []storage.RawPage
	collected := 0
	pageNo := resumePage(ckptPath, zcode)

	for {
		if err := ctx.Err(); err != nil {
			return pages, err
		}
		if pageNo > 1 {
			if err := sleepCtx(ctx, interPageDelay); err != nil {
				return pages, err
			}
		}

		rawXML, resp, err := fetchPage(ctx, pool, zcode, pageNo, numOfRows)
		if err != nil {
			return pages, err
		}

		items := resp.Body.Items.Item
		page := storage.RawPage{PageNo: pageNo, RawXML: rawXML, Items: items}

		// 원본 XML을 먼저 즉시 저장한다(로컬+S3). 이 저장은 반드시 체크포인트 기록보다
		// 앞서야 한다 — 순서를 반대로 두면 "체크포인트는 전진했는데 실제 원본은 없는"
		// 유실 창구가 재발한다. persist 실패는 원본 보존 실패이므로 수집을 중단하고 에러를
		// 그대로 반환한다(ctx 만료/취소면 예산초과로, 그 외엔 StatusError로 분류된다).
		if err := stor.PersistRawPage(ctx, page); err != nil {
			return pages, err
		}

		// 원본 저장이 성공한 뒤에야 방금 페이지를 체크포인트에 기록(덮어쓰기)한다. 체크포인트
		// 저장 자체 실패는 비치명적이다(재개 최적화일 뿐 필수 경로가 아니다).
		if err := writeCheckpoint(ckptPath, zcode, pageNo); err != nil {
			log.Printf("[warn] 체크포인트 저장 실패(비치명적): %v", err)
		}

		collected += len(items)
		log.Printf("page=%d 수집=%d건 (누적 %d/%d)", pageNo, len(items), collected, resp.Body.TotalCount)

		pages = append(pages, page)

		// totalCount가 0 이하로 오는 소스(예: zcode=11)가 있어 신뢰할 수 없으므로,
		// 양수일 때만 조기 종료 판단에 쓰고 그 외엔 빈 페이지로만 종료한다.
		if (resp.Body.TotalCount > 0 && collected >= resp.Body.TotalCount) || len(items) == 0 {
			break
		}
		pageNo++
	}

	// 자연 종료(전량 수집 완료)에 도달했으므로 체크포인트를 초기화한다. 이렇게 해야
	// 다음 정기 실행에서 이 지역을 처음부터 새로고침 수집한다. 쿼터 소진 등으로 위에서
	// return으로 빠져나간 경우엔 이 지점에 도달하지 않아 체크포인트가 남아 재개된다.
	if err := clearCheckpoint(ckptPath); err != nil {
		log.Printf("[warn] 체크포인트 삭제 실패(비치명적): %v", err)
	}

	log.Printf("전체 수집 완료: 총 %d건, %d페이지", collected, len(pages))
	return pages, nil
}

// classifyCollectStatus는 collectAll이 반환한 에러를 파이프라인 종료 상태로 분류한다.
// nil이면 전량 완료(Complete), errEmptyResponse면 빈 응답(쿼터 소진 추정, EmptyResponse),
// ctx 취소/마감 초과면 예산 초과(BudgetExceeded), 그 외는 일반 오류(Error)로 본다.
// collectAll/fetchPage가 ctx.Err()를 그대로 반환하므로 DeadlineExceeded/Canceled가 매치된다.
func classifyCollectStatus(err error) model.PipelineStatus {
	switch {
	case err == nil:
		return model.StatusComplete
	case errors.Is(err, errEmptyResponse):
		return model.StatusEmptyResponse
	case errors.Is(err, context.DeadlineExceeded), errors.Is(err, context.Canceled):
		return model.StatusBudgetExceeded
	default:
		return model.StatusError
	}
}
