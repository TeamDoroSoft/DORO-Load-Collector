// Package keypool은 공공데이터포털 서비스키 여러 개를 라운드로빈 풀로 관리한다.
// 환경부 EvCharger 서비스키는 하루 호출 한도(1,000회)가 있어, 한 키가 소진되면
// 다음 키로 자동 전환해야 fast/slow path가 계속 동작할 수 있다.
//
// fast/slow 두 프로세스가 동시에 돌 수 있으므로 "현재 몇 번째 키를 쓰는지" 상태를
// 로컬 JSON 파일에 flock으로 보호해 공유한다. 날짜가 바뀌면(공공데이터포털 쿼터
// 리셋 시점을 자정 KST로 가정 — 미확정이므로 이 패키지에서만 예외적으로 KST를
// 쓰고, 그 외 프로젝트 전체는 UTC로 통일돼 있다) 인덱스를 0으로 리셋한다.
//
// 로그에는 인덱스만 남기고 키 값 자체는 절대 출력하지 않는다(기존 관례 유지).
package keypool

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

// kstZone은 KST(UTC+9) 고정 오프셋이다. 한국은 서머타임이 없어 time.LoadLocation으로
// tzdata 파일에 의존하지 않고 FixedZone으로 안전하게 표현할 수 있다(최소 컨테이너
// 이미지에도 tzdata가 없을 수 있어 이 방식이 더 견고하다).
var kstZone = time.FixedZone("KST", 9*60*60)

// poolState는 statePath에 저장되는 공유 상태다.
type poolState struct {
	Date      string `json:"date"`      // KST 기준 YYYY-MM-DD. 날짜가 바뀌면 Index를 0으로 리셋.
	Index     int    `json:"index"`     // 현재 사용 중인 키 인덱스(풀 크기로 정규화해서 사용).
	UpdatedAt string `json:"updatedAt"` // 마지막 갱신 시각(UTC RFC3339, 디버깅용).
}

// Pool은 서비스키 라운드로빈 풀이다.
type Pool struct {
	keys      []string
	statePath string
}

// New는 keys(최소 1개)와 상태 파일 경로로 Pool을 만든다.
func New(keys []string, statePath string) (*Pool, error) {
	if len(keys) == 0 {
		return nil, errors.New("keypool: 서비스키가 최소 1개 이상 필요합니다")
	}
	if statePath == "" {
		return nil, errors.New("keypool: 상태 파일 경로가 비어 있습니다")
	}
	return &Pool{keys: keys, statePath: statePath}, nil
}

// Size는 풀에 등록된 키 개수다.
func (p *Pool) Size() int { return len(p.keys) }

// Current는 현재 사용해야 할 키의 인덱스와 값을 반환한다. 날짜가 KST 기준으로
// 바뀌었으면 인덱스를 0으로 리셋하고 그 결과를 상태 파일에 반영한다.
func (p *Pool) Current(ctx context.Context) (int, string, error) {
	if ctx != nil {
		if err := ctx.Err(); err != nil {
			return 0, "", err
		}
	}
	st, err := p.withStateLock(func(st *poolState) (bool, error) {
		return resetIfNewDay(st, time.Now()), nil
	})
	if err != nil {
		return 0, "", fmt.Errorf("keypool: 상태 조회 실패: %w", err)
	}
	idx := normalizeIndex(st.Index, len(p.keys))
	return idx, p.keys[idx], nil
}

// Advance는 다음 키로 전환한다. CAS 유사 동작: 호출 시점에 관찰한 idx가 이미
// 다른 프로세스에 의해 전진해 있으면 그 값을 그대로 채택하고(추가 전진 없음),
// 아직 idx 그대로면 다음 키로 1 전진시킨다. 두 프로세스가 동시에 Advance를
// 호출해도 flock 덕분에 결과적으로 한 번만 전진한다(이중전진 방지).
func (p *Pool) Advance(ctx context.Context, idx int) (int, string, error) {
	if ctx != nil {
		if err := ctx.Err(); err != nil {
			return 0, "", err
		}
	}
	n := len(p.keys)
	st, err := p.withStateLock(func(st *poolState) (bool, error) {
		if resetIfNewDay(st, time.Now()) {
			// 날짜가 바뀌어 이미 0으로 리셋됐으면 그 자체가 "전진"이므로 더 진행하지 않는다.
			return true, nil
		}
		cur := normalizeIndex(st.Index, n)
		if cur != idx {
			// 이미 다른 프로세스가 전진시켰다 — 그 값을 그대로 채택.
			return false, nil
		}
		st.Index = normalizeIndex(idx+1, n)
		return true, nil
	})
	if err != nil {
		return 0, "", fmt.Errorf("keypool: 상태 전진 실패: %w", err)
	}
	newIdx := normalizeIndex(st.Index, n)
	return newIdx, p.keys[newIdx], nil
}

