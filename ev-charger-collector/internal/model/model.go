// Package model은 collector 파이프라인 전 단계가 공유하는 데이터 타입을 정의한다.
//   - RawItem/Response/ServiceErrorResponse: 환경부 EvCharger 원본 응답 구조
//     (기존 main 패키지의 Item/Response/ServiceErrorResponse를 이 패키지로 이동해
//     normalize/validate/db 등 내부 패키지가 참조할 수 있게 한다).
//   - Normalized*: 검증·정규화를 거친 표준화 데이터. 시간 필드는 전부 UTC로 통일한다.
//   - PipelineStats: 단계별 실행 통계(CloudWatch Logs Insights용 구조화 로그에 재사용).
package model

import (
	"encoding/xml"
	"time"
)

// RawItem은 한국환경공단 EvCharger getChargerInfo 응답의 item 하나를 그대로 담는다.
// 실제 XML 샘플로 확인된 필드만 포함하며, 날짜류 필드는 YYYYMMDDHHmmss 원본
// 포맷을 그대로 문자열로 보존한다(가공/변환은 normalize 단계 책임).
type RawItem struct {
	StatNm      string `xml:"statNm" json:"statNm"`
	StatId      string `xml:"statId" json:"statId"`
	ChgerId     string `xml:"chgerId" json:"chgerId"`
	ChgerType   string `xml:"chgerType" json:"chgerType"`
	Addr        string `xml:"addr" json:"addr"`
	AddrDetail  string `xml:"addrDetail" json:"addrDetail"`
	Location    string `xml:"location" json:"location"`
	Lat         string `xml:"lat" json:"lat"`
	Lng         string `xml:"lng" json:"lng"`
	UseTime     string `xml:"useTime" json:"useTime"`
	BusiId      string `xml:"busiId" json:"busiId"`
	Bnm         string `xml:"bnm" json:"bnm"`
	BusiNm      string `xml:"busiNm" json:"busiNm"`
	BusiCall    string `xml:"busiCall" json:"busiCall"`
	Stat        string `xml:"stat" json:"stat"`
	StatUpdDt   string `xml:"statUpdDt" json:"statUpdDt"`
	LastTsdt    string `xml:"lastTsdt" json:"lastTsdt"`
	LastTedt    string `xml:"lastTedt" json:"lastTedt"`
	NowTsdt     string `xml:"nowTsdt" json:"nowTsdt"`
	PowerType   string `xml:"powerType" json:"powerType"`
	Output      string `xml:"output" json:"output"`
	Method      string `xml:"method" json:"method"`
	Zcode       string `xml:"zcode" json:"zcode"`
	Zscode      string `xml:"zscode" json:"zscode"`
	Kind        string `xml:"kind" json:"kind"`
	KindDetail  string `xml:"kindDetail" json:"kindDetail"`
	ParkingFree string `xml:"parkingFree" json:"parkingFree"`
	Note        string `xml:"note" json:"note"`
	LimitYn     string `xml:"limitYn" json:"limitYn"`
	LimitDetail string `xml:"limitDetail" json:"limitDetail"`
	DelYn       string `xml:"delYn" json:"delYn"`
	DelDetail   string `xml:"delDetail" json:"delDetail"`
	TrafficYn   string `xml:"trafficYn" json:"trafficYn"`
	Year        string `xml:"year" json:"year"`
	FloorNum    string `xml:"floorNum" json:"floorNum"`
	FloorType   string `xml:"floorType" json:"floorType"`
	Maker       string `xml:"maker" json:"maker"`
}

// Response는 data.go.kr 표준 응답 봉투(response/header/body)를 담는다.
type Response struct {
	XMLName xml.Name `xml:"response"`
	Header  struct {
		ResultCode string `xml:"resultCode"`
		ResultMsg  string `xml:"resultMsg"`
	} `xml:"header"`
	Body struct {
		Items struct {
			Item []RawItem `xml:"item"`
		} `xml:"items"`
		NumOfRows  int `xml:"numOfRows"`
		PageNo     int `xml:"pageNo"`
		TotalCount int `xml:"totalCount"`
	} `xml:"body"`
}

// ServiceErrorResponse는 인증 실패 등 서비스 레벨 오류 시 data.go.kr이
// 반환하는 별도 봉투 형식이다(도메인 응답과 XML 구조 자체가 다름).
type ServiceErrorResponse struct {
	XMLName      xml.Name `xml:"OpenAPI_ServiceResponse"`
	CmmMsgHeader struct {
		ErrMsg           string `xml:"errMsg"`
		ReturnAuthMsg    string `xml:"returnAuthMsg"`
		ReturnReasonCode string `xml:"returnReasonCode"`
	} `xml:"cmmMsgHeader"`
}

// NormalizedStatusEvent는 충전기의 표준화된 상태 이벤트 한 건이다.
// 시간 필드는 전부 UTC(normalize 단계에서 KST→UTC 변환).
type NormalizedStatusEvent struct {
	StatusRaw       string    // 원본 상태코드(stat) 그대로 보존
	Status          string    // x-code-mappings로 변환한 표준 ChargerStatus
	SourceUpdatedAt time.Time // statUpdDt 파싱값(UTC). zero면 소스가 시각 미제공
	CollectedAt     time.Time // 수집 시각(UTC)
}

