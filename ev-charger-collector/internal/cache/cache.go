// Package cache는 Redis 캐시 갱신을 담당한다(go-redis/v9).
// RDS가 source of truth이고 Redis는 Spring Boot 백엔드의 read-through 캐시다.
//
// 키 패턴(deployment-v2 §4):
//   - charger:status:{charger_id}            Hash {status, source_updated_at, collected_at}
//   - station:availability:{station_id}      Hash {rapid_total, rapid_available, slow_total, slow_available}
//   - station:connector_breakdown:{station_id} String(JSON)
//   - collector:last_run                     String(ISO timestamp + 요약 통계)
//
// 쓰기 순서 원칙: db.UpsertStation 커밋 성공 직후 그 station만 즉시 갱신한다.
// Redis 실패는 1회 재시도 후 경고만 남기고 파이프라인을 막지 않는다.
// 폐쇄 충전소 캐시 즉시 DEL은 이번 범위 제외(TTL 자연 소멸에 위임).
package cache

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"sort"
	"time"

	"github.com/redis/go-redis/v9"

	"ev-charger-collector/internal/model"
)

// TTL은 실행 주기(15분)의 3배로, 실행이 지연돼도 캐시가 급격히 비지 않게 한다.
const TTL = 45 * time.Minute

// timeFormat은 캐시에 기록하는 시간 문자열 포맷(RFC3339, UTC)이다.
const timeFormat = time.RFC3339

// Client는 Redis 캐시 갱신 진입점이다.
type Client struct {
	rdb *redis.Client
}

// NewClient는 host/port/authToken으로 Redis 클라이언트를 만든다.
// authToken이 비어 있으면 비밀번호 없이 접속한다. ElastiCache Serverless는
// 전송 중 암호화(TLS)가 강제라 TLSConfig를 항상 설정한다(평문 연결 시 핸드셰이크가
// 안 맞아 타임아웃만 나고 원인이 드러나지 않는다).
func NewClient(host, port, authToken string) *Client {
	return &Client{rdb: redis.NewClient(&redis.Options{
		Addr:      fmt.Sprintf("%s:%s", host, port),
		Password:  authToken,
		TLSConfig: &tls.Config{ServerName: host},
	})}
}

// NewClientFromRedis는 이미 만들어진 *redis.Client를 감싼다(테스트용: miniredis 주입).
func NewClientFromRedis(rdb *redis.Client) *Client {
	return &Client{rdb: rdb}
}

// Close는 내부 Redis 연결을 닫는다.
func (c *Client) Close() error {
	return c.rdb.Close()
}

// Ping은 연결 확인용이다.
func (c *Client) Ping(ctx context.Context) error {
	return c.rdb.Ping(ctx).Err()
}

// RefreshChargerStatus는 개별 충전기 최신 상태를 charger:status:{chargerID}에 갱신한다.
func (c *Client) RefreshChargerStatus(ctx context.Context, chargerID int64, ev model.NormalizedStatusEvent) error {
	key := fmt.Sprintf("charger:status:%d", chargerID)
	fields := map[string]any{
		"status":            ev.Status,
		"source_updated_at": formatTime(ev.SourceUpdatedAt),
		"collected_at":      formatTime(ev.CollectedAt),
	}
	return c.withRetry(func() error {
		if err := c.rdb.HSet(ctx, key, fields).Err(); err != nil {
			return err
		}
		return c.rdb.Expire(ctx, key, TTL).Err()
	})
}

