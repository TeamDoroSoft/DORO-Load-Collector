package storage

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"ev-charger-collector/internal/db"
	"ev-charger-collector/internal/model"
	"ev-charger-collector/internal/validate"
)

// countFiles는 dir에서 prefix로 시작하고 suffix로 끝나는 파일 개수를 센다.
// 디렉터리가 없으면 0을 반환한다(테스트 편의용).
func countFiles(t *testing.T, dir, prefix, suffix string) int {
	t.Helper()
	entries, err := os.ReadDir(dir)
	if err != nil {
		return 0
	}
	n := 0
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if strings.HasPrefix(name, prefix) && strings.HasSuffix(name, suffix) {
			n++
		}
	}
	return n
}

func sampleRawPage() RawPage {
	return RawPage{
		PageNo: 1,
		RawXML: []byte(`<response><body><items></items></body></response>`),
		Items:  []model.RawItem{{Zcode: "11"}},
	}
}

// --- PersistRawPage: 업로드 성공 시 로컬 삭제 / 비활성·실패 시 로컬 보존 ---

func TestPersistRawPage_UploadSuccessRemovesLocal(t *testing.T) {
	up := &mockUploader{}
	dir := t.TempDir()
	s := New(Config{OutputDir: dir, S3Bucket: "test-bucket"}, up)

	if err := s.PersistRawPage(context.Background(), sampleRawPage()); err != nil {
		t.Fatalf("PersistRawPage 실패: %v", err)
	}
	if len(up.calls) != 1 {
		t.Fatalf("업로드 호출 횟수 불일치: %d", len(up.calls))
	}
	if got := countFiles(t, filepath.Join(dir, "raw"), "evcharger_page", ".xml"); got != 0 {
		t.Fatalf("업로드 성공 후 로컬 원본이 남아 있음: %d개", got)
	}
}

func TestPersistRawPage_S3DisabledKeepsLocal(t *testing.T) {
	dir := t.TempDir()
	s := New(Config{OutputDir: dir}, nil) // S3 비활성

	if err := s.PersistRawPage(context.Background(), sampleRawPage()); err != nil {
		t.Fatalf("PersistRawPage 실패: %v", err)
	}
	if got := countFiles(t, filepath.Join(dir, "raw"), "evcharger_page", ".xml"); got != 1 {
		t.Fatalf("S3 비활성인데 로컬 원본이 보존되지 않음: %d개", got)
	}
}

func TestPersistRawPage_UploadFailureKeepsLocal(t *testing.T) {
	up := &mockUploader{failNext: 10, putErr: errUploadFailed}
	dir := t.TempDir()
	s := New(Config{OutputDir: dir, S3Bucket: "test-bucket"}, up)

	if err := s.PersistRawPage(context.Background(), sampleRawPage()); err == nil {
		t.Fatalf("업로드 실패인데 에러 없이 성공 처리됨")
	}
	if got := countFiles(t, filepath.Join(dir, "raw"), "evcharger_page", ".xml"); got != 1 {
		t.Fatalf("업로드 실패인데 로컬 원본이 삭제됨(원본 유실 회귀): %d개", got)
	}
}

// --- PersistErrorItems: 업로드 성공 시 로컬 삭제 / 비활성·실패 시 로컬 보존 ---

func sampleInvalid() []validate.InvalidItem {
	return []validate.InvalidItem{{Item: model.RawItem{Zcode: "11"}, Reason: "TEST", Detail: "모의 오류"}}
}

func TestPersistErrorItems_UploadSuccessRemovesLocal(t *testing.T) {
	up := &mockUploader{}
	dir := t.TempDir()
	s := New(Config{OutputDir: dir, S3Bucket: "test-bucket"}, up)

	if err := s.PersistErrorItems(context.Background(), sampleInvalid()); err != nil {
		t.Fatalf("PersistErrorItems 실패: %v", err)
	}
	if len(up.calls) != 1 {
		t.Fatalf("업로드 호출 횟수 불일치: %d", len(up.calls))
	}
	if got := countFiles(t, filepath.Join(dir, "errors"), "invalid_items_", ".json"); got != 0 {
		t.Fatalf("업로드 성공 후 로컬 오류 파일이 남아 있음: %d개", got)
	}
}

