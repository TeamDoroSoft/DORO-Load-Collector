package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"ev-charger-collector/internal/keypool"
	"ev-charger-collector/internal/storage"
)

func TestLockPathForMode(t *testing.T) {
	cases := map[string]string{
		"slow":    "/var/run/ev-charger-collector-slow.lock",
		"fast":    "/var/run/ev-charger-collector-fast.lock",
		"archive": "/var/run/ev-charger-collector-archive.lock",
	}
	for mode, want := range cases {
		if got := lockPathForMode(mode); got != want {
			t.Errorf("lockPathForMode(%q) = %q, want %q", mode, got, want)
		}
	}
	// 서로 다른 모드는 항상 서로 다른 경로여야 한다(동시 실행이 서로 막지 않기 위함).
	if lockPathForMode("fast") == lockPathForMode("slow") {
		t.Fatal("fast/slow lock 경로가 동일함 — 동시 실행 시 서로 막게 됨")
	}
}

func TestCheckpointFileName(t *testing.T) {
	if got := checkpointFileName("slow"); got != "collector_checkpoint_slow.json" {
		t.Errorf("checkpointFileName(slow) = %q", got)
	}
	if got := checkpointFileName("fast"); got != "collector_checkpoint_fast.json" {
		t.Errorf("checkpointFileName(fast) = %q", got)
	}
	if checkpointFileName("fast") == checkpointFileName("slow") {
		t.Fatal("fast/slow 체크포인트 파일명이 동일함 — 같은 output-dir 공유 시 덮어씀")
	}
}

func TestResolveTimeout(t *testing.T) {
	if got := resolveTimeout(5*time.Minute, "slow", ""); got != 5*time.Minute {
		t.Errorf("명시적 --timeout이 우선되지 않음: %v", got)
	}
	if got := resolveTimeout(0, "slow", ""); got != slowDefaultTimeout {
		t.Errorf("slow 기본값 불일치: %v", got)
	}
	if got := resolveTimeout(0, "slow", "20260101"); got != recoverTimeout {
		t.Errorf("recover-date 지정 시 recoverTimeout이어야 함: %v", got)
	}
	if got := resolveTimeout(0, "fast", ""); got != fastDefaultTimeout {
		t.Errorf("fast 기본값 불일치: %v", got)
	}
	if got := resolveTimeout(0, "archive", ""); got != archiveDefaultTimeout {
		t.Errorf("archive 기본값 불일치: %v", got)
	}
}

func TestClassifyCollectStatus(t *testing.T) {
	if got := classifyCollectStatus(nil); got != "complete" {
		t.Errorf("nil 에러는 complete여야 함: %v", got)
	}
	if got := classifyCollectStatus(fmt.Errorf("wrap: %w", errEmptyResponse)); got != "empty_response" {
		t.Errorf("errEmptyResponse는 empty_response여야 함: %v", got)
	}
	if got := classifyCollectStatus(context.DeadlineExceeded); got != "budget_exceeded" {
		t.Errorf("DeadlineExceeded는 budget_exceeded여야 함: %v", got)
	}
	if got := classifyCollectStatus(context.Canceled); got != "budget_exceeded" {
		t.Errorf("Canceled는 budget_exceeded여야 함: %v", got)
	}
	if got := classifyCollectStatus(errors.New("기타 오류")); got != "error" {
		t.Errorf("그 외 오류는 error여야 함: %v", got)
	}
}

// evPage는 테스트용 최소 응답 XML을 만든다.
func evPage(resultCode string, pageNo, numOfRows, totalCount int, itemsXML string) string {
	return fmt.Sprintf(`<response>
  <header><resultCode>%s</resultCode><resultMsg>OK</resultMsg></header>
  <body>
    <items>%s</items>
    <numOfRows>%d</numOfRows>
    <pageNo>%d</pageNo>
    <totalCount>%d</totalCount>
  </body>
</response>`, resultCode, itemsXML, numOfRows, pageNo, totalCount)
}

const oneItemXML = `<item><statNm>테스트충전소</statNm><statId>ST0001</statId><chgerId>1</chgerId></item>`

