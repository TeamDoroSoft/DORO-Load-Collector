// Package storage는 원본/오류/집계 데이터의 영속화를 담당한다.
//   - PersistRawPages: 원본 XML을 로컬에 항상 저장하고, S3_BUCKET이 설정된 경우
//     지수 백오프 3회 재시도로 S3에 업로드한다. 원본 보존은 CLAUDE.md 필수 규칙이라
//     S3 업로드 실패 시 파이프라인 전체를 중단시키기 위해 error를 반환한다.
//   - PersistErrorItems: 오류 item을 로컬+S3에 저장한다. 실패는 비치명적(경고만).
//   - PersistItemsJSON: 기존 집계 JSON(디버그용)을 로컬에 저장한다.
//
// S3 클라이언트는 aws-sdk-go-v2 config.LoadDefaultConfig로 EC2 Instance Profile
// 자격증명을 자동 사용한다(하드코딩 없음). S3Uploader 인터페이스로 추상화해
// 유닛 테스트에서 목으로 대체할 수 있게 한다.
package storage

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"

	"ev-charger-collector/internal/model"
	"ev-charger-collector/internal/validate"
)

// RawPage는 한 페이지 호출의 원본 XML과 파싱된 아이템 목록을 담는다.
// (기존 main.pageResult를 이 패키지로 이동.)
type RawPage struct {
	PageNo int
	RawXML []byte
	Items  []model.RawItem
}

// S3Uploader는 S3 업로드를 추상화한다(유닛 테스트에서 목 주입 가능).
type S3Uploader interface {
	PutObject(ctx context.Context, bucket, key string, body []byte) error
}

// Config는 storage 동작에 필요한 설정이다.
type Config struct {
	OutputDir string // 로컬 저장 루트(예: ./output)
	S3Bucket  string // 비면 S3 업로드 스킵
	S3Prefix  string // S3 키 접두사(예: evcharger)
}

// Storage는 로컬/S3 저장 진입점이다.
type Storage struct {
	cfg      Config
	uploader S3Uploader // nil이면 S3 스킵
}

// New는 Storage를 생성한다. uploader가 nil이거나 S3Bucket이 비면 S3 업로드를 건너뛴다.
func New(cfg Config, uploader S3Uploader) *Storage {
	return &Storage{cfg: cfg, uploader: uploader}
}

// s3Enabled는 S3 업로드가 활성인지 여부다.
func (s *Storage) s3Enabled() bool {
	return s.uploader != nil && s.cfg.S3Bucket != ""
}

const (
	rawUploadRetries = 3
	rawBaseBackoff   = 1 * time.Second
)

// PersistRawPages는 원본 XML을 로컬에 항상 저장하고, S3가 활성이면 업로드한다.
// S3 업로드는 지수 백오프 3회 재시도하며, 최종 실패 시 error를 반환한다(파이프라인 중단).
func (s *Storage) PersistRawPages(ctx context.Context, pages []RawPage) error {
	rawDir := filepath.Join(s.cfg.OutputDir, "raw")
	if err := os.MkdirAll(rawDir, 0o755); err != nil {
		return fmt.Errorf("raw 디렉터리 생성 실패: %w", err)
	}

	ts := time.Now().UTC().Format("20060102150405")
	datePart := time.Now().UTC().Format("20060102")

	for _, p := range pages {
		fname := fmt.Sprintf("evcharger_page%d_%s.xml", p.PageNo, ts)

		localPath := filepath.Join(rawDir, fname)
		if err := os.WriteFile(localPath, p.RawXML, 0o644); err != nil {
			return fmt.Errorf("원본 XML 로컬 저장 실패(page=%d): %w", p.PageNo, err)
		}

		if s.s3Enabled() {
			key := s.s3Key("raw", datePart, fname)
			if err := s.uploadWithRetry(ctx, key, p.RawXML); err != nil {
				return fmt.Errorf("원본 XML S3 업로드 실패(page=%d, key=%s): %w", p.PageNo, key, err)
			}
		}
	}

	log.Printf("[storage] 원본 %d개 페이지 저장 완료(로컬=%s, s3=%v)", len(pages), rawDir, s.s3Enabled())
	return nil
}