func TestPersistErrorItems_S3DisabledKeepsLocal(t *testing.T) {
	dir := t.TempDir()
	s := New(Config{OutputDir: dir}, nil)

	if err := s.PersistErrorItems(context.Background(), sampleInvalid()); err != nil {
		t.Fatalf("PersistErrorItems 실패: %v", err)
	}
	if got := countFiles(t, filepath.Join(dir, "errors"), "invalid_items_", ".json"); got != 1 {
		t.Fatalf("S3 비활성인데 로컬 오류 파일이 보존되지 않음: %d개", got)
	}
}

func TestPersistErrorItems_UploadFailureKeepsLocal(t *testing.T) {
	up := &mockUploader{failNext: 10, putErr: errUploadFailed}
	dir := t.TempDir()
	s := New(Config{OutputDir: dir, S3Bucket: "test-bucket"}, up)

	if err := s.PersistErrorItems(context.Background(), sampleInvalid()); err == nil {
		t.Fatalf("업로드 실패인데 에러 없이 성공 처리됨")
	}
	if got := countFiles(t, filepath.Join(dir, "errors"), "invalid_items_", ".json"); got != 1 {
		t.Fatalf("업로드 실패인데 로컬 오류 파일이 삭제됨(원본 유실 회귀): %d개", got)
	}
}

// --- PersistItemsJSON: 업로드 성공 삭제 / 비활성·실패 보존 / uploadToS3=false 회귀 ---

func TestPersistItemsJSON_UploadSuccessRemovesLocal(t *testing.T) {
	up := &mockUploader{}
	dir := t.TempDir()
	s := New(Config{OutputDir: dir, S3Bucket: "test-bucket"}, up)

	if err := s.PersistItemsJSON(context.Background(), []RawPage{sampleRawPage()}, true); err != nil {
		t.Fatalf("PersistItemsJSON 실패: %v", err)
	}
	if len(up.calls) != 1 {
		t.Fatalf("업로드 호출 횟수 불일치: %d", len(up.calls))
	}
	if !strings.Contains(up.calls[0].key, "/items/") {
		t.Fatalf("집계 JSON S3 키에 items 카테고리가 없음: %s", up.calls[0].key)
	}
	if got := countFiles(t, dir, "evcharger_items_", ".json"); got != 0 {
		t.Fatalf("업로드 성공 후 로컬 집계 파일이 남아 있음: %d개", got)
	}
}

func TestPersistItemsJSON_S3DisabledKeepsLocal(t *testing.T) {
	dir := t.TempDir()
	s := New(Config{OutputDir: dir}, nil)

	if err := s.PersistItemsJSON(context.Background(), []RawPage{sampleRawPage()}, true); err != nil {
		t.Fatalf("PersistItemsJSON 실패: %v", err)
	}
	if got := countFiles(t, dir, "evcharger_items_", ".json"); got != 1 {
		t.Fatalf("S3 비활성인데 로컬 집계 파일이 보존되지 않음: %d개", got)
	}
}

func TestPersistItemsJSON_UploadFailureKeepsLocal(t *testing.T) {
	up := &mockUploader{failNext: 10, putErr: errUploadFailed}
	dir := t.TempDir()
	s := New(Config{OutputDir: dir, S3Bucket: "test-bucket"}, up)

	if err := s.PersistItemsJSON(context.Background(), []RawPage{sampleRawPage()}, true); err == nil {
		t.Fatalf("업로드 실패인데 에러 없이 성공 처리됨")
	}
	if got := countFiles(t, dir, "evcharger_items_", ".json"); got != 1 {
		t.Fatalf("업로드 실패인데 로컬 집계 파일이 삭제됨(원본 유실 회귀): %d개", got)
	}
}

