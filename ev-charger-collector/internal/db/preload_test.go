package db

import (
	"context"
	"testing"

	sqlmock "github.com/DATA-DOG/go-sqlmock"
)

func TestPreloadStationChargerMap(t *testing.T) {
	mockDB, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock 생성 실패: %v", err)
	}
	defer mockDB.Close()

	rows := sqlmock.NewRows([]string{"source_station_id", "station_id", "external_charger_id", "charger_id"}).
		AddRow("ST0001", int64(1), "ST0001#1", int64(10)).
		AddRow("ST0001", int64(1), "ST0001#2", int64(11)).
		// charger가 없는 station(LEFT JOIN NULL) 케이스.
		AddRow("ST0002", int64(2), nil, nil)

	mock.ExpectQuery(`SELECT sl\.source_station_id, s\.station_id, c\.external_charger_id, c\.charger_id`).
		WithArgs(int64(42)).
		WillReturnRows(rows)

	d := NewFromSQL(mockDB)
	m, err := d.PreloadStationChargerMap(context.Background(), 42)
	if err != nil {
		t.Fatalf("PreloadStationChargerMap 실패: %v", err)
	}

	if id, ok := m.StationID("ST0001"); !ok || id != 1 {
		t.Fatalf("ST0001 station_id 매핑 불일치: id=%d ok=%v", id, ok)
	}
	if id, ok := m.StationID("ST0002"); !ok || id != 2 {
		t.Fatalf("ST0002 station_id 매핑 불일치: id=%d ok=%v", id, ok)
	}
	if _, ok := m.StationID("ST9999"); ok {
		t.Fatalf("존재하지 않는 station이 매핑에 있음(신규 station 오판)")
	}

	if id, ok := m.ChargerID(1, "ST0001#1"); !ok || id != 10 {
		t.Fatalf("charger 매핑 불일치: id=%d ok=%v", id, ok)
	}
	if id, ok := m.ChargerID(1, "ST0001#2"); !ok || id != 11 {
		t.Fatalf("charger 매핑 불일치: id=%d ok=%v", id, ok)
	}
	// station 2는 charger가 없으므로(NULL) charger 매핑에 없어야 한다.
	if _, ok := m.ChargerID(2, ""); ok {
		t.Fatalf("charger가 없는 station인데 매핑이 존재함")
	}

	if m.StationCount() != 2 {
		t.Fatalf("StationCount 불일치: %d", m.StationCount())
	}
	if m.ChargerCount() != 2 {
		t.Fatalf("ChargerCount 불일치: %d", m.ChargerCount())
	}

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("sqlmock 기대 불일치: %v", err)
	}
}

func TestPreloadStationChargerMap_QueryError(t *testing.T) {
	mockDB, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock 생성 실패: %v", err)
	}
	defer mockDB.Close()

	mock.ExpectQuery(`SELECT sl\.source_station_id`).
		WithArgs(int64(1)).
		WillReturnError(context.DeadlineExceeded)

	d := NewFromSQL(mockDB)
	if _, err := d.PreloadStationChargerMap(context.Background(), 1); err == nil {
		t.Fatalf("쿼리 실패 시 에러가 반환돼야 함(폴백 없음이 설계 의도)")
	}
}
