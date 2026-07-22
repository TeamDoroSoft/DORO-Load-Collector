// Package db는 MySQL(RDS) 적재를 담당한다(database/sql + go-sql-driver/mysql).
// station 1건 + 그에 속한 charger 전부 + 각 charger의 status_history를 하나의
// 트랜잭션으로 묶어 station 단위로 격리한다. 그 트랜잭션에는 busiId 기반
// operator/charging_network 해석(resolveNetworkID)도 포함되어, station이 올바른
// network_id에 연결되는 것까지 원자적으로 처리한다. station 단위 실패는 스킵하고
// 계속 진행하며(연결 자체 장애만 전체 중단), 좌표는 ST_GeomFromText(WKT, 4326,
// 'axis-order=long-lat')로 저장한다 — axis-order를 명시해 SRID 4326의 기본 위도-경도
// 축 해석과 무관하게 항상 경도-위도(long-lat)로 해석되게 한다(축이 뒤집히면
// SPATIAL INDEX와 거리 계산이 틀어진다).
package db

import (
	"context"
	"database/sql"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/go-sql-driver/mysql"

	"ev-charger-collector/internal/model"
)

// KEV_INFO data_source를 식별하는 엔드포인트(시드 V3와 일치).
const kevInfoEndpoint = "http://apis.data.go.kr/B552584/EvCharger/getChargerInfo"

// 미분류 operator/charging_network 식별값(시드 V4와 일치).
const unverifiedOperatorCode = "UNVERIFIED"

// Config는 MySQL 연결 설정이다.
type Config struct {
	Host     string
	Port     string
	User     string
	Password string
	Name     string
}

// DB는 MySQL 적재 진입점이다.
type DB struct {
	sqldb *sql.DB
}

// Open은 커넥션 풀을 열고 ParseTime=true, Loc=UTC로 설정한다.
// 타임존은 normalize의 UTC 통일 결정과 일치시킨다.
func Open(cfg Config) (*DB, error) {
	mc := mysql.NewConfig()
	mc.User = cfg.User
	mc.Passwd = cfg.Password
	mc.Net = "tcp"
	mc.Addr = fmt.Sprintf("%s:%s", cfg.Host, cfg.Port)
	mc.DBName = cfg.Name
	mc.ParseTime = true
	mc.Loc = time.UTC
	mc.Params = map[string]string{"charset": "utf8mb4"}

	sqldb, err := sql.Open("mysql", mc.FormatDSN())
	if err != nil {
		return nil, fmt.Errorf("MySQL 연결 열기 실패: %w", err)
	}
	// 상시 서버가 아니라 주기 배치이고, RDS가 db.t3.micro 급이라 max_connections
	// 한도가 낮다(기본 수십 개 수준). Spring Boot 백엔드와 커넥션을 나눠 써야 하므로
	// collector 배치는 풀을 작게 잡는다 — 20 이상으로 크게 잡지 않는다.
	// station 단위 트랜잭션을 순차 처리하는 구조라 10/5로 충분하다.
	sqldb.SetMaxOpenConns(10)
	sqldb.SetMaxIdleConns(5)
	sqldb.SetConnMaxLifetime(5 * time.Minute)
	return &DB{sqldb: sqldb}, nil
}

// NewFromSQL은 이미 열린 *sql.DB를 감싼다(테스트용: sqlmock 주입).
func NewFromSQL(sqldb *sql.DB) *DB {
	return &DB{sqldb: sqldb}
}

// Close는 커넥션 풀을 닫는다.
func (d *DB) Close() error { return d.sqldb.Close() }

// Ping은 연결 상태를 확인한다(station 단위 실패가 연결 장애인지 판정에 사용).
func (d *DB) Ping(ctx context.Context) error { return d.sqldb.PingContext(ctx) }

// GetKevInfoSourceID는 KEV_INFO data_source의 source_id를 조회한다.
// 없으면 마이그레이션(V3) 누락 신호로 error를 반환한다(코드가 시드를 만들지 않음).
func (d *DB) GetKevInfoSourceID(ctx context.Context) (int64, error) {
	var id int64
	err := d.sqldb.QueryRowContext(ctx,
		`SELECT source_id FROM data_source WHERE endpoint = ? LIMIT 1`,
		kevInfoEndpoint).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("KEV_INFO data_source 조회 실패(마이그레이션 V3 확인 필요): %w", err)
	}
	return id, nil
}