// 복구 모드 시뮬레이션: S3가 활성이어도 uploadToS3=false면 업로드 자체를 하지 않고
// 로컬 사본도 유지해야 한다(복구는 이미 S3에 있던 원본을 되읽는 것이라 재업로드하면
// 중복 오브젝트가 생기고, 복구 모드에서 로컬 사본은 유일한 산출물이므로).
func TestPersistItemsJSON_NoUploadKeepsLocalAndSkipsS3(t *testing.T) {
	up := &mockUploader{}
	dir := t.TempDir()
	s := New(Config{OutputDir: dir, S3Bucket: "test-bucket"}, up)

	if err := s.PersistItemsJSON(context.Background(), []RawPage{sampleRawPage()}, false); err != nil {
		t.Fatalf("PersistItemsJSON 실패: %v", err)
	}
	if len(up.calls) != 0 {
		t.Fatalf("uploadToS3=false인데 S3 업로드가 발생함: %d건", len(up.calls))
	}
	if got := countFiles(t, dir, "evcharger_items_", ".json"); got != 1 {
		t.Fatalf("uploadToS3=false인데 로컬 집계 파일이 보존되지 않음: %d개", got)
	}
}

// --- SweepOldLocalFiles ---

func TestSweepOldLocalFiles(t *testing.T) {
	dir := t.TempDir()
	s := New(Config{OutputDir: dir}, nil)

	rawDir := filepath.Join(dir, "raw")
	errDir := filepath.Join(dir, "errors")
	for _, d := range []string{rawDir, errDir} {
		if err := os.MkdirAll(d, 0o755); err != nil {
			t.Fatalf("디렉터리 생성 실패: %v", err)
		}
	}

	old := time.Now().Add(-10 * 24 * time.Hour) // 10일 전 → 삭제 대상
	recent := time.Now().Add(-1 * time.Hour)    // 1시간 전 → 유지

	// 삭제돼야 할 오래된 파일들(이 패키지가 만드는 패턴).
	oldItems := filepath.Join(dir, "evcharger_items_20260101000000.json")
	oldRaw := filepath.Join(rawDir, "evcharger_page1_20260101000000.xml")
	oldErr := filepath.Join(errDir, "invalid_items_20260101000000.json")
	// 유지돼야 할 최근 파일.
	recentItems := filepath.Join(dir, "evcharger_items_20260722000000.json")
	// 절대 건드리면 안 되는, 이 패키지가 안 만드는 오래된 파일(체크포인트).
	checkpoint := filepath.Join(dir, "collector_checkpoint_slow.json")

	write := func(path string, mtime time.Time) {
		if err := os.WriteFile(path, []byte("x"), 0o644); err != nil {
			t.Fatalf("파일 생성 실패(%s): %v", path, err)
		}
		if err := os.Chtimes(path, mtime, mtime); err != nil {
			t.Fatalf("mtime 설정 실패(%s): %v", path, err)
		}
	}
	write(oldItems, old)
	write(oldRaw, old)
	write(oldErr, old)
	write(recentItems, recent)
	write(checkpoint, old) // 오래됐지만 패턴 불일치라 삭제되면 안 됨

	removed := s.SweepOldLocalFiles(DefaultRetentionMaxAge)
	if removed != 3 {
		t.Fatalf("삭제된 파일 수 불일치: got=%d want=3", removed)
	}

	// 오래된 대상 파일은 삭제됐어야 함.
	for _, p := range []string{oldItems, oldRaw, oldErr} {
		if _, err := os.Stat(p); !os.IsNotExist(err) {
			t.Fatalf("오래된 대상 파일이 삭제되지 않음: %s", p)
		}
	}
	// 최근 파일과 체크포인트는 유지돼야 함.
	for _, p := range []string{recentItems, checkpoint} {
		if _, err := os.Stat(p); err != nil {
			t.Fatalf("삭제되면 안 되는 파일이 사라짐: %s (%v)", p, err)
		}
	}
}

// raw·errors 디렉터리가 아예 없어도 에러·패닉 없이 0을 반환해야 한다.
func TestSweepOldLocalFiles_MissingDirs(t *testing.T) {
	dir := t.TempDir() // raw/, errors/ 없음
	s := New(Config{OutputDir: dir}, nil)

	if removed := s.SweepOldLocalFiles(DefaultRetentionMaxAge); removed != 0 {
		t.Fatalf("빈 output에서 삭제 대상이 있으면 안 됨: got=%d", removed)
	}
}

// mockUploader는 PutObject 호출을 기록하는 테스트용 S3Uploader다.
type mockUploader struct {
	calls    []mockPut
	failNext int // 0보다 크면 다음 N번 호출을 실패시킨다(재시도 검증용).
	putErr   error
}

type mockPut struct {
	bucket string
	key    string
	body   []byte
}

