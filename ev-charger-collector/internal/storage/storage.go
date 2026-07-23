// Package storage는 원본/오류/집계 데이터의 영속화를 담당한다.
//   - PersistRawPages: 원본 XML을 로컬에 항상 저장하고, S3_BUCKET이 설정된 경우
//     지수 백오프 3회 재시도로 S3에 업로드한다. 원본 보존은 CLAUDE.md 필수 규칙이라
//     S3 업로드 실패 시 파이프라인 전체를 중단시키기 위해 error를 반환한다.
//   - PersistErrorItems: 오류 item을 로컬+S3에 저장한다. 실패는 비치명적(경고만).
//   - PersistItemsJSON: 기존 집계 JSON(디버그용)을 로컬+S3에 저장한다.
//
// 세 저장 함수는 모두 "로컬 저장 → S3 업로드 → 성공 시 로컬 삭제"라는 동일한
// 패턴을 따른다(원본은 CLAUDE.md §4에 따라 S3에 보존되므로, 업로드 성공 뒤 로컬
// 사본을 지워도 원본 유실이 아니다). S3가 비활성이거나 삭제가 실패한 예외 상황을
// 대비해 SweepOldLocalFiles가 오래된 로컬 파일을 정리하는 이중 안전판을 둔다.
//
// S3 클라이언트는 aws-sdk-go-v2 config.LoadDefaultConfig로 EC2 Instance Profile
// 자격증명을 자동 사용한다(하드코딩 없음). S3Uploader 인터페이스로 추상화해
// 유닛 테스트에서 목으로 대체할 수 있게 한다.
package storage

import (
	"bytes"
	"context"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"

	"ev-charger-collector/internal/db"
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

// PersistRawPage는 한 페이지의 원본 XML을 로컬에 저장하고, S3가 활성이면 즉시 업로드한다.
// 페이지별 즉시 저장이므로, 페이지네이션 도중 프로세스가 강제 종료(SIGKILL/OOM/panic)돼도
// 이미 API로 받아온 페이지는 유실되지 않는다. S3 업로드는 지수 백오프 3회 재시도하며,
// 최종 실패 시 error를 반환한다(원본 보존은 CLAUDE.md 필수 규칙이므로 파이프라인 중단).
func (s *Storage) PersistRawPage(ctx context.Context, p RawPage) error {
	rawDir := filepath.Join(s.cfg.OutputDir, "raw")
	if err := os.MkdirAll(rawDir, 0o755); err != nil {
		return fmt.Errorf("raw 디렉터리 생성 실패: %w", err)
	}

	now := time.Now().UTC()
	ts := now.Format("20060102150405")
	datePart := now.Format("20060102")
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
		// S3에 원본이 보존됐으므로 로컬 사본을 삭제한다(디스크 무한 누적 방지).
		// 삭제 실패는 비치명적 — S3에 이미 보존됐으므로 원본 유실이 아니고,
		// 남은 로컬 파일은 SweepOldLocalFiles가 나중에 정리한다.
		if err := os.Remove(localPath); err != nil {
			log.Printf("[warn] 원본 XML 로컬 사본 삭제 실패(비치명적, path=%s): %v", localPath, err)
		}
	}
	return nil
}

// PersistRawPages는 여러 페이지를 순회하며 PersistRawPage로 각각 저장하는 얇은 래퍼다.
// 공개 API를 유지해 복구 모드 등에서 재사용할 수 있게 한다(정상 수집 경로에서는
// collectAll이 페이지별로 PersistRawPage를 직접 호출한다).
func (s *Storage) PersistRawPages(ctx context.Context, pages []RawPage) error {
	for _, p := range pages {
		if err := s.PersistRawPage(ctx, p); err != nil {
			return err
		}
	}
	log.Printf("[storage] 원본 %d개 페이지 저장 완료(로컬=%s, s3=%v)", len(pages), filepath.Join(s.cfg.OutputDir, "raw"), s.s3Enabled())
	return nil
}

