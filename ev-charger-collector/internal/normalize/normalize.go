// Package normalize는 검증을 통과한 RawItem을 DORO Load 표준 포맷(NormalizedStation)
// 으로 변환한다. 코드 매핑(커넥터/상태), 시간·좌표 파싱, station 그룹핑,
// 급속/완속(charge_speed) 파생을 담당한다.
//
// 코드 매핑 테이블은 하드코딩 Go map이다. data/schemas의 통합 스키마가 Go 모듈
// 루트 밖에 있어 go:embed가 물리적으로 불가하기 때문이다. 아래 map은
//   - data/schemas/ev-charging-station.integrated.schema.json 의 x-code-mappings(source=KEV_INFO)
//   - data/schemas/ev-charging-station.search-response.schema.json 의 x-speed-mapping
//
// 과 정확히 동일해야 한다. 스키마 변경 시 이 파일을 수동으로 동기화해야 한다.
package normalize

import (
	"log"
	"strconv"
	"strings"
	"time"

	"ev-charger-collector/internal/model"
)

// connectorTypeMap은 KEV_INFO의 chgerType(원본) → 표준 ConnectorType 매핑이다.
// 스키마 변경 시 수동 동기화 필요(x-code-mappings.connector_type, source=KEV_INFO).
var connectorTypeMap = map[string]string{
	"01": "DC_CHADEMO",
	"02": "AC_SLOW",
	"03": "DC_CHADEMO_AC3",
	"04": "DC_COMBO",
	"05": "DC_CHADEMO_DC_COMBO",
	"06": "DC_CHADEMO_AC3_DC_COMBO",
	"07": "AC3",
	"08": "DC_COMBO_SLOW",
	"09": "NACS",
	"10": "DC_COMBO_NACS",
	"11": "DC_COMBO2_BUS",
}

// chargerStatusMap은 KEV_INFO의 stat(원본) → 표준 ChargerStatus 매핑이다.
// 스키마 변경 시 수동 동기화 필요(x-code-mappings.charger_status, source=KEV_INFO).
// 주의: 7, 8 등 정의되지 않은 코드는 미매핑으로 UNKNOWN 처리(아래 MapChargerStatus).
var chargerStatusMap = map[string]string{
	"0": "UNKNOWN",
	"1": "COMMUNICATION_ERROR",
	"2": "AVAILABLE",
	"3": "CHARGING",
	"4": "OUT_OF_SERVICE",
	"5": "UNDER_MAINTENANCE",
	"6": "RESERVED",
	"9": "UNKNOWN",
}

// speedMap은 표준 ConnectorType → charge_speed(급속/완속) 매핑이다.
// 스키마 변경 시 수동 동기화 필요(x-speed-mapping.rules).
var speedMap = map[string]string{
	"AC_SLOW":                 "SLOW",
	"DC_COMBO_SLOW":           "SLOW",
	"DC_CHADEMO":              "RAPID",
	"DC_CHADEMO_AC3":          "RAPID",
	"DC_COMBO":                "RAPID",
	"DC_CHADEMO_DC_COMBO":     "RAPID",
	"DC_CHADEMO_AC3_DC_COMBO": "RAPID",
	"AC3":                     "RAPID",
	"NACS":                    "RAPID",
	"DC_COMBO_NACS":           "RAPID",
	"DC_COMBO2_BUS":           "RAPID",
	"UNKNOWN":                 "UNKNOWN",
	"UNMAPPED":                "UNKNOWN",
}

// compositeDecomposition은 복합 커넥터 표준값을 원자 커넥터 코드 목록으로 분해한다.
// 환경부 chgerType 03/05/06/10은 커넥터 2~3종이 물리적으로 결합된 복합 코드다.
// 여기 없는 표준값은 그 자체가 원자 커넥터이므로 [자기자신] 한 원소로 반환한다.
var compositeDecomposition = map[string][]string{
	"DC_CHADEMO_AC3":          {"DC_CHADEMO", "AC3"},
	"DC_CHADEMO_DC_COMBO":     {"DC_CHADEMO", "DC_COMBO"},
	"DC_CHADEMO_AC3_DC_COMBO": {"DC_CHADEMO", "AC3", "DC_COMBO"},
	"DC_COMBO_NACS":           {"DC_COMBO", "NACS"},
}