// PersistItemsJSON은 전체 item을 가공 없이 모은 집계 JSON을 로컬에 저장한다(디버그용).
func (s *Storage) PersistItemsJSON(pages []RawPage) error {
	if err := os.MkdirAll(s.cfg.OutputDir, 0o755); err != nil {
		return fmt.Errorf("output 디렉터리 생성 실패: %w", err)
	}
	ts := time.Now().UTC().Format("20060102150405")

	var allItems []model.RawItem
	for _, p := range pages {
		allItems = append(allItems, p.Items...)
	}

	path := filepath.Join(s.cfg.OutputDir, fmt.Sprintf("evcharger_items_%s.json", ts))
	data, err := marshalIndent(allItems)
	if err != nil {
		return fmt.Errorf("집계 JSON 인코딩 실패: %w", err)
	}
	if err := os.WriteFile(path, data, 0o644); err != nil {
		return fmt.Errorf("집계 JSON 저장 실패: %w", err)
	}
	log.Printf("[storage] 집계 %d건 저장 완료 -> %s", len(allItems), path)
	return nil
}

// PersistErrorItems는 오류 item을 로컬+S3에 저장한다. 실패는 비치명적이라
// error를 반환하되(호출부가 경고만 남김) 파이프라인을 막지 않는다.
func (s *Storage) PersistErrorItems(ctx context.Context, items []validate.InvalidItem) error {
	if len(items) == 0 {
		return nil
	}
	errDir := filepath.Join(s.cfg.OutputDir, "errors")
	if err := os.MkdirAll(errDir, 0o755); err != nil {
		return fmt.Errorf("errors 디렉터리 생성 실패: %w", err)
	}

	ts := time.Now().UTC().Format("20060102150405")
	datePart := time.Now().UTC().Format("20060102")
	fname := fmt.Sprintf("invalid_items_%s.json", ts)

	data, err := marshalIndent(items)
	if err != nil {
		return fmt.Errorf("오류 item 인코딩 실패: %w", err)
	}

	localPath := filepath.Join(errDir, fname)
	if err := os.WriteFile(localPath, data, 0o644); err != nil {
		return fmt.Errorf("오류 item 로컬 저장 실패: %w", err)
	}

	if s.s3Enabled() {
		key := s.s3Key("errors", datePart, fname)
		if err := s.uploadWithRetry(ctx, key, data); err != nil {
			return fmt.Errorf("오류 item S3 업로드 실패(key=%s): %w", key, err)
		}
	}
	log.Printf("[storage] 오류 item %d건 저장 완료(로컬=%s, s3=%v)", len(items), localPath, s.s3Enabled())
	return nil
}

// s3Key는 prefix/category/date/name 형태의 S3 오브젝트 키를 만든다.
func (s *Storage) s3Key(category, datePart, name string) string {
	parts := make([]string, 0, 4)
	if s.cfg.S3Prefix != "" {
		parts = append(parts, s.cfg.S3Prefix)
	}
	parts = append(parts, "evcharger", category, datePart, name)
	return filepath.ToSlash(filepath.Join(parts...))
}

// uploadWithRetry는 지수 백오프로 S3 업로드를 재시도한다.
func (s *Storage) uploadWithRetry(ctx context.Context, key string, body []byte) error {
	var lastErr error
	for attempt := 0; attempt < rawUploadRetries; attempt++ {
		if attempt > 0 {
			backoff := rawBaseBackoff * time.Duration(1<<uint(attempt-1))
			log.Printf("[storage] S3 업로드 재시도 대기 %s (key=%s, attempt=%d/%d, 원인=%v)",
				backoff, key, attempt+1, rawUploadRetries, lastErr)
			time.Sleep(backoff)
		}
		if err := s.uploader.PutObject(ctx, s.cfg.S3Bucket, key, body); err != nil {
			lastErr = err
			continue
		}
		return nil
	}
	return fmt.Errorf("최대 재시도(%d회) 초과: %w", rawUploadRetries, lastErr)
}

// marshalIndent는 들여쓰기 JSON을 바이트로 만든다.
func marshalIndent(v any) ([]byte, error) {
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetIndent("", "  ")
	if err := enc.Encode(v); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// --- 실제 S3 업로더 구현 (aws-sdk-go-v2) ---

// s3Client는 S3Uploader를 구현하는 실제 aws-sdk-go-v2 래퍼다.
type s3Client struct {
	cli *s3.Client
}

// NewS3Uploader는 EC2 Instance Profile 자격증명을 자동 사용하는 S3 업로더를 만든다.
func NewS3Uploader(ctx context.Context) (S3Uploader, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, fmt.Errorf("AWS 기본 설정 로드 실패: %w", err)
	}
	return &s3Client{cli: s3.NewFromConfig(cfg)}, nil
}

// PutObject는 body를 지정 버킷/키에 업로드한다.
func (c *s3Client) PutObject(ctx context.Context, bucket, key string, body []byte) error {
	_, err := c.cli.PutObject(ctx, &s3.PutObjectInput{
		Bucket: &bucket,
		Key:    &key,
		Body:   bytes.NewReader(body),
	})
	return err
}
