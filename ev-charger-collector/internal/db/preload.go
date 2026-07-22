// preload.go는 fast path 전용 프리로드 함수를 담는다. db.go(slow path 메인 적재 로직)
// 비대화를 막기 위해 별도 파일로 분리했다.
package db

import (
	"context"
	"database/sql"
	"fmt"
)

// StationChargerMap은 fast path가 RDS에 쓰지 않고 조회만으로 station_id/charger_id를
// 해석할 수 있게 하는 in-memory 매핑이다. PreloadStationChargerMap으로 한 번에
// 채워지며, 이후 station/charger는 순수 map 조회로만 해석된다(N+1 없음).
type StationChargerMap struct {
	// stationIDs는 source_station_id(statId) → station_id.
	stationIDs map[string]int64
	// chargerIDs는 "station_id:external_charger_id" → charger_id.
	chargerIDs map[string]int64
}

func newStationChargerMap() *StationChargerMap {
	return &StationChargerMap{
		stationIDs: make(map[string]int64),
		chargerIDs: make(map[string]int64),
	}
}

func chargerMapKey(stationID int64, externalChargerID string) string {
	return fmt.Sprintf("%d:%s", stationID, externalChargerID)
}

// StationID는 source_station_id로 매핑된 station_id를 조회한다. ok=false면
// RDS에 아직 없는 신규 station이라는 뜻이다(fast path는 이 경우 스킵한다).
func (m *StationChargerMap) StationID(sourceStationID string) (int64, bool) {
	id, ok := m.stationIDs[sourceStationID]
	return id, ok
}

// ChargerID는 (station_id, external_charger_id)로 매핑된 charger_id를 조회한다.
// ok=false면 기존 station 하위의 신규 charger라는 뜻이다(fast path는 이 경우 그
// charger만 스킵하고 나머지는 계속 처리한다).
func (m *StationChargerMap) ChargerID(stationID int64, externalChargerID string) (int64, bool) {
	id, ok := m.chargerIDs[chargerMapKey(stationID, externalChargerID)]
	return id, ok
}

// StationCount/ChargerCount는 프리로드 완료 로그용 건수다.
func (m *StationChargerMap) StationCount() int { return len(m.stationIDs) }
func (m *StationChargerMap) ChargerCount() int { return len(m.chargerIDs) }

// PreloadStationChargerMap은 station_source_link + station + charger를 LEFT JOIN
// 한 번으로 읽어 source_station_id→station_id, (station_id, external_charger_id)→
// charger_id 매핑을 메모리로 로드한다.
//
// PreloadOperatorNetworkMap과 달리 실패 시 폴백(개별 SELECT) 없이 그대로 에러를
// 반환한다 — fast path는 이 매핑이 불완전하면 "신규 station"과 "프리로드 실패로
// 못 찾은 기존 station"을 구분할 수 없어 잘못된 스킵(캐시 미갱신)을 할 위험이
// 있으므로, 실패 시 호출측(runFast)이 이번 실행 전체를 건너뛰게 하는 편이 더
// 안전하다는 설계 결정이다.
func (d *DB) PreloadStationChargerMap(ctx context.Context, sourceID int64) (*StationChargerMap, error) {
	rows, err := d.sqldb.QueryContext(ctx,
		`SELECT sl.source_station_id, s.station_id, c.external_charger_id, c.charger_id
		 FROM station_source_link sl
		 JOIN station s ON s.station_id = sl.station_id
		 LEFT JOIN charger c ON c.station_id = s.station_id
		 WHERE sl.source_id = ?`,
		sourceID)
	if err != nil {
		return nil, fmt.Errorf("station/charger 매핑 프리로드 실패: %w", err)
	}
	defer rows.Close()

	m := newStationChargerMap()
	for rows.Next() {
		var sourceStationID string
		var stationID int64
		var externalChargerID sql.NullString
		var chargerID sql.NullInt64
		if serr := rows.Scan(&sourceStationID, &stationID, &externalChargerID, &chargerID); serr != nil {
			return nil, fmt.Errorf("station/charger 매핑 스캔 실패: %w", serr)
		}
		m.stationIDs[sourceStationID] = stationID
		if externalChargerID.Valid && chargerID.Valid {
			m.chargerIDs[chargerMapKey(stationID, externalChargerID.String)] = chargerID.Int64
		}
	}
	if rerr := rows.Err(); rerr != nil {
		return nil, fmt.Errorf("station/charger 매핑 순회 실패: %w", rerr)
	}
	return m, nil
}