// TestFetchPage_KeyPoolSwitchesOnEmptyResponse는 첫 키(bad)가 빈 응답(쿼터 소진
// 추정)을 주면 keypool.Pool이 자동으로 다음 키(good)로 전환해 같은 페이지를
// 재시도하고, 결국 성공하는지 확인한다(EVCHARGER_SERVICE_KEYS=bad,good 시나리오).
func TestFetchPage_KeyPoolSwitchesOnEmptyResponse(t *testing.T) {
	var sawKeys []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		key := r.URL.Query().Get("serviceKey")
		sawKeys = append(sawKeys, key)
		if key == "bad" {
			// 완전히 빈 바디 — errEmptyResponse 유발(EOF).
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(evPage("00", 1, 100, 1, oneItemXML)))
	}))
	defer srv.Close()

	origEndpoint := apiEndpoint
	apiEndpoint = srv.URL
	defer func() { apiEndpoint = origEndpoint }()

	statePath := filepath.Join(t.TempDir(), "state.json")
	pool, err := keypool.New([]string{"bad", "good"}, statePath)
	if err != nil {
		t.Fatalf("keypool.New 실패: %v", err)
	}

	raw, resp, err := fetchPage(context.Background(), pool, "", 1, 100)
	if err != nil {
		t.Fatalf("fetchPage 실패(키 전환이 동작하지 않음): %v", err)
	}
	if len(raw) == 0 || resp == nil || len(resp.Body.Items.Item) != 1 {
		t.Fatalf("전환 후 응답이 올바르지 않음: raw=%d resp=%+v", len(raw), resp)
	}
	if len(sawKeys) < 2 || sawKeys[0] != "bad" || sawKeys[1] != "good" {
		t.Fatalf("키 사용 순서가 기대와 다름: %v", sawKeys)
	}

	idx, key, err := pool.Current(context.Background())
	if err != nil {
		t.Fatalf("pool.Current 실패: %v", err)
	}
	if idx != 1 || key != "good" {
		t.Fatalf("전환 후 풀 상태가 good에 머물러 있지 않음: idx=%d key=%q", idx, key)
	}
}

// TestFetchPage_AllKeysExhausted는 풀의 모든 키가 빈 응답을 주면 errEmptyResponse가
// 최종적으로 반환되는지 확인한다("풀 전체 소진"으로 확장된 의미).
func TestFetchPage_AllKeysExhausted(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK) // 항상 빈 바디.
	}))
	defer srv.Close()

	origEndpoint := apiEndpoint
	apiEndpoint = srv.URL
	defer func() { apiEndpoint = origEndpoint }()

	statePath := filepath.Join(t.TempDir(), "state.json")
	pool, err := keypool.New([]string{"k1", "k2"}, statePath)
	if err != nil {
		t.Fatalf("keypool.New 실패: %v", err)
	}

	_, _, err = fetchPage(context.Background(), pool, "", 1, 100)
	if !errors.Is(err, errEmptyResponse) {
		t.Fatalf("풀 전체 소진 시 errEmptyResponse가 반환돼야 함: %v", err)
	}
}

// TestCollectAll_NaturalCompletionClearsCheckpoint는 정상 종료(빈 페이지 도달) 시
// 체크포인트 파일이 삭제되는지, 그리고 mode별로 체크포인트 파일이 분리되는지 확인한다.
func TestCollectAll_NaturalCompletionClearsCheckpoint(t *testing.T) {
	pageNo := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		pageNo++
		w.WriteHeader(http.StatusOK)
		if pageNo == 1 {
			// totalCount를 실제 item 수보다 크게 줘서 조기 종료 조건에 걸리지 않게 한다
			// (collectAll은 collected>=totalCount면 다음 페이지를 부르지 않고 끝낸다).
			_, _ = w.Write([]byte(evPage("00", 1, 100, 2, oneItemXML)))
			return
		}
		// 2페이지째는 빈 item으로 자연 종료.
		_, _ = w.Write([]byte(evPage("00", 2, 100, 2, "")))
	}))
	defer srv.Close()

	origEndpoint := apiEndpoint
	apiEndpoint = srv.URL
	defer func() { apiEndpoint = origEndpoint }()

	outputDir := t.TempDir()
	statePath := filepath.Join(t.TempDir(), "state.json")
	pool, err := keypool.New([]string{"only-key"}, statePath)
	if err != nil {
		t.Fatalf("keypool.New 실패: %v", err)
	}
	stor := storage.New(storage.Config{OutputDir: outputDir}, nil)

	pages, err := collectAll(context.Background(), pool, "", 100, outputDir, "fast", stor)
	if err != nil {
		t.Fatalf("collectAll 실패: %v", err)
	}
	if len(pages) != 2 {
		t.Fatalf("페이지 수 불일치: %d", len(pages))
	}

	ckptPath := checkpointPath(outputDir, "fast")
	if _, err := os.Stat(ckptPath); !os.IsNotExist(err) {
		t.Fatalf("자연 종료 후 체크포인트가 삭제되지 않음: %v", err)
	}

	// slow 모드용 체크포인트 파일은 애초에 만들어지지 않았어야 한다(분리 확인).
	slowCkptPath := checkpointPath(outputDir, "slow")
	if _, err := os.Stat(slowCkptPath); !os.IsNotExist(err) {
		t.Fatalf("fast 실행인데 slow 체크포인트 파일이 존재함: %s", slowCkptPath)
	}
}