// PersistItemsJSON은 전체 item을 가공 없이 모은 집계 JSON을 로컬에 저장한다(디버그용).
// 다른 두 저장 함수와 동일하게, S3가 활성이고 uploadToS3=true면 업로드 후 로컬 사본을
// 삭제한다. 복구 모드(pipeline_slow의 cfg.RecoverDate != "")에서는 이미 S3에 있던 원본을
// 되읽는 것이므로 재업로드가 중복 오브젝트를 만든다 — 그 경우 uploadToS3=false로 호출해
// 로컬 저장만 하고 삭제도 하지 않는다(복구 모드에서는 로컬 사본이 유일한 산출물).
func (s *Storage) PersistItemsJSON(ctx context.Context, pages []RawPage, uploadToS3 bool) error {
	if err := os.MkdirAll(s.cfg.OutputDir, 0o755); err != nil {
		return fmt.Errorf("output 디렉터리 생성 실패: %w", err)
	}
	now := time.Now().UTC()
	ts := now.Format("20060102150405")
	datePart := now.Format("20060102")
	fname := fmt.Sprintf("evcharger_items_%s.json", ts)

	var allItems []model.RawItem
	for _, p := range pages {
		allItems = append(allItems, p.Items...)
	}

	localPath := filepath.Join(s.cfg.OutputDir, fname)
	data, err := marshalIndent(allItems)
	if err != nil {
		return fmt.Errorf("집계 JSON 인코딩 실패: %w", err)
	}
	if err := os.WriteFile(localPath, data, 0o644); err != nil {
		return fmt.Errorf("집계 JSON 저장 실패: %w", err)
	}

	if s.s3Enabled() && uploadToS3 {
		key := s.s3Key("items", datePart, fname)
		if err := s.uploadWithRetry(ctx, key, data); err != nil {
			return fmt.Errorf("집계 JSON S3 업로드 실패(key=%s): %w", key, err)
		}
		// S3에 보존됐으므로 로컬 사본 삭제(비치명적 — 남으면 SweepOldLocalFiles가 정리).
		if err := os.Remove(localPath); err != nil {
			log.Printf("[warn] 집계 JSON 로컬 사본 삭제 실패(비치명적, path=%s): %v", localPath, err)
		}
	}
	log.Printf("[storage] 집계 %d건 저장 완료(로컬=%s, s3=%v)", len(allItems), localPath, s.s3Enabled() && uploadToS3)
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
		// S3에 보존됐으므로 로컬 사본 삭제(비치명적 — 남으면 SweepOldLocalFiles가 정리).
		if err := os.Remove(localPath); err != nil {
			log.Printf("[warn] 오류 item 로컬 사본 삭제 실패(비치명적, path=%s): %v", localPath, err)
		}
	}
	log.Printf("[storage] 오류 item %d건 저장 완료(로컬=%s, s3=%v)", len(items), localPath, s.s3Enabled())
	return nil
}

// DefaultRetentionMaxAge는 SweepOldLocalFiles가 정리 대상으로 삼는 로컬 파일의 기본
// 보존 기간이다(7일). 정상 운영(S3 활성)에서는 업로드 성공 즉시 로컬 사본이 지워지므로
// 이 스윕이 실제로 지울 대상은 거의 없어야 정상이다 — 이는 S3 미설정 dev 환경이나
// os.Remove 자체가 실패한 예외 케이스를 위한 이중 안전판이다.
const DefaultRetentionMaxAge = 7 * 24 * time.Hour

// sweepTarget은 SweepOldLocalFiles가 훑는 (디렉터리, 파일명 접두사, 접미사) 쌍이다.
// 이 패키지가 직접 만드는 파일 패턴만 나열한다 — main 패키지 소유의
// collector_checkpoint_*.json 등 다른 파일은 접두/접미 매칭에서 자연히 제외돼
// 절대 삭제되지 않는다.
type sweepTarget struct {
	dir    string
	prefix string
	suffix string
}

// SweepOldLocalFiles는 이 패키지가 만든 로컬 산출물 중 mtime이 maxAge보다 오래된 것만
// 삭제하고 삭제한 개수를 반환한다. 대상은 OutputDir 최상위의 evcharger_items_*.json,
// raw/의 evcharger_page*.xml, errors/의 invalid_items_*.json 뿐이다. 이 패키지가 만들지
// 않는 파일(체크포인트 등)은 접두/접미 패턴 불일치로 건드리지 않는다. 디렉터리가 아직
// 없으면 조용히 건너뛴다(에러/패닉 없음). 개별 파일 삭제 실패는 비치명적 로그만 남긴다.
func (s *Storage) SweepOldLocalFiles(maxAge time.Duration) int {
	targets := []sweepTarget{
		{dir: s.cfg.OutputDir, prefix: "evcharger_items_", suffix: ".json"},
		{dir: filepath.Join(s.cfg.OutputDir, "raw"), prefix: "evcharger_page", suffix: ".xml"},
		{dir: filepath.Join(s.cfg.OutputDir, "errors"), prefix: "invalid_items_", suffix: ".json"},
	}
	cutoff := time.Now().Add(-maxAge)
	removed := 0
	for _, tgt := range targets {
		entries, err := os.ReadDir(tgt.dir)
		if err != nil {
			// 디렉터리가 아직 없거나(한 번도 안 쓴 output) 읽을 수 없으면 조용히 건너뛴다.
			continue
		}
		for _, e := range entries {
			if e.IsDir() {
				continue
			}
			name := e.Name()
			// 이 패키지가 만든 파일 패턴만 대상 — 그 외 파일은 절대 건드리지 않는다.
			if !strings.HasPrefix(name, tgt.prefix) || !strings.HasSuffix(name, tgt.suffix) {
				continue
			}
			info, err := e.Info()
			if err != nil {
				continue
			}
			if info.ModTime().After(cutoff) {
				continue // 아직 보존 기간 내 — 유지.
			}
			path := filepath.Join(tgt.dir, name)
			if err := os.Remove(path); err != nil {
				log.Printf("[warn] 오래된 로컬 파일 삭제 실패(비치명적, path=%s): %v", path, err)
				continue
			}
			removed++
		}
	}
	if removed > 0 {
		log.Printf("[storage] 레트리션 스윕: %d일 경과 로컬 파일 %d개 정리", int(maxAge.Hours()/24), removed)
	}
	return removed
}

