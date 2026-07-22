// archive.go(main 패키지)는 --mode=archive 오케스트레이션이다. charger_status_history의
// 오래된 행을 S3에 JSON으로 내보내고 RDS에서 삭제하는 콜드 아카이브 배치다. RDS
// 자체 백업이 아니다(RDS 자동 스냅샷에 별도로 의존 — 이 작업 범위 밖). 부수적으로
// 백업 효과가 있을 뿐이다.
//
// WHERE collected_at < cutoff 조건 자체가 이미 멱등적 재개 조건이라 별도 체크포인트
// 파일이 필요 없다 — 중단돼도 다음 실행이 남은 대상부터 자연 재개한다.
package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"ev-charger-collector/internal/db"
	"ev-charger-collector/internal/model"
)

// archiveDefaultTimeout은 archive 실행의 기본 마감시간이다. --archive-max-batches로
// 한 실행의 상한을 두더라도(타임아웃 내 종료 보장용) 배치 수가 많으면 오래 걸릴 수
// 있어 넉넉하게 잡는다. --timeout 플래그로 배포 시 조정 가능하다(0이면 이 기본값 사용).
const archiveDefaultTimeout = 30 * time.Minute

// archiveConfig는 runArchive에 필요한 입력을 모은다.
type archiveConfig struct {
	OutputDir     string
	OlderThanDays int
	BatchSize     int
	MaxBatches    int
	DryRun        bool
	Timeout       time.Duration
}

// runArchive는 charger_status_history 콜드 아카이브를 실행한다.
func runArchive(cfg archiveConfig) {
	// 1) archive 전용 flock(fast/slow와 별도 — 서로 막지 않고 동시 실행 가능).
	lockPath := lockPathForMode("archive")
	release, ok := acquireLock(lockPath)
	if !ok {
		log.Printf("이전 archive 실행이 진행 중이라 이번 실행을 스킵한다(flock=%s)", lockPath)
		os.Exit(0)
	}
	defer release()

	dbCfg, missing := dbConfigFromEnv()
	if len(missing) > 0 {
		log.Fatalf("필수 DB 환경변수 누락: %v", missing)
	}
	// dry-run이 아니면 S3 업로드가 필수 목적지이므로 시작 전에 미리 검증한다
	// (배치를 다 돌고 나서야 S3 미설정을 발견하면 그만큼 낭비다).
	if !cfg.DryRun && os.Getenv("S3_BUCKET") == "" {
		log.Fatal("아카이브에는 환경변수 S3_BUCKET이 필수입니다(--archive-dry-run 제외).")
	}

	baseCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()
	ctx, cancel := context.WithTimeout(baseCtx, cfg.Timeout)
	defer cancel()

	database, err := db.Open(dbCfg)
	if err != nil {
		log.Fatalf("DB 연결 실패: %v", err)
	}
	defer database.Close()
	if err := database.Ping(ctx); err != nil {
		log.Fatalf("DB Ping 실패: %v", err)
	}

	stor := newStorage(ctx, cfg.OutputDir)

	cutoff := time.Now().UTC().AddDate(0, 0, -cfg.OlderThanDays)
	runDate := time.Now().UTC()
	var stats model.ArchiveStats
	stats.DryRun = cfg.DryRun

	if cfg.DryRun {
		runArchiveDryRun(ctx, database, cutoff, cfg, &stats)
	} else {
		runArchiveBatches(ctx, database, stor, cutoff, runDate, cfg, &stats)
	}

	log.Printf("archive_summary dry_run=%v scanned=%d archived=%d deleted=%d batches=%d cutoff=%s",
		stats.DryRun, stats.ScannedRows, stats.ArchivedRows, stats.DeletedRows, stats.Batches, cutoff.Format(time.RFC3339))
}

