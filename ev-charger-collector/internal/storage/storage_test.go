package storage

import (
	"context"
	"encoding/json"
	"strings"
	"testing"
	"time"

	"ev-charger-collector/internal/db"
)

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