// DecomposeConnectorTypes는 표준 ConnectorType을 원자 커넥터 코드 목록으로 분해한다.
// 복합 코드면 구성 원자 커넥터들을, 아니면 자기 자신 한 원소를 담은 새 슬라이스를 반환한다.
func DecomposeConnectorTypes(standard string) []string {
	if parts, ok := compositeDecomposition[standard]; ok {
		out := make([]string, len(parts))
		copy(out, parts)
		return out
	}
	return []string{standard}
}

// kstZone은 statUpdDt 파싱용 KST(UTC+9) 고정 오프셋 존이다.
// time.LoadLocation("Asia/Seoul")은 tzdata 미설치 환경에서 실패할 수 있어
// FixedZone으로 대체한다(계획 결정).
var kstZone = time.FixedZone("KST", 9*3600)

// MapConnectorType은 원본 chgerType 코드를 표준 ConnectorType으로 변환한다.
// 매핑되지 않은 신규 코드는 파이프라인을 막지 않고 UNMAPPED로 표시한다(결정 8).
func MapConnectorType(raw string) string {
	if v, ok := connectorTypeMap[raw]; ok {
		return v
	}
	return "UNMAPPED"
}

// MapChargerStatus는 원본 stat 코드를 표준 ChargerStatus로 변환한다.
// 매핑되지 않은 코드(7, 8 등)는 UNKNOWN으로 관대하게 정규화한다(결정 7).
// 주의: ChargerStatus enum에는 UNMAPPED가 없으므로 커넥터와 달리 UNKNOWN이다.
func MapChargerStatus(raw string) string {
	if v, ok := chargerStatusMap[raw]; ok {
		return v
	}
	return "UNKNOWN"
}

// MapChargeSpeed는 표준 ConnectorType을 급속/완속(charge_speed)으로 파생한다.
// x-speed-mapping을 그대로 이식한 것으로, 새 kW 임계값 규칙을 만들지 않는다.
// default_rule: 표에 없는 DC_* 계열은 RAPID, 그 외는 UNKNOWN.
func MapChargeSpeed(connectorType string) string {
	if v, ok := speedMap[connectorType]; ok {
		return v
	}
	if strings.HasPrefix(connectorType, "DC_") {
		return "RAPID"
	}
	return "UNKNOWN"
}

// ParseKSTToUTC는 statUpdDt(YYYYMMDDHHmmss, KST 가정)를 UTC time.Time으로 변환한다.
// 빈 문자열이거나 파싱 실패면 zero time과 false를 반환한다(호출부가 판단).
func ParseKSTToUTC(raw string) (time.Time, bool) {
	s := strings.TrimSpace(raw)
	if s == "" {
		return time.Time{}, false
	}
	t, err := time.ParseInLocation("20060102150405", s, kstZone)
	if err != nil {
		return time.Time{}, false
	}
	return t.UTC(), true
}

// parseOutput은 output(kW) 문자열을 *float64로 파싱한다. 공란/파싱 실패면 nil.
func parseOutput(raw string) *float64 {
	s := strings.TrimSpace(raw)
	if s == "" {
		return nil
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return nil
	}
	return &v
}

// parseCoord는 위/경도 문자열을 float64로 파싱한다. 실패 시 0, false.
func parseCoord(raw string) (float64, bool) {
	v, err := strconv.ParseFloat(strings.TrimSpace(raw), 64)
	if err != nil {
		return 0, false
	}
	return v, true
}