// GetUnverifiedNetworkID는 "미분류(UNVERIFIED)" charging_network의 network_id를 조회한다.
// 없으면 마이그레이션(V4) 누락 신호로 error를 반환한다.
func (d *DB) GetUnverifiedNetworkID(ctx context.Context) (int64, error) {
	var id int64
	err := d.sqldb.QueryRowContext(ctx,
		`SELECT cn.network_id FROM charging_network cn
		 JOIN operator o ON cn.operator_id = o.operator_id
		 WHERE o.operator_code = ? LIMIT 1`,
		unverifiedOperatorCode).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("미분류 charging_network 조회 실패(마이그레이션 V4 확인 필요): %w", err)
	}
	return id, nil
}

// UpsertedCharger는 upsert된 charger의 DB id와 정규화 원본을 함께 담는다(캐시 갱신용).
type UpsertedCharger struct {
	ChargerID int64
	Norm      model.NormalizedCharger
}

// UpsertResult는 station upsert 결과다(캐시 갱신에 필요한 DB id 포함).
type UpsertResult struct {
	StationID int64
	Chargers  []UpsertedCharger
}

// UpsertStation은 station 1건과 그 charger/status_history를 하나의 트랜잭션으로 적재한다.
// fallbackNetworkID는 station의 busiId가 비어 실제 operator를 해석할 수 없을 때만
// 쓰는 미분류(UNVERIFIED) network_id다. busiId가 있으면 트랜잭션 안에서
// resolveNetworkID가 실제 operator 기반 network_id를 해석해 사용한다.
func (d *DB) UpsertStation(ctx context.Context, sourceID, fallbackNetworkID int64, st model.NormalizedStation) (UpsertResult, error) {
	var res UpsertResult

	tx, err := d.sqldb.BeginTx(ctx, nil)
	if err != nil {
		return res, fmt.Errorf("트랜잭션 시작 실패: %w", err)
	}
	// 커밋 전에 함수가 반환되면 롤백(성공 시 아래에서 tx.Commit 후 committed=true).
	committed := false
	defer func() {
		if !committed {
			_ = tx.Rollback()
		}
	}()

	// busiId 기반으로 실제 operator/charging_network를 해석한다(같은 트랜잭션에 포함).
	networkID, err := d.resolveNetworkID(ctx, tx, st.OperatorExternalID, st.OperatorName, fallbackNetworkID)
	if err != nil {
		return res, err
	}

	stationID, err := d.upsertStationRow(ctx, tx, sourceID, networkID, st)
	if err != nil {
		return res, err
	}
	res.StationID = stationID

	for _, ch := range st.Chargers {
		chargerID, err := d.upsertCharger(ctx, tx, stationID, ch)
		if err != nil {
			return res, err
		}
		if err := d.syncChargerConnectors(ctx, tx, chargerID, ch.ConnectorCodes); err != nil {
			return res, err
		}
		if err := d.upsertStatusHistory(ctx, tx, chargerID, ch.Status); err != nil {
			return res, err
		}
		res.Chargers = append(res.Chargers, UpsertedCharger{ChargerID: chargerID, Norm: ch})
	}

	if err := tx.Commit(); err != nil {
		return res, fmt.Errorf("커밋 실패: %w", err)
	}
	committed = true
	return res, nil
}

