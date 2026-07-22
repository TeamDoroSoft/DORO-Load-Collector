package db

import (
	"context"
	"testing"
	"time"

	sqlmock "github.com/DATA-DOG/go-sqlmock"
)

func TestSelectOldStatusHistory(t *testing.T) {
	mockDB, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock 생성 실패: %v", err)
	}
	defer mockDB.Close()

	cutoff := time.Date(2026, 4, 1, 0, 0, 0, 0, time.UTC)
	srcUpd := time.Date(2026, 3, 1, 10, 0, 0, 0, time.UTC)
	collected := time.Date(2026, 3, 1, 10, 5, 0, 0, time.UTC)

	rows := sqlmock.NewRows([]string{
		"status_id", "charger_id", "external_charger_id", "station_id",
		"source_station_id", "status", "source_updated_at", "collected_at",
	}).
		AddRow(int64(100), int64(10), "ST0001#1", int64(1), "ST0001", "AVAILABLE", srcUpd, collected).
		AddRow(int64(101), int64(10), "ST0001#1", int64(1), "ST0001", "CHARGING", nil, nil)

	mock.ExpectQuery(`SELECT h\.status_id, h\.charger_id, c\.external_charger_id, c\.station_id`).
		WithArgs(cutoff, 500).
		WillReturnRows(rows)

	d := NewFromSQL(mockDB)
	got, err := d.SelectOldStatusHistory(context.Background(), cutoff, 500)
	if err != nil {
		t.Fatalf("SelectOldStatusHistory 실패: %v", err)
	}
	if len(got) != 2 {
		t.Fatalf("행 개수 불일치: %d", len(got))
	}
	if got[0].StatusID != 100 || got[0].SourceUpdatedAt == nil || !got[0].SourceUpdatedAt.Equal(srcUpd) {
		t.Fatalf("첫 행 불일치: %+v", got[0])
	}
	if got[1].SourceUpdatedAt != nil || got[1].CollectedAt != nil {
		t.Fatalf("NULL 시간 필드가 nil 포인터로 처리되지 않음: %+v", got[1])
	}

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("sqlmock 기대 불일치: %v", err)
	}
}

func TestDeleteStatusHistoryByIDs(t *testing.T) {
	mockDB, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock 생성 실패: %v", err)
	}
	defer mockDB.Close()

	mock.ExpectExec(`DELETE FROM charger_status_history WHERE status_id IN \(\?,\?,\?\)`).
		WithArgs(int64(1), int64(2), int64(3)).
		WillReturnResult(sqlmock.NewResult(0, 3))

	d := NewFromSQL(mockDB)
	n, err := d.DeleteStatusHistoryByIDs(context.Background(), []int64{1, 2, 3})
	if err != nil {
		t.Fatalf("DeleteStatusHistoryByIDs 실패: %v", err)
	}
	if n != 3 {
		t.Fatalf("삭제 건수 불일치: %d", n)
	}

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("sqlmock 기대 불일치: %v", err)
	}
}

func TestDeleteStatusHistoryByIDs_Empty(t *testing.T) {
	mockDB, _, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock 생성 실패: %v", err)
	}
	defer mockDB.Close()

	d := NewFromSQL(mockDB)
	n, err := d.DeleteStatusHistoryByIDs(context.Background(), nil)
	if err != nil {
		t.Fatalf("빈 목록은 에러 없이 0 반환해야 함: %v", err)
	}
	if n != 0 {
		t.Fatalf("빈 목록인데 삭제 건수가 0이 아님: %d", n)
	}
}