// Normalize는 검증을 통과한 RawItem 목록을 표준 NormalizedStation 목록으로 변환한다.
// 같은 statId끼리 충전기를 그룹핑하고, station 필드는 그 그룹의 첫 item을 채택한다.
// station 필드 값이 그룹 내에서 불일치하면 실패시키지 않고 경고 로그만 남긴다.
// collectedAt은 이번 수집 배치의 기준 시각(UTC 권장)이다.
func Normalize(items []model.RawItem, collectedAt time.Time) []model.NormalizedStation {
	// statId -> stations 슬라이스 인덱스. stations 슬라이스 자체가 등장 순서를 보존한다.
	idx := make(map[string]int)
	stations := make([]model.NormalizedStation, 0)

	for _, it := range items {
		statID := strings.TrimSpace(it.StatId)

		lat, _ := parseCoord(it.Lat)
		lng, _ := parseCoord(it.Lng)

		connType := MapConnectorType(strings.TrimSpace(it.ChgerType))
		// sourceUpdatedAt은 소스가 준 이벤트시각(파싱 실패 시 zero)이다.
		// 이 값은 collectedAt으로 폴백하지 않고 그대로 Status.SourceUpdatedAt에 넣어
		// charger_status_history dedup 키가 진짜 zero를 유지하게 한다(무의미한 이력 증식 방지).
		sourceUpdatedAt, hasSourceTime := ParseKSTToUTC(it.StatUpdDt)
		// groupingEventTime은 station.UpdatedAt(표시용 "최선 추정 이벤트시각") 갱신에만
		// 쓰는 별도 값이다. 소스 시각이 없으면 수집 시각으로 폴백한다.
		groupingEventTime := sourceUpdatedAt
		if !hasSourceTime {
			groupingEventTime = collectedAt
		}

		charger := model.NormalizedCharger{
			ExternalChargerID: statID + "#" + strings.TrimSpace(it.ChgerId),
			ChargerTypeRaw:    strings.TrimSpace(it.ChgerType),
			ChargerType:       connType,
			ChargeSpeed:       MapChargeSpeed(connType),
			ConnectorCodes:    DecomposeConnectorTypes(connType),
			MaxPowerKW:        parseOutput(it.Output),
			Status: model.NormalizedStatusEvent{
				StatusRaw:       strings.TrimSpace(it.Stat),
				Status:          MapChargerStatus(strings.TrimSpace(it.Stat)),
				SourceUpdatedAt: sourceUpdatedAt,
				CollectedAt:     collectedAt,
			},
		}

		// delYn='Y'는 폐쇄 충전소다(검증 실패가 아닌 정당한 운영 상태).
		isClosed := strings.TrimSpace(it.DelYn) == "Y"

		// busiId(사업자 식별자)/busiNm(사업자명, 비면 bnm fallback)을 뽑아둔다.
		// DB 계층이 이 값으로 실제 operator/charging_network를 해석한다.
		operatorExtID := strings.TrimSpace(it.BusiId)
		operatorName := strings.TrimSpace(it.BusiNm)
		if operatorName == "" {
			operatorName = strings.TrimSpace(it.Bnm)
		}

		if i, exists := idx[statID]; exists {
			// 기존 station에 충전기 추가. station 필드 불일치는 경고만.
			st := &stations[i]
			warnIfMismatch(statID, "statNm", st.StationName, strings.TrimSpace(it.StatNm))
			warnIfMismatch(statID, "addr", st.Address, strings.TrimSpace(it.Addr))
			warnIfMismatch(statID, "busiId", st.OperatorExternalID, operatorExtID)
			warnIfMismatch(statID, "busiNm", st.OperatorName, operatorName)
			warnIfMismatch(statID, "delYn", boolToYN(st.IsClosed), boolToYN(isClosed))
			st.Chargers = append(st.Chargers, charger)
			if groupingEventTime.After(st.UpdatedAt) {
				st.UpdatedAt = groupingEventTime
			}
			// CollectedAt은 이벤트시간과 무관하게 항상 이번 배치 시각으로 갱신한다
			// ("마지막으로 이 station을 본 시각").
			st.CollectedAt = collectedAt
		} else {
			// 새 station: 첫 item의 필드를 채택.
			st := model.NormalizedStation{
				SourceStationID:    statID,
				StationName:        strings.TrimSpace(it.StatNm),
				Address:            strings.TrimSpace(it.Addr),
				Lat:                lat,
				Lng:                lng,
				OperatingHours:     strings.TrimSpace(it.UseTime),
				UpdatedAt:          groupingEventTime,
				CollectedAt:        collectedAt,
				IsClosed:           isClosed,
				OperatorExternalID: operatorExtID,
				OperatorName:       operatorName,
				Chargers:           []model.NormalizedCharger{charger},
			}
			idx[statID] = len(stations)
			stations = append(stations, st)
		}
	}

	return stations
}

// warnIfMismatch는 같은 station 그룹 내에서 station 레벨 필드 값이 다를 때
// 경고 로그를 남긴다(실패시키지 않음 — 첫 값을 신뢰).
func warnIfMismatch(statID, field, first, current string) {
	if current != "" && current != first {
		log.Printf("[normalize] station=%s 필드 %s 값 불일치(첫값=%q, 이후값=%q) — 첫값 채택",
			statID, field, first, current)
	}
}

// boolToYN은 IsClosed(bool)를 원본 delYn 표기("Y"/"N")로 변환한다.
// warnIfMismatch가 문자열 비교로 그룹 내 delYn 불일치를 경고할 수 있게 한다.
func boolToYN(b bool) string {
	if b {
		return "Y"
	}
	return "N"
}