// resolveNetworkID는 소스 사업자(busiId/busiNm)를 실제 operator/charging_network로
// 해석해 station이 연결될 network_id를 반환한다. operator/network가 없으면 생성하고,
// 소스 표기가 바뀌었으면 최신화한다(모두 인자로 받은 tx로 실행 — station 단위
// 트랜잭션에 포함시켜 원자성 유지). busiID가 비면 미분류 fallbackID를 그대로 쓴다.
func (d *DB) resolveNetworkID(ctx context.Context, tx *sql.Tx, busiID, busiName string, fallbackID int64) (int64, error) {
	busiID = strings.TrimSpace(busiID)
	if busiID == "" {
		// 사업자 식별자가 없으면 미분류 fallback을 그대로 사용(추가 쿼리 없음).
		return fallbackID, nil
	}
	busiName = strings.TrimSpace(busiName)
	if busiName == "" {
		// legal_name/network_name이 NOT NULL이라 빈 문자열을 넣지 않는다.
		busiName = "미상(" + busiID + ")"
	}

	// 1) operator 조회 — 없으면 생성, legal_name이 바뀌었으면 최신화.
	var operatorID int64
	var legalName string
	err := tx.QueryRowContext(ctx,
		`SELECT operator_id, legal_name FROM operator WHERE operator_code = ?`,
		busiID).Scan(&operatorID, &legalName)
	switch err {
	case nil:
		if legalName != busiName {
			// 소스 표기가 시간이 지나며 바뀔 수 있어 최신 값으로 갱신한다.
			if _, uerr := tx.ExecContext(ctx,
				`UPDATE operator SET legal_name = ? WHERE operator_id = ?`,
				busiName, operatorID); uerr != nil {
				return 0, fmt.Errorf("operator 갱신 실패(operator_id=%d): %w", operatorID, uerr)
			}
		}
	case sql.ErrNoRows:
		result, ierr := tx.ExecContext(ctx,
			`INSERT INTO operator (legal_name, operator_code) VALUES (?, ?)`,
			busiName, busiID)
		if ierr != nil {
			return 0, fmt.Errorf("operator 삽입 실패(operator_code=%s): %w", busiID, ierr)
		}
		operatorID, ierr = result.LastInsertId()
		if ierr != nil {
			return 0, fmt.Errorf("operator LAST_INSERT_ID 조회 실패: %w", ierr)
		}
	default:
		return 0, fmt.Errorf("operator 조회 실패(operator_code=%s): %w", busiID, err)
	}

	// 2) charging_network 조회 — 연산자당 네트워크 1개 가정(V8 UNIQUE로 강제).
	//    없으면 생성, network_name이 바뀌었으면 최신화.
	var networkID int64
	var networkName string
	nerr := tx.QueryRowContext(ctx,
		`SELECT network_id, network_name FROM charging_network WHERE operator_id = ? LIMIT 1`,
		operatorID).Scan(&networkID, &networkName)
	switch nerr {
	case nil:
		if networkName != busiName {
			if _, uerr := tx.ExecContext(ctx,
				`UPDATE charging_network SET network_name = ? WHERE network_id = ?`,
				busiName, networkID); uerr != nil {
				return 0, fmt.Errorf("charging_network 갱신 실패(network_id=%d): %w", networkID, uerr)
			}
		}
	case sql.ErrNoRows:
		result, ierr := tx.ExecContext(ctx,
			`INSERT INTO charging_network (operator_id, network_name) VALUES (?, ?)`,
			operatorID, busiName)
		if ierr != nil {
			return 0, fmt.Errorf("charging_network 삽입 실패(operator_id=%d): %w", operatorID, ierr)
		}
		networkID, ierr = result.LastInsertId()
		if ierr != nil {
			return 0, fmt.Errorf("charging_network LAST_INSERT_ID 조회 실패: %w", ierr)
		}
	default:
		return 0, fmt.Errorf("charging_network 조회 실패(operator_id=%d): %w", operatorID, nerr)
	}

	return networkID, nil
}

// pointWKT는 (lng, lat)를 WKT POINT 문자열("POINT(경도 위도)")로 만든다.
// %v(지수 표기 가능)를 피하려고 strconv.FormatFloat('f', -1)로 소수 표기를 고정한다.
func pointWKT(lng, lat float64) string {
	return fmt.Sprintf("POINT(%s %s)",
		strconv.FormatFloat(lng, 'f', -1, 64),
		strconv.FormatFloat(lat, 'f', -1, 64))
}

