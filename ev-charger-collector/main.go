// Command ev-charger-collector는 한국환경공단 EvCharger(getChargerInfo) API를
// 페이지네이션 전량 수집한 뒤, 원본 보존(로컬/S3) → 검증 → 정규화 → RDS 적재 →
// Redis 캐시 갱신까지 처리하는 배치 도구다(Kafka 미사용).
//
// --mode 플래그로 세 가지 독립 파이프라인 중 하나를 실행한다(기본값 slow — 플래그
// 없는 기존 배포와 하위호환):
//
//   - slow(기본값, 주기 1~6시간): RDS(진실의 원천) upsert + 커밋된 station만 Redis 갱신.
//     기존(파일 분할 이전) main()과 100% 동일 동작. pipeline_slow.go의 runSlow 참고.
//   - fast(주기 수 분~수십 분): RDS에 쓰지 않고 기존 station/charger 매핑을 프리로드해
//     조회만 하고 Redis만 갱신. 신규 station/charger는 스킵. pipeline_fast.go의 runFast 참고.
//   - archive: charger_status_history의 오래된 행을 S3로 내보내고 RDS에서 삭제하는
//     콜드 아카이브. archive.go의 runArchive 참고.
//
// 서비스키는 internal/keypool.Pool로 라운드로빈 관리되며 fast/slow가 같은 풀을 공유한다.
//
// --recover-date 지정 시(slow 모드에서만 의미 있음)에는 API 수집 대신 S3에서 원본을
// 되읽어(RecoverRawPages) 이후 파이프라인을 재사용하는 수동 복구 모드로 동작한다.
package main

import (
	"flag"
	"log"
	"os"
	"time"

	"ev-charger-collector/internal/keypool"
)

func main() {
	mode := flag.String("mode", "slow", "실행 모드: fast|slow|archive (기본값 slow)")
	numOfRows := flag.Int("num-of-rows", 100, "페이지당 조회 건수(fast/slow 공용)")
	outputDir := flag.String("output-dir", "./output", "결과 저장 디렉터리")
	timeoutFlag := flag.Duration("timeout", 0, "전체 마감시간(0이면 모드별 기본값 사용: slow=9m30s, fast=4m, archive=30m, recover=30m)")

	// slow 전용: 수동 S3 복구 모드 플래그. --recover-date가 지정되면 API를 호출하지 않고
	// S3에 보존된 해당 날짜의 원본 XML을 되읽어 이후 파이프라인(검증→정규화→적재)을 재사용한다.
	recoverDate := flag.String("recover-date", "", "[slow 전용] S3 수동 복구 모드: 복구할 원본 날짜(YYYYMMDD). 지정 시 API 미호출.")
	recoverZcode := flag.String("recover-zcode", "", "[slow 전용] S3 수동 복구 모드: item 단위 필터링용 시도코드(선택, 비면 전체).")

	// archive 전용 플래그.
	archiveOlderThanDays := flag.Int("archive-older-than-days", 90, "[archive 전용] 이 일수보다 오래된 charger_status_history를 아카이브 대상으로 삼는다.")
	archiveBatchSize := flag.Int("archive-batch-size", 2000, "[archive 전용] 배치당 조회/삭제 건수.")
	archiveMaxBatches := flag.Int("archive-max-batches", 200, "[archive 전용] 한 실행에서 처리할 최대 배치 수(타임아웃 내 종료 보장용 상한).")
	archiveDryRun := flag.Bool("archive-dry-run", false, "[archive 전용] 업로드/삭제 없이 대상 건수만 확인.")
	flag.Parse()

	// 서비스키 풀 구성(fast/slow가 공유). archive는 API를 호출하지 않으므로 풀이 필요 없다.
	var pool *keypool.Pool
	if *mode == "fast" || *mode == "slow" {
		keys := keypool.ParseKeys(os.Getenv("EVCHARGER_SERVICE_KEYS"), os.Getenv("EVCHARGER_SERVICE_KEY"))
		if len(keys) == 0 {
			log.Fatal("환경변수 EVCHARGER_SERVICE_KEYS(콤마 구분) 또는 EVCHARGER_SERVICE_KEY가 설정되지 않았습니다.")
		}
		statePath := os.Getenv("EVCHARGER_KEYPOOL_STATE_PATH")
		if statePath == "" {
			statePath = "/var/lib/ev-charger-collector/keypool_state.json"
		}
		var perr error
		pool, perr = keypool.New(keys, statePath)
		if perr != nil {
			log.Fatalf("서비스키 풀 초기화 실패: %v", perr)
		}
		log.Printf("서비스키 풀 초기화 완료: %d개 키(state=%s)", pool.Size(), statePath)
	}

	// EVCHARGER_ZCODE는 선택적 시도(zcode) 필터다. 미설정 시 빈 문자열이 되어
	// 전국 전체를 수집한다(예: "11"이면 서울시 전체만 수집).
	zcode := os.Getenv("EVCHARGER_ZCODE")

	switch *mode {
	case "slow":
		timeout := resolveTimeout(*timeoutFlag, *mode, *recoverDate)
		runSlow(slowConfig{
			Pool:         pool,
			Zcode:        zcode,
			NumOfRows:    *numOfRows,
			OutputDir:    *outputDir,
			RecoverDate:  *recoverDate,
			RecoverZcode: *recoverZcode,
			Timeout:      timeout,
		})
	case "fast":
		timeout := resolveTimeout(*timeoutFlag, *mode, "")
		runFast(fastConfig{
			Pool:      pool,
			Zcode:     zcode,
			NumOfRows: *numOfRows,
			OutputDir: *outputDir,
			Timeout:   timeout,
		})
	case "archive":
		timeout := resolveTimeout(*timeoutFlag, *mode, "")
		runArchive(archiveConfig{
			OutputDir:     *outputDir,
			OlderThanDays: *archiveOlderThanDays,
			BatchSize:     *archiveBatchSize,
			MaxBatches:    *archiveMaxBatches,
			DryRun:        *archiveDryRun,
			Timeout:       timeout,
		})
	default:
		log.Fatalf("알 수 없는 --mode=%q (fast|slow|archive 중 하나여야 함)", *mode)
	}
}

// resolveTimeout은 --timeout이 명시됐으면 그 값을 그대로 쓰고, 0(미지정)이면
// 모드별 기본값을 적용한다. slow 모드에서 --recover-date가 지정된 경우엔
// slow의 일반 기본값 대신 더 긴 recoverTimeout을 쓴다(하루치 백로그 재적재는
// 정기 실행 마감시간으로는 부족할 수 있어서).
func resolveTimeout(flagVal time.Duration, mode, recoverDate string) time.Duration {
	if flagVal > 0 {
		return flagVal
	}
	switch mode {
	case "slow":
		if recoverDate != "" {
			return recoverTimeout
		}
		return slowDefaultTimeout
	case "fast":
		return fastDefaultTimeout
	case "archive":
		return archiveDefaultTimeout
	default:
		return slowDefaultTimeout
	}
}