func (m *mockUploader) PutObject(_ context.Context, bucket, key string, body []byte) error {
	if m.failNext > 0 {
		m.failNext--
		return m.putErr
	}
	cp := make([]byte, len(body))
	copy(cp, body)
	m.calls = append(m.calls, mockPut{bucket: bucket, key: key, body: cp})
	return nil
}

func TestPersistHistoryArchiveBatch_Success(t *testing.T) {
	up := &mockUploader{}
	s := New(Config{OutputDir: t.TempDir(), S3Bucket: "test-bucket", S3Prefix: ""}, up)

	rows := []db.ArchivableHistoryRow{
		{StatusID: 1, ChargerID: 10, ExternalChargerID: "ST0001#1", StationID: 1, SourceStationID: "ST0001", Status: "AVAILABLE"},
	}
	runDate := time.Date(2026, 7, 22, 0, 0, 0, 0, time.UTC)

	if err := s.PersistHistoryArchiveBatch(context.Background(), rows, runDate, 3); err != nil {
		t.Fatalf("PersistHistoryArchiveBatch 실패: %v", err)
	}

	if len(up.calls) != 1 {
		t.Fatalf("업로드 호출 횟수 불일치: %d", len(up.calls))
	}
	call := up.calls[0]
	if call.bucket != "test-bucket" {
		t.Fatalf("버킷 불일치: %s", call.bucket)
	}
	wantPrefix := "evcharger/archive/charger_status_history/20260722/batch_3_"
	if !strings.HasPrefix(call.key, wantPrefix) {
		t.Fatalf("키 패턴 불일치: %s (기대 접두사: %s)", call.key, wantPrefix)
	}

	var decoded []db.ArchivableHistoryRow
	if err := json.Unmarshal(call.body, &decoded); err != nil {
		t.Fatalf("업로드 본문이 유효한 JSON이 아님: %v", err)
	}
	if len(decoded) != 1 || decoded[0].StatusID != 1 {
		t.Fatalf("업로드 본문 내용 불일치: %+v", decoded)
	}
}

func TestPersistHistoryArchiveBatch_EmptyRowsNoUpload(t *testing.T) {
	up := &mockUploader{}
	s := New(Config{OutputDir: t.TempDir(), S3Bucket: "test-bucket"}, up)

	if err := s.PersistHistoryArchiveBatch(context.Background(), nil, time.Now(), 1); err != nil {
		t.Fatalf("빈 배치는 에러 없이 무시돼야 함: %v", err)
	}
	if len(up.calls) != 0 {
		t.Fatalf("빈 배치인데 업로드가 발생함: %d건", len(up.calls))
	}
}

func TestPersistHistoryArchiveBatch_NoS3ConfiguredReturnsError(t *testing.T) {
	// uploader가 nil이거나 S3Bucket이 비어 있으면 s3Enabled()==false이고, 아카이브는
	// S3 없이는 무의미하므로 에러를 반환해야 한다(원본 collectAll의 "S3 미설정 시 로컬만"
	// 완화와 달리, 아카이브는 S3가 유일한 목적지라 완화가 없다).
	s := New(Config{OutputDir: t.TempDir()}, nil)

	rows := []db.ArchivableHistoryRow{{StatusID: 1}}
	if err := s.PersistHistoryArchiveBatch(context.Background(), rows, time.Now(), 1); err == nil {
		t.Fatalf("S3 미설정인데 에러 없이 성공 처리됨")
	}
}

func TestPersistHistoryArchiveBatch_UploadFailure(t *testing.T) {
	up := &mockUploader{failNext: 10, putErr: errUploadFailed}
	s := New(Config{OutputDir: t.TempDir(), S3Bucket: "test-bucket"}, up)

	rows := []db.ArchivableHistoryRow{{StatusID: 1}}
	if err := s.PersistHistoryArchiveBatch(context.Background(), rows, time.Now(), 1); err == nil {
		t.Fatalf("업로드 실패인데 에러 없이 성공 처리됨(호출측이 DELETE를 막을 신호가 없음)")
	}
}

var errUploadFailed = &staticErr{"업로드 실패(모의)"}

type staticErr struct{ msg string }

func (e *staticErr) Error() string { return e.msg }