// upsertStationRow는 station_source_link로 기존 매칭을 조회해 station을 insert/update한다.
// 좌표는 ST_GeomFromText(WKT, 4326, 'axis-order=long-lat')로 저장한다 —
// axis-order를 명시해 SRID 4326의 기본 위도-경도 축 해석과 무관하게 항상 경도-위도로
// 해석되게 한다(pointWKT가 "경도 위도" 순서로 WKT를 만든다).
func (d *DB) upsertStationRow(ctx context.Context, tx *sql.Tx, sourceID, networkID int64, st model.NormalizedStation) (int64, error) {
	loc := pointWKT(st.Lng, st.Lat)
	collectedAt := nullTime(st.CollectedAt)

	var stationID int64
	var curUpdatedAt sql.NullTime
	err := tx.QueryRowContext(ctx,
		`SELECT sl.station_id, s.updated_at
		 FROM station_source_link sl
		 JOIN station s ON s.station_id = sl.station_id
		 WHERE sl.source_id = ? AND sl.source_station_id = ?`,
		sourceID, st.SourceStationID).Scan(&stationID, &curUpdatedAt)

	switch err {
	case nil:
		// 기존 station 갱신.
		// network_id도 함께 갱신한다 — 과거 UNVERIFIED로 적재된 station이 재수집 시
		// busiId로 해석된 올바른 operator/network로 자연스럽게 self-heal 되게 한다.
		// updated_at은 이벤트시간 역행 방지: 지연 도착 배치가 과거로 되돌리지 못하게
		// 기존 값과 비교해 더 이후일 때만 갱신한다(status_history와 동일한 Go 비교 스타일).
		updatedAt := resolveStationUpdatedAt(curUpdatedAt, st.UpdatedAt)
		if _, uerr := tx.ExecContext(ctx,
			`UPDATE station
			 SET network_id = ?, station_name = ?, address = ?, is_closed = ?,
			     location = ST_GeomFromText(?, 4326, 'axis-order=long-lat'),
			     operating_hours = ?, updated_at = ?, last_collected_at = ?
			 WHERE station_id = ?`,
			networkID, st.StationName, st.Address, st.IsClosed, loc, st.OperatingHours, updatedAt, collectedAt, stationID); uerr != nil {
			return 0, fmt.Errorf("station 갱신 실패(station_id=%d): %w", stationID, uerr)
		}
		return stationID, nil

	case sql.ErrNoRows:
		// 신규 station 삽입 후 station_source_link 매칭 추가.
		result, ierr := tx.ExecContext(ctx,
			`INSERT INTO station (network_id, station_name, address, is_closed, location, operating_hours, updated_at, last_collected_at)
			 VALUES (?, ?, ?, ?, ST_GeomFromText(?, 4326, 'axis-order=long-lat'), ?, ?, ?)`,
			networkID, st.StationName, st.Address, st.IsClosed, loc, st.OperatingHours, nullTime(st.UpdatedAt), collectedAt)
		if ierr != nil {
			return 0, fmt.Errorf("station 삽입 실패(source_station_id=%s): %w", st.SourceStationID, ierr)
		}
		newID, lerr := result.LastInsertId()
		if lerr != nil {
			return 0, fmt.Errorf("station LAST_INSERT_ID 조회 실패: %w", lerr)
		}
		// 이번 소스는 하나뿐이라 exact_id / score=1.0 고정.
		if _, lerr := tx.ExecContext(ctx,
			`INSERT INTO station_source_link (station_id, source_id, source_station_id, match_method, match_score)
			 VALUES (?, ?, ?, 'exact_id', 1.0)`,
			newID, sourceID, st.SourceStationID); lerr != nil {
			return 0, fmt.Errorf("station_source_link 삽입 실패(station_id=%d): %w", newID, lerr)
		}
		return newID, nil

	default:
		return 0, fmt.Errorf("station_source_link 조회 실패(source_station_id=%s): %w", st.SourceStationID, err)
	}
}