// PersistHistoryArchiveBatch는 아카이브 대상 charger_status_history 배치 하나를 JSON으로
// S3에 업로드한다(콜드 아카이브 전용 — S3_BUCKET 미설정이면 아카이브 자체가 무의미하므로
// 에러를 반환한다). 업로드 실패 시 error를 반환하며, 호출측(archive.go)은 이 배치의
// RDS DELETE를 수행하지 않고 중단해야 한다(원본 보존 성공 후에만 다음 단계로 가는
// 기존 PersistRawPage 원칙과 동일).
func (s *Storage) PersistHistoryArchiveBatch(ctx context.Context, rows []db.ArchivableHistoryRow, runDate time.Time, batchSeq int) error {
	if len(rows) == 0 {
		return nil
	}
	if !s.s3Enabled() {
		return fmt.Errorf("아카이브에는 S3_BUCKET 설정이 필수입니다(콜드 아카이브 목적)")
	}

	data, err := marshalIndent(rows)
	if err != nil {
		return fmt.Errorf("아카이브 배치 인코딩 실패: %w", err)
	}

	key := s.archiveKey(runDate.UTC().Format("20060102"), batchSeq)
	if err := s.uploadWithRetry(ctx, key, data); err != nil {
		return fmt.Errorf("아카이브 배치 S3 업로드 실패(key=%s): %w", key, err)
	}
	log.Printf("[storage] 아카이브 배치 업로드 완료: %d건 -> %s", len(rows), key)
	return nil
}

// archiveKey는 아카이브 배치의 S3 키를 만든다:
// <prefix?>/evcharger/archive/charger_status_history/<YYYYMMDD>/batch_<seq>_<ts>.json
// (날짜는 아카이브 실행일 기준 파티션이다 — 원본 이력의 collected_at이 아니다.)
func (s *Storage) archiveKey(datePart string, batchSeq int) string {
	ts := time.Now().UTC().Format("20060102150405")
	parts := make([]string, 0, 5)
	if s.cfg.S3Prefix != "" {
		parts = append(parts, s.cfg.S3Prefix)
	}
	parts = append(parts, "evcharger", "archive", "charger_status_history", datePart,
		fmt.Sprintf("batch_%d_%s.json", batchSeq, ts))
	return filepath.ToSlash(filepath.Join(parts...))
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

// --- 수동 S3 복구(읽기 전용) ---

// S3Downloader는 복구 모드에서 S3에 보존된 원본 XML을 되읽는 읽기 전용 인터페이스다.
// (업로드용 S3Uploader와 분리해, 복구 경로가 쓰기 권한 없이도 동작하도록 추상화한다.)
type S3Downloader interface {
	// ListObjects는 prefix로 시작하는 모든 객체 키를 반환한다.
	ListObjects(ctx context.Context, bucket, prefix string) ([]string, error)
	// GetObject는 지정 키의 객체 본문을 바이트로 반환한다.
	GetObject(ctx context.Context, bucket, key string) ([]byte, error)
}

// NewS3Downloader는 EC2 Instance Profile 자격증명을 자동 사용하는 읽기 전용 S3 다운로더를
// 만든다(기존 NewS3Uploader와 별개, 같은 s3Client 타입을 재사용).
func NewS3Downloader(ctx context.Context) (S3Downloader, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, fmt.Errorf("AWS 기본 설정 로드 실패: %w", err)
	}
	return &s3Client{cli: s3.NewFromConfig(cfg)}, nil
}

