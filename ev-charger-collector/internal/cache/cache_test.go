package cache

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/alicebob/miniredis/v2"
	"github.com/redis/go-redis/v9"

	"ev-charger-collector/internal/model"
)

func newTestClient(t *testing.T) (*Client, *miniredis.Miniredis) {
	t.Helper()
	mr, err := miniredis.Run()
	if err != nil {
		t.Fatalf("miniredis 시작 실패: %v", err)
	}
	t.Cleanup(mr.Close)
	rdb := redis.NewClient(&redis.Options{Addr: mr.Addr()})
	return NewClientFromRedis(rdb), mr
}

func TestRefreshLastRun_FastUpdatesCommonAndModeKey(t *testing.T) {
	c, mr := newTestClient(t)
	finishedAt := time.Date(2026, 7, 22, 3, 0, 0, 0, time.UTC)

	if err := c.RefreshLastRun(context.Background(), finishedAt, model.PipelineStats{UpsertedStns: 5}, "fast"); err != nil {
		t.Fatalf("RefreshLastRun 실패: %v", err)
	}

	if !mr.Exists("collector:last_run") {
		t.Fatalf("fast 실행인데 공용 키 collector:last_run이 갱신되지 않음")
	}
	if !mr.Exists("collector:last_run:fast") {
		t.Fatalf("collector:last_run:fast가 갱신되지 않음")
	}
	if mr.Exists("collector:last_run:slow") {
		t.Fatalf("fast 실행인데 collector:last_run:slow가 생성됨")
	}

	raw, err := mr.Get("collector:last_run:fast")
	if err != nil {
		t.Fatalf("collector:last_run:fast 조회 실패: %v", err)
	}
	var payload map[string]any
	if err := json.Unmarshal([]byte(raw), &payload); err != nil {
		t.Fatalf("payload가 유효한 JSON이 아님: %v", err)
	}
	if payload["mode"] != "fast" {
		t.Fatalf("mode 필드 불일치: %v", payload["mode"])
	}
}

func TestRefreshLastRun_SlowDoesNotTouchCommonKey(t *testing.T) {
	c, mr := newTestClient(t)
	finishedAt := time.Now().UTC()

	if err := c.RefreshLastRun(context.Background(), finishedAt, model.PipelineStats{UpsertedStns: 1}, "slow"); err != nil {
		t.Fatalf("RefreshLastRun 실패: %v", err)
	}

	if mr.Exists("collector:last_run") {
		t.Fatalf("slow 실행인데 공용 키 collector:last_run이 생성됨(설계상 fast 전용이어야 함)")
	}
	if !mr.Exists("collector:last_run:slow") {
		t.Fatalf("collector:last_run:slow가 갱신되지 않음")
	}
}