// upsertCharger는 (station_id, external_charger_id)로 조회해 charger를 insert/update한다.
func (d *DB) upsertCharger(ctx context.Context, tx *sql.Tx, stationID int64, ch model.NormalizedCharger) (int64, error) {
	var chargerID int64
	err := tx.QueryRowContext(ctx,
		`SELECT charger_id FROM charger WHERE station_id = ? AND external_charger_id = ?`,
		stationID, ch.ExternalChargerID).Scan(&chargerID)

	switch err {
	case nil:
		if _, uerr := tx.ExecContext(ctx,
			`UPDATE charger SET charger_type = ?, max_power_kw = ? WHERE charger_id = ?`,
			ch.ChargerType, nullFloat(ch.MaxPowerKW), chargerID); uerr != nil {
			return 0, fmt.Errorf("charger 갱신 실패(charger_id=%d): %w", chargerID, uerr)
		}
		return chargerID, nil

	case sql.ErrNoRows:
		result, ierr := tx.ExecContext(ctx,
			`INSERT INTO charger (station_id, external_charger_id, charger_type, max_power_kw)
			 VALUES (?, ?, ?, ?)`,
			stationID, ch.ExternalChargerID, ch.ChargerType, nullFloat(ch.MaxPowerKW))
		if ierr != nil {
			return 0, fmt.Errorf("charger 삽입 실패(external=%s): %w", ch.ExternalChargerID, ierr)
		}
		newID, lerr := result.LastInsertId()
		if lerr != nil {
			return 0, fmt.Errorf("charger LAST_INSERT_ID 조회 실패: %w", lerr)
		}
		return newID, nil

	default:
		return 0, fmt.Errorf("charger 조회 실패(external=%s): %w", ch.ExternalChargerID, err)
	}
}

// upsertStatusHistory는 변경분만 append한다.
//   - 직전 row와 status·source_updated_at이 모두 같으면 skip
//   - 새 이벤트시간이 직전보다 과거이면 skip(지연 도착 무시)
//   - 그 외에는 insert
func (d *DB) upsertStatusHistory(ctx context.Context, tx *sql.Tx, chargerID int64, ev model.NormalizedStatusEvent) error {
	var lastStatus string
	var lastSrcUpd sql.NullTime
	err := tx.QueryRowContext(ctx,
		`SELECT status, source_updated_at FROM charger_status_history
		 WHERE charger_id = ? ORDER BY collected_at DESC LIMIT 1`,
		chargerID).Scan(&lastStatus, &lastSrcUpd)

	newSrc := nullTime(ev.SourceUpdatedAt)

	switch err {
	case nil:
		// 상태·이벤트시간이 모두 동일하면 skip.
		if lastStatus == ev.Status && sameNullTime(lastSrcUpd, newSrc) {
			return nil
		}
		// 새 이벤트시간이 직전보다 과거이면 지연 도착으로 보고 skip.
		if lastSrcUpd.Valid && newSrc.Valid && newSrc.Time.Before(lastSrcUpd.Time) {
			return nil
		}
		// 그 외에는 아래에서 insert.
	case sql.ErrNoRows:
		// 이력이 없으면 최초 insert.
	default:
		return fmt.Errorf("status_history 최신 row 조회 실패(charger_id=%d): %w", chargerID, err)
	}

	if _, ierr := tx.ExecContext(ctx,
		`INSERT INTO charger_status_history (charger_id, status, source_updated_at, collected_at)
		 VALUES (?, ?, ?, ?)`,
		chargerID, ev.Status, newSrc, nullTime(ev.CollectedAt)); ierr != nil {
		return fmt.Errorf("status_history 삽입 실패(charger_id=%d): %w", chargerID, ierr)
	}
	return nil
}