// RefreshStationAvailability는 급속/완속 총·이용가능 대수를 집계해
// station:availability:{stationID}에 갱신한다(charge_speed 기반).
func (c *Client) RefreshStationAvailability(ctx context.Context, stationID int64, chargers []model.NormalizedCharger) error {
	var rapidTotal, rapidAvail, slowTotal, slowAvail int
	for _, ch := range chargers {
		available := ch.Status.Status == "AVAILABLE"
		switch ch.ChargeSpeed {
		case "RAPID":
			rapidTotal++
			if available {
				rapidAvail++
			}
		case "SLOW":
			slowTotal++
			if available {
				slowAvail++
			}
		}
		// UNKNOWN 속도는 급속/완속 어느 쪽에도 포함하지 않는다.
	}

	key := fmt.Sprintf("station:availability:%d", stationID)
	fields := map[string]any{
		"rapid_total":     rapidTotal,
		"rapid_available": rapidAvail,
		"slow_total":      slowTotal,
		"slow_available":  slowAvail,
	}
	return c.withRetry(func() error {
		if err := c.rdb.HSet(ctx, key, fields).Err(); err != nil {
			return err
		}
		return c.rdb.Expire(ctx, key, TTL).Err()
	})
}

// connectorAgg는 커넥터 타입별 집계 항목이다(JSON 직렬화용).
type connectorAgg struct {
	ConnectorType string `json:"connector_type"`
	Total         int    `json:"total"`
	Available     int    `json:"available"`
}

// RefreshConnectorBreakdown은 커넥터 타입별 총·이용가능 대수를 JSON으로
// station:connector_breakdown:{stationID}에 갱신한다.
func (c *Client) RefreshConnectorBreakdown(ctx context.Context, stationID int64, chargers []model.NormalizedCharger) error {
	totals := make(map[string]*connectorAgg)
	for _, ch := range chargers {
		agg, ok := totals[ch.ChargerType]
		if !ok {
			agg = &connectorAgg{ConnectorType: ch.ChargerType}
			totals[ch.ChargerType] = agg
		}
		agg.Total++
		if ch.Status.Status == "AVAILABLE" {
			agg.Available++
		}
	}

	// 결정적 순서를 위해 커넥터 타입명으로 정렬.
	keys := make([]string, 0, len(totals))
	for k := range totals {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	list := make([]connectorAgg, 0, len(keys))
	for _, k := range keys {
		list = append(list, *totals[k])
	}

	data, err := json.Marshal(list)
	if err != nil {
		return fmt.Errorf("connector_breakdown 인코딩 실패: %w", err)
	}
	key := fmt.Sprintf("station:connector_breakdown:%d", stationID)
	return c.withRetry(func() error {
		return c.rdb.Set(ctx, key, data, TTL).Err()
	})
}

// RefreshLastRun은 마지막 실행 시각과 요약 통계를 collector:last_run에 기록한다.
// 헬스체크/화면 "마지막 수집 시간" 표시에 쓰이므로 TTL 없이 유지한다.
func (c *Client) RefreshLastRun(ctx context.Context, finishedAt time.Time, stats model.PipelineStats) error {
	payload := map[string]any{
		"finished_at": formatTime(finishedAt),
		"stats":       stats,
	}
	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("last_run 인코딩 실패: %w", err)
	}
	return c.withRetry(func() error {
		return c.rdb.Set(ctx, "collector:last_run", data, 0).Err()
	})
}

// withRetry는 Redis 쓰기를 1회 재시도한 뒤 실패하면 경고만 남기고 error를 반환한다.
// (호출부는 이 error로 파이프라인을 중단하지 않고 통계에만 반영한다.)
func (c *Client) withRetry(fn func() error) error {
	err := fn()
	if err == nil {
		return nil
	}
	log.Printf("[cache] Redis 쓰기 실패, 1회 재시도: %v", err)
	if retryErr := fn(); retryErr != nil {
		log.Printf("[cache] Redis 쓰기 재시도도 실패(경고, 파이프라인 계속): %v", retryErr)
		return retryErr
	}
	return nil
}

// formatTime은 시간을 RFC3339(UTC) 문자열로 만든다. zero면 빈 문자열.
func formatTime(t time.Time) string {
	if t.IsZero() {
		return ""
	}
	return t.UTC().Format(timeFormat)
}