// normalizeIndex는 i를 [0, n) 범위로 정규화한다(음수 방어 포함).
func normalizeIndex(i, n int) int {
	if n <= 0 {
		return 0
	}
	m := i % n
	if m < 0 {
		m += n
	}
	return m
}

// resetIfNewDay는 오늘 KST 날짜와 st.Date가 다르면 인덱스를 0으로 리셋하고 true를
// 반환한다(상태 파일에 반영이 필요함을 알리는 mutated 신호).
func resetIfNewDay(st *poolState, now time.Time) bool {
	today := now.In(kstZone).Format("2006-01-02")
	if st.Date == today {
		return false
	}
	st.Date = today
	st.Index = 0
	return true
}

// withStateLock은 statePath 파일을 배타적 flock으로 잠근 채 fn을 실행한다. fn이
// true(mutated)를 반환하면 갱신된 상태를 파일에 다시 쓴다. flock은 블로킹(LOCK_EX)
// 방식이라 동시에 여러 프로세스가 호출해도 순서대로 처리되며 유실되지 않는다.
func (p *Pool) withStateLock(fn func(st *poolState) (bool, error)) (*poolState, error) {
	if err := os.MkdirAll(filepath.Dir(p.statePath), 0o755); err != nil {
		return nil, fmt.Errorf("상태 파일 디렉터리 생성 실패: %w", err)
	}
	f, err := os.OpenFile(p.statePath, os.O_CREATE|os.O_RDWR, 0o644)
	if err != nil {
		return nil, fmt.Errorf("상태 파일 열기 실패: %w", err)
	}
	defer f.Close()

	if err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX); err != nil {
		return nil, fmt.Errorf("상태 파일 flock 실패: %w", err)
	}
	defer func() { _ = syscall.Flock(int(f.Fd()), syscall.LOCK_UN) }()

	data, err := io.ReadAll(f)
	if err != nil {
		return nil, fmt.Errorf("상태 파일 읽기 실패: %w", err)
	}

	var st poolState
	if len(data) > 0 {
		if uerr := json.Unmarshal(data, &st); uerr != nil {
			// 손상된 상태 파일은 치명적으로 다루지 않는다 — 0부터 다시 시작하는 게
			// 쿼터를 소량 낭비할지언정 전체 파이프라인을 막는 것보다 안전하다.
			st = poolState{}
		}
	}

	mutated, ferr := fn(&st)
	if ferr != nil {
		return nil, ferr
	}
	if mutated {
		st.UpdatedAt = time.Now().UTC().Format(time.RFC3339)
		out, merr := json.MarshalIndent(&st, "", "  ")
		if merr != nil {
			return nil, fmt.Errorf("상태 인코딩 실패: %w", merr)
		}
		if _, serr := f.Seek(0, io.SeekStart); serr != nil {
			return nil, fmt.Errorf("상태 파일 seek 실패: %w", serr)
		}
		if terr := f.Truncate(0); terr != nil {
			return nil, fmt.Errorf("상태 파일 truncate 실패: %w", terr)
		}
		if _, werr := f.Write(out); werr != nil {
			return nil, fmt.Errorf("상태 파일 쓰기 실패: %w", werr)
		}
	}
	return &st, nil
}

// ParseKeys는 EVCHARGER_SERVICE_KEYS(콤마 구분, 우선) / EVCHARGER_SERVICE_KEY(단수,
// 하위호환 폴백) 두 값을 받아 공백 제거·빈 항목 제거된 키 목록을 반환한다.
// keysCSV가 비어 있으면 singleKey(비어있지 않은 경우) 하나짜리 목록을 반환한다.
func ParseKeys(keysCSV, singleKey string) []string {
	var raw []string
	if keysCSV != "" {
		for _, part := range strings.Split(keysCSV, ",") {
			part = strings.TrimSpace(part)
			if part != "" {
				raw = append(raw, part)
			}
		}
	}
	if len(raw) == 0 && strings.TrimSpace(singleKey) != "" {
		raw = []string{strings.TrimSpace(singleKey)}
	}
	return raw
}
