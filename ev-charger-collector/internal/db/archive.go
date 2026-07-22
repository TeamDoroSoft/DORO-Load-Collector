// archive.go는 charger_status_history 콜드 아카이브(--mode=archive)에 필요한 조회/삭제
// 함수를 담는다. 아카이브는 RDS 백업이 아니라 오래된 이력을 S3로 내보내고 RDS에서
// 지워 테이블을 가볍게 유지하는 목적이다(부수적으로 백업 효과가 있을 뿐).
package db

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"
)

// ArchivableHistoryRow는 아카이브 대상 charger_status_history 한 행이다. RDS 없이
// S3에 저장된 JSON만으로도 어떤 충전기/충전소의 이력인지 해석할 수 있도록
// charger_id뿐 아니라 external_charger_id/station_id/source_station_id까지 함께 담는다.
type ArchivableHistoryRow struct {
	StatusID          int64      `json:"status_id"`
	ChargerID         int64      `json:"charger_id"`
	ExternalChargerID string     `json:"external_charger_id"`
	StationID         int64      `json:"station_id"`
	SourceStationID   string     `json:"source_station_id"`
	Status            string     `json:"status"`
	SourceUpdatedAt   *time.Time `json:"source_updated_at"`
	CollectedAt       *time.Time `json:"collected_at"`
}

// SelectOldStatusHistory는 collected_at < cutoff인 행을 status_id 오름차순으로 최대
// limit개 조회한다. 별도 오프셋 없이 항상 "가장 오래된 것부터" 다시 훑는 방식인데,
// 이는 각 배치가 조회 직후 DeleteStatusHistoryByIDs로 즉시 삭제되는 것을 전제로 한다
// (archive.go 오케스트레이션이 배치 단위로 조회→아카이브→삭제를 반복하므로, 삭제된
// 행은 다음 조회에서 자연히 빠진다 — 별도 체크포인트 없이도 멱등적으로 재개 가능).
//
// station_source_link는 (station_id, source_id) 복합키이며 현재 프로젝트 범위에서는
// station당 소스가 하나(KEV_INFO)뿐이라 JOIN으로 행이 늘어나지 않는다. 향후 한
// station이 복수 소스에 연결되는 시나리오가 추가되면 이 쿼리도 소스 선택 기준을
// 명시하도록 재검토가 필요하다.
func (d *DB) SelectOldStatusHistory(ctx context.Context, cutoff time.Time, limit int) ([]ArchivableHistoryRow, error) {
	rows, err := d.sqldb.QueryContext(ctx,
		`SELECT h.status_id, h.charger_id, c.external_charger_id, c.station_id,
		        sl.source_station_id, h.status, h.source_updated_at, h.collected_at
		 FROM charger_status_history h
		 JOIN charger c ON c.charger_id = h.charger_id
		 JOIN station_source_link sl ON sl.station_id = c.station_id
		 WHERE h.collected_at < ?
		 ORDER BY h.status_id
		 LIMIT ?`,
		cutoff.UTC(), limit)
	if err != nil {
		return nil, fmt.Errorf("아카이브 대상 조회 실패: %w", err)
	}
	defer rows.Close()

	var out []ArchivableHistoryRow
	for rows.Next() {
		var r ArchivableHistoryRow
		var extID sql.NullString
		var srcStationID sql.NullString
		var srcUpdated sql.NullTime
		var collectedAt sql.NullTime
		if serr := rows.Scan(&r.StatusID, &r.ChargerID, &extID, &r.StationID, &srcStationID, &r.Status, &srcUpdated, &collectedAt); serr != nil {
			return nil, fmt.Errorf("아카이브 대상 스캔 실패: %w", serr)
		}
		r.ExternalChargerID = extID.String
		r.SourceStationID = srcStationID.String
		if srcUpdated.Valid {
			t := srcUpdated.Time
			r.SourceUpdatedAt = &t
		}
		if collectedAt.Valid {
			t := collectedAt.Time
			r.CollectedAt = &t
		}
		out = append(out, r)
	}
	if rerr := rows.Err(); rerr != nil {
		return nil, fmt.Errorf("아카이브 대상 순회 실패: %w", rerr)
	}
	return out, nil
}

// DeleteStatusHistoryByIDs는 status_id 목록으로 정확히 그 행들만 삭제한다.
// SelectOldStatusHistory로 SELECT해 PK가 확정된 행만 넘겨야 한다 — 조건절로 다시
// "collected_at < cutoff"를 재사용해 DELETE하면 SELECT와 DELETE 사이에 새로 insert된
// (동일 조건을 우연히 만족하는) 행까지 함께 지워질 위험이 있어, 그 오삭제를 막기
// 위해 반드시 ID 목록 기반으로만 삭제한다.
func (d *DB) DeleteStatusHistoryByIDs(ctx context.Context, ids []int64) (int64, error) {
	if len(ids) == 0 {
		return 0, nil
	}
	placeholders := make([]string, len(ids))
	args := make([]any, len(ids))
	for i, id := range ids {
		placeholders[i] = "?"
		args[i] = id
	}
	query := fmt.Sprintf(`DELETE FROM charger_status_history WHERE status_id IN (%s)`, strings.Join(placeholders, ","))
	result, err := d.sqldb.ExecContext(ctx, query, args...)
	if err != nil {
		return 0, fmt.Errorf("아카이브 대상 삭제 실패: %w", err)
	}
	n, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("아카이브 삭제 영향행수 조회 실패: %w", err)
	}
	return n, nil
}
