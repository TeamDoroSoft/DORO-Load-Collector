// Package validate는 RawItem을 정규화 이전에 검증한다.
// 검증 규칙(deployment-v2 §2):
//   - 필수값: statId/chgerId/statNm/addr 공란 시 실패
//   - 좌표: lat/lng 파싱 불가 또는 대한민국 실용 범위(위도 33~39, 경도 124~132)
//     밖이면 실패
//
// 상태코드는 검증 대상이 아니다(normalize의 관대한 매핑 책임 — 결정 7·8).
// 오류 item과 정상 item을 분리 반환하고, 저장은 storage 패키지 책임이다.
package validate

import (
	"strconv"
	"strings"
	"time"

	"ev-charger-collector/internal/model"
)

// 대한민국 실용 좌표 범위(deployment-v2 §2 검증 규칙).
const (
	minLat = 33.0
	maxLat = 39.0
	minLng = 124.0
	maxLng = 132.0
)

// 검증 실패 사유 코드(오류 저장소에 기록).
const (
	ReasonMissingRequiredField = "missing_required_field"
	ReasonInvalidCoordinate    = "invalid_coordinate"
)

// InvalidItem은 검증에 실패한 원본 item과 실패 사유를 묶는다.
type InvalidItem struct {
	Item      model.RawItem `json:"item"`
	Reason    string        `json:"reason"`    // 사유 코드(위 상수)
	Detail    string        `json:"detail"`    // 사람이 읽을 상세 설명
	CheckedAt time.Time     `json:"checkedAt"` // 검증 시각(UTC)
}

// Validate는 items를 검증해 (정상 item, 오류 item) 쌍으로 분리 반환한다.
// checkedAt은 검증 배치 기준 시각(UTC 권장)이다.
func Validate(items []model.RawItem, checkedAt time.Time) (valid []model.RawItem, invalid []InvalidItem) {
	valid = make([]model.RawItem, 0, len(items))
	invalid = make([]InvalidItem, 0)

	for _, it := range items {
		if reason, detail, ok := checkRequiredFields(it); !ok {
			invalid = append(invalid, InvalidItem{Item: it, Reason: reason, Detail: detail, CheckedAt: checkedAt})
			continue
		}
		if reason, detail, ok := checkCoordinates(it); !ok {
			invalid = append(invalid, InvalidItem{Item: it, Reason: reason, Detail: detail, CheckedAt: checkedAt})
			continue
		}
		valid = append(valid, it)
	}
	return valid, invalid
}

// checkRequiredFields는 statId/chgerId/statNm/addr 공란 여부를 검증한다.
func checkRequiredFields(it model.RawItem) (reason, detail string, ok bool) {
	missing := make([]string, 0, 4)
	if strings.TrimSpace(it.StatId) == "" {
		missing = append(missing, "statId")
	}
	if strings.TrimSpace(it.ChgerId) == "" {
		missing = append(missing, "chgerId")
	}
	if strings.TrimSpace(it.StatNm) == "" {
		missing = append(missing, "statNm")
	}
	if strings.TrimSpace(it.Addr) == "" {
		missing = append(missing, "addr")
	}
	if len(missing) > 0 {
		return ReasonMissingRequiredField, "누락 필드: " + strings.Join(missing, ", "), false
	}
	return "", "", true
}

// checkCoordinates는 lat/lng 파싱 및 대한민국 실용 범위를 검증한다.
func checkCoordinates(it model.RawItem) (reason, detail string, ok bool) {
	lat, err := strconv.ParseFloat(strings.TrimSpace(it.Lat), 64)
	if err != nil {
		return ReasonInvalidCoordinate, "위도 파싱 실패: " + it.Lat, false
	}
	lng, err := strconv.ParseFloat(strings.TrimSpace(it.Lng), 64)
	if err != nil {
		return ReasonInvalidCoordinate, "경도 파싱 실패: " + it.Lng, false
	}
	if lat < minLat || lat > maxLat {
		return ReasonInvalidCoordinate, "위도 범위 밖: " + it.Lat, false
	}
	if lng < minLng || lng > maxLng {
		return ReasonInvalidCoordinate, "경도 범위 밖: " + it.Lng, false
	}
	return "", "", true
}