// NormalizedCharger는 표준화된 개별 충전기다.
type NormalizedCharger struct {
	ExternalChargerID string   // statId + "#" + chgerId
	ChargerTypeRaw    string   // 원본 커넥터 코드(chgerType) 그대로 보존
	ChargerType       string   // x-code-mappings로 변환한 표준 ConnectorType
	ChargeSpeed       string   // x-speed-mapping으로 파생한 RAPID/SLOW/UNKNOWN
	MaxPowerKW        *float64 // output 파싱값(kW). 미상이면 nil
	ConnectorCodes    []string // DecomposeConnectorTypes(ChargerType)로 파생된 원자 커넥터 코드 목록
	Status            NormalizedStatusEvent
}

// NormalizedStation은 표준화된 충전소다. 같은 statId로 묶인 충전기 목록을 가진다.
type NormalizedStation struct {
	SourceStationID string // 소스 원본 충전소 ID(statId)
	StationName     string
	Address         string // addr (+ addrDetail은 필요 시 결합, 이번은 addr만)
	Lat             float64
	Lng             float64
	OperatingHours  string    // useTime
	UpdatedAt       time.Time // 소속 충전기들의 SourceUpdatedAt 최댓값(UTC)
	// CollectedAt은 이번 수집 배치가 이 station을 실제로 본 시각(UTC)이다.
	// 이벤트시간(UpdatedAt)과 무관하게 매 run마다 항상 채워지며 무조건 갱신된다
	// ("마지막으로 이 station을 수집한 시각"). station.last_collected_at으로 저장.
	CollectedAt time.Time
	// IsClosed는 원본 delYn='Y'(폐쇄 충전소) 여부다. 검증 실패가 아니라
	// 정당한 운영 상태이므로 station.is_closed 컬럼으로 반영한다.
	IsClosed bool
	// OperatorExternalID는 소스 사업자 식별자(busiId, trim)다. DB 계층이 이 값으로
	// operator/charging_network를 해석한다. 비어 있으면 미분류 fallback을 쓴다.
	OperatorExternalID string
	// OperatorName은 소스 사업자명(busiNm trim, 비면 bnm trim으로 fallback)이다.
	OperatorName string
	Chargers     []NormalizedCharger
}

// PipelineStatus는 1회 실행이 어떤 상태로 마무리됐는지 나타내는 종료 신호다.
// 로그(pipeline_summary)와 Redis(collector:last_run)에 실려, 운영자가 이번 실행이
// 전량 완주했는지 부분 완료/중단으로 끝났는지 명확히 구분할 수 있게 한다.
type PipelineStatus string

const (
	StatusComplete       PipelineStatus = "complete"        // 전량 정상 수집 완료
	StatusEmptyResponse  PipelineStatus = "empty_response"  // 빈 XML 응답(쿼터 소진 등)으로 즉시 중단
	StatusBudgetExceeded PipelineStatus = "budget_exceeded" // 전체 마감시간 초과/취소로 부분 완료
	StatusRecovered      PipelineStatus = "recovered"       // S3 수동 복구 모드로 적재
	StatusError          PipelineStatus = "error"           // 그 외 오류로 부분 완료/중단
)

// PipelineStats는 1회 실행의 단계별 건수를 모은 구조화 통계다.
// run_log 단계에서 CloudWatch Logs Insights가 집계할 수 있는 형태로 출력한다.
type PipelineStats struct {
	CollectedItems  int            // fetch로 수집한 총 item 수
	InvalidItems    int            // validate에서 걸러진 오류 item 수
	ValidItems      int            // 검증 통과 item 수
	NormalizedStns  int            // 정규화된 station 수
	UpsertedStns    int            // DB upsert 성공 station 수
	FailedStns      int            // DB upsert 실패(스킵) station 수
	CacheRefreshed  int            // 캐시 갱신 성공 station 수
	CacheFailedStns int            // 캐시 갱신 실패 station 수
	Status          PipelineStatus // 이번 실행의 종료 상태 신호
	// SkippedNewStations는 fast path에서 프리로드 매핑(StationChargerMap)에 없어
	// 통째로 스킵한 신규 station 수다(slow path에서는 항상 0 — 신규 station도 upsert함).
	SkippedNewStations int
	// SkippedNewChargers는 fast path에서 station은 있으나 charger가 프리로드 매핑에
	// 없어 스킵한 신규 charger 수다(slow path에서는 항상 0).
	SkippedNewChargers int
}

// ArchiveStats는 --mode=archive 1회 실행의 단계별 건수를 모은 구조화 통계다.
// PipelineStats와 성격이 달라(수집 파이프라인이 아니라 조회→S3업로드→삭제 배치)
// 별도 구조체로 둔다.
type ArchiveStats struct {
	ScannedRows  int  // SelectOldStatusHistory로 조회한 대상 행 수(배치 합계)
	ArchivedRows int  // S3 업로드까지 성공한 행 수
	DeletedRows  int  // RDS 삭제까지 성공한 행 수
	Batches      int  // 처리한 배치 수
	DryRun       bool // --archive-dry-run이면 true(업로드/삭제 없이 대상 건수만 집계)
}