// ListObjects는 ListObjectsV2Paginator로 prefix 하위 모든 객체 키를 나열한다.
func (c *s3Client) ListObjects(ctx context.Context, bucket, prefix string) ([]string, error) {
	paginator := s3.NewListObjectsV2Paginator(c.cli, &s3.ListObjectsV2Input{
		Bucket: &bucket,
		Prefix: &prefix,
	})
	var keys []string
	for paginator.HasMorePages() {
		page, err := paginator.NextPage(ctx)
		if err != nil {
			return nil, fmt.Errorf("S3 객체 나열 실패(prefix=%s): %w", prefix, err)
		}
		for _, obj := range page.Contents {
			if obj.Key != nil {
				keys = append(keys, *obj.Key)
			}
		}
	}
	return keys, nil
}

// GetObject는 지정 키의 객체 본문을 끝까지 읽어 바이트로 반환한다.
func (c *s3Client) GetObject(ctx context.Context, bucket, key string) ([]byte, error) {
	out, err := c.cli.GetObject(ctx, &s3.GetObjectInput{
		Bucket: &bucket,
		Key:    &key,
	})
	if err != nil {
		return nil, fmt.Errorf("S3 객체 다운로드 실패(key=%s): %w", key, err)
	}
	defer out.Body.Close()
	data, err := io.ReadAll(out.Body)
	if err != nil {
		return nil, fmt.Errorf("S3 객체 본문 읽기 실패(key=%s): %w", key, err)
	}
	return data, nil
}

// pageFileRe는 원본 파일명에서 페이지 번호를 뽑기 위한 정규식이다(evcharger_page{N}_{ts}.xml).
var pageFileRe = regexp.MustCompile(`evcharger_page(\d+)_`)

// RecoverRawPages는 S3에 보존된 특정 날짜의 원본 XML을 되읽어 RawPage 목록으로 복원한다.
// API를 호출하지 않고 저장된 원본만으로 파이프라인(검증→정규화→DB적재)을 다시 태우기 위한
// 수동 복구 경로다. zcode가 지정되면 item 단위로 필터링한다 — S3 키 구조에 zcode가 없고
// 전국 수집 시 한 페이지에 여러 zcode가 섞일 수 있으므로 페이지 단위가 아닌 item 단위 필터가
// 맞다. RawXML은 원본 그대로 보존하고 Items만 필터링한다. 파일명의 페이지 번호로 정렬하되,
// 이는 로그 가독성 목적일 뿐 정합성엔 필수가 아니다(station upsert가 자연키 기준 멱등적이라
// 순서가 뒤바뀌거나 중복 로드돼도 안전하다).
func (s *Storage) RecoverRawPages(ctx context.Context, downloader S3Downloader, bucket, zcode, date string) ([]RawPage, error) {
	// s3Key의 name을 비워 해당 날짜 raw 디렉터리 전체를 프리픽스로 만든다.
	prefix := s.s3Key("raw", date, "")
	keys, err := downloader.ListObjects(ctx, bucket, prefix)
	if err != nil {
		return nil, err
	}
	if len(keys) == 0 {
		return nil, fmt.Errorf("복구 대상 원본 없음(bucket=%s, prefix=%s)", bucket, prefix)
	}

	// 파일명의 페이지 번호 기준 오름차순 정렬(가독성용).
	sort.Slice(keys, func(i, j int) bool {
		return pageNoFromKey(keys[i]) < pageNoFromKey(keys[j])
	})

	var pages []RawPage
	for _, key := range keys {
		data, err := downloader.GetObject(ctx, bucket, key)
		if err != nil {
			return nil, err
		}
		var resp model.Response
		if err := xml.Unmarshal(data, &resp); err != nil {
			log.Printf("[storage] 복구 중 XML 파싱 실패 — 건너뜀(key=%s): %v", key, err)
			continue
		}
		items := resp.Body.Items.Item
		if zcode != "" {
			items = filterByZcode(items, zcode)
		}
		if len(items) == 0 {
			continue
		}
		pages = append(pages, RawPage{
			PageNo: pageNoFromKey(key),
			RawXML: data,
			Items:  items,
		})
	}
	log.Printf("[storage] S3 복구 완료: %d개 원본에서 %d페이지 복원(zcode=%q, prefix=%s)", len(keys), len(pages), zcode, prefix)
	return pages, nil
}

// pageNoFromKey는 S3 키(파일명)에서 페이지 번호를 추출한다. 추출 실패 시 0을 반환한다.
func pageNoFromKey(key string) int {
	m := pageFileRe.FindStringSubmatch(key)
	if len(m) < 2 {
		return 0
	}
	n, err := strconv.Atoi(m[1])
	if err != nil {
		return 0
	}
	return n
}

// filterByZcode는 item 목록에서 지정 zcode(시도코드)에 해당하는 것만 남긴다.
func filterByZcode(items []model.RawItem, zcode string) []model.RawItem {
	var filtered []model.RawItem
	for _, it := range items {
		if it.Zcode == zcode {
			filtered = append(filtered, it)
		}
	}
	return filtered
}