// syncChargerConnectors는 charger의 지원 커넥터 집합을 diff 기반으로 동기화한다.
// status_history와 달리 append-only 이력이 아니라 "현재 지원 커넥터 집합"
// 스냅샷이므로, 기존 행을 조회해 추가분만 INSERT하고 사라진 것만 DELETE하며
// 무변경 시 쓰기를 하지 않는다. 결정적 순서(테스트 재현성)를 위해 정렬 순서로 처리한다.
func (d *DB) syncChargerConnectors(ctx context.Context, tx *sql.Tx, chargerID int64, codes []string) error {
	// 원하는 집합(빈 문자열 제외, 중복 제거).
	want := make(map[string]struct{}, len(codes))
	for _, c := range codes {
		if c == "" {
			continue
		}
		want[c] = struct{}{}
	}

	// 기존 집합 조회.
	rows, err := tx.QueryContext(ctx,
		`SELECT connector_code FROM charger_connector WHERE charger_id = ?`,
		chargerID)
	if err != nil {
		return fmt.Errorf("charger_connector 조회 실패(charger_id=%d): %w", chargerID, err)
	}
	existing := make(map[string]struct{})
	for rows.Next() {
		var code string
		if serr := rows.Scan(&code); serr != nil {
			_ = rows.Close()
			return fmt.Errorf("charger_connector 스캔 실패(charger_id=%d): %w", chargerID, serr)
		}
		existing[code] = struct{}{}
	}
	if rerr := rows.Err(); rerr != nil {
		_ = rows.Close()
		return fmt.Errorf("charger_connector 순회 실패(charger_id=%d): %w", chargerID, rerr)
	}
	_ = rows.Close()

	// 추가분(want엔 있고 existing엔 없음) — 정렬 순서로 INSERT.
	var toAdd []string
	for c := range want {
		if _, ok := existing[c]; !ok {
			toAdd = append(toAdd, c)
		}
	}
	sort.Strings(toAdd)
	for _, c := range toAdd {
		if _, ierr := tx.ExecContext(ctx,
			`INSERT INTO charger_connector (charger_id, connector_code) VALUES (?, ?)`,
			chargerID, c); ierr != nil {
			return fmt.Errorf("charger_connector 삽입 실패(charger_id=%d, code=%s): %w", chargerID, c, ierr)
		}
	}

	// 사라진 것(existing엔 있고 want엔 없음) — 정렬 순서로 DELETE.
	var toDel []string
	for c := range existing {
		if _, ok := want[c]; !ok {
			toDel = append(toDel, c)
		}
	}
	sort.Strings(toDel)
	for _, c := range toDel {
		if _, derr := tx.ExecContext(ctx,
			`DELETE FROM charger_connector WHERE charger_id = ? AND connector_code = ?`,
			chargerID, c); derr != nil {
			return fmt.Errorf("charger_connector 삭제 실패(charger_id=%d, code=%s): %w", chargerID, c, derr)
		}
	}

	return nil
}

// resolveStationUpdatedAt은 이벤트시간 역행을 방지해 station.updated_at 최종값을 결정한다.
//   - 새 값(newUpdatedAt)이 zero면 → 기존 값 유지(갱신 안 함).
//   - 기존 값(cur)이 NULL이면 → 새 값 사용.
//   - 새 값이 기존보다 이후(after)면 → 새 값 사용.
//   - 그 외(새 값이 기존보다 과거)면 → 기존 값 유지(지연 도착 역행 방지).
func resolveStationUpdatedAt(cur sql.NullTime, newUpdatedAt time.Time) sql.NullTime {
	if newUpdatedAt.IsZero() {
		return cur
	}
	newVal := nullTime(newUpdatedAt)
	if !cur.Valid {
		return newVal
	}
	if newVal.Time.After(cur.Time) {
		return newVal
	}
	return cur
}

// nullTime은 zero time을 SQL NULL로 변환한다.
func nullTime(t time.Time) sql.NullTime {
	if t.IsZero() {
		return sql.NullTime{}
	}
	return sql.NullTime{Time: t.UTC(), Valid: true}
}

// nullFloat은 nil 포인터를 SQL NULL로 변환한다.
func nullFloat(f *float64) sql.NullFloat64 {
	if f == nil {
		return sql.NullFloat64{}
	}
	return sql.NullFloat64{Float64: *f, Valid: true}
}

// sameNullTime은 두 NullTime이 같은 시각(또는 둘 다 NULL)인지 비교한다.
func sameNullTime(a, b sql.NullTime) bool {
	if a.Valid != b.Valid {
		return false
	}
	if !a.Valid {
		return true
	}
	return a.Time.Equal(b.Time)
}