// runArchiveDryRun은 삭제 없이 대상 건수만 확인한다. SelectOldStatusHistory가 삭제로
// 자연 진행하는 페이지네이션이라(archive.go의 db.SelectOldStatusHistory 문서 참고),
// 삭제가 없는 dry-run에서 같은 조회를 반복하면 매번 같은 행이 잡혀 무한히 같은
// 배치를 세게 된다. 그래서 dry-run은 한 번만, "배치크기 × 최대배치수"를 상한으로
// 조회해 대상 건수를 확인한다(그 상한에 도달하면 실제로는 더 많을 수 있다고 로그로 알린다).
func runArchiveDryRun(ctx context.Context, database *db.DB, cutoff time.Time, cfg archiveConfig, stats *model.ArchiveStats) {
	limit := cfg.BatchSize * cfg.MaxBatches
	rows, err := database.SelectOldStatusHistory(ctx, cutoff, limit)
	if err != nil {
		log.Fatalf("아카이브 대상 조회 실패(dry-run): %v", err)
	}
	stats.ScannedRows = len(rows)
	stats.Batches = 1

	if len(rows) >= limit {
		log.Printf("[dry-run] 아카이브 대상 %d건 확인(cutoff=%s) — 조회 상한(%d)에 도달해 실제로는 더 많을 수 있음",
			len(rows), cutoff.Format(time.RFC3339), limit)
		return
	}
	log.Printf("[dry-run] 아카이브 대상 %d건 확인(cutoff=%s)", len(rows), cutoff.Format(time.RFC3339))
}

// runArchiveBatches는 조회→S3 업로드→RDS 삭제를 배치 단위로 반복한다. 업로드가
// 성공한 배치만 삭제한다(원본 보존 성공 후에만 다음 단계로 가는 기존 원칙과 동일 —
// PersistRawPage와 같은 순서 원칙).
func runArchiveBatches(ctx context.Context, database *db.DB, stor archiveStorage, cutoff, runDate time.Time, cfg archiveConfig, stats *model.ArchiveStats) {
	for batchSeq := 1; batchSeq <= cfg.MaxBatches; batchSeq++ {
		if err := ctx.Err(); err != nil {
			log.Printf("[warn] 아카이브 예산 초과/취소 — 중단(batch=%d): %v", batchSeq, err)
			return
		}

		rows, err := database.SelectOldStatusHistory(ctx, cutoff, cfg.BatchSize)
		if err != nil {
			log.Fatalf("아카이브 대상 조회 실패(batch=%d): %v", batchSeq, err)
		}
		if len(rows) == 0 {
			log.Printf("아카이브 대상 소진 — 종료(batch=%d에서 0건)", batchSeq)
			return
		}
		stats.ScannedRows += len(rows)
		stats.Batches++

		// 원본(S3) 보존이 성공한 뒤에만 RDS에서 삭제한다 — 순서를 반대로 두면
		// "RDS는 지웠는데 S3엔 없는" 유실 창구가 생긴다.
		if err := stor.PersistHistoryArchiveBatch(ctx, rows, runDate, batchSeq); err != nil {
			log.Fatalf("아카이브 배치 S3 업로드 실패(batch=%d) — 원본 보존 실패로 중단(이 배치는 삭제하지 않음): %v", batchSeq, err)
		}
		stats.ArchivedRows += len(rows)

		ids := make([]int64, len(rows))
		for i, r := range rows {
			ids[i] = r.StatusID
		}
		n, err := database.DeleteStatusHistoryByIDs(ctx, ids)
		if err != nil {
			log.Fatalf("아카이브 배치 RDS 삭제 실패(batch=%d, S3 업로드는 이미 완료됨): %v", batchSeq, err)
		}
		stats.DeletedRows += int(n)

		log.Printf("아카이브 batch=%d 처리 완료: %d건(S3 업로드 + RDS 삭제)", batchSeq, len(rows))

		if len(rows) < cfg.BatchSize {
			// 배치 크기보다 적게 나왔다는 건 대상이 소진됐다는 뜻 — 다음 루프에서
			// 어차피 0건으로 자연 종료되지만, 여기서 끝내 쿼리 1회를 절약한다.
			return
		}
	}
	log.Printf("[warn] --archive-max-batches(%d) 상한에 도달해 이번 실행을 종료한다(다음 실행이 이어서 처리)", cfg.MaxBatches)
}

// archiveStorage는 runArchiveBatches가 필요로 하는 storage.Storage의 최소 표면이다
// (패키지 순환 없이 이 파일에서 인터페이스로만 선언).
type archiveStorage interface {
	PersistHistoryArchiveBatch(ctx context.Context, rows []db.ArchivableHistoryRow, runDate time.Time, batchSeq int) error
}
