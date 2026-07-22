// pipeline_common.go는 fast/slow path가 공유하는 부트스트랩(DB/Storage/Cache 클라이언트
// 초기화)과 캐시 갱신 헬퍼를 담는다.
package main

import (
	"context"
	"log"
	"os"

	"ev-charger-collector/internal/cache"
	"ev-charger-collector/internal/db"
	"ev-charger-collector/internal/model"
	"ev-charger-collector/internal/storage"
)

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

// refreshStationCache는 한 station의 커밋(또는 fast path에서는 프리로드로 확인된) 직후
// 그 station의 캐시를 갱신한다. Redis 실패는 파이프라인을 막지 않고 통계에만 반영한다.
// res.Chargers는 slow path에서는 UpsertStation이 실제로 적재한 charger 전체이고,
// fast path에서는 프리로드 매핑으로 해석에 성공한(신규가 아닌) charger만 담긴
// 부분집합이다 — 두 경우 모두 이 함수 입장에서는 동일하게 다룬다.
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
