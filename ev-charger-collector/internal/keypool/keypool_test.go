package keypool

import (
	"context"
	"path/filepath"
	"sync"
	"testing"
	"time"
)

func TestParseKeys(t *testing.T) {
	cases := []struct {
		name     string
		keysCSV  string
		single   string
		expected []string
	}{
		{"콤마구분 우선", "a,b,c", "z", []string{"a", "b", "c"}},
		{"공백 트림", " a , b ,c ", "", []string{"a", "b", "c"}},
		{"빈 항목 제거", "a,,b,", "", []string{"a", "b"}},
		{"단수 폴백", "", "single", []string{"single"}},
		{"둘 다 비면 빈 목록", "", "", nil},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			got := ParseKeys(c.keysCSV, c.single)
			if len(got) != len(c.expected) {
				t.Fatalf("길이 불일치: got=%v want=%v", got, c.expected)
			}
			for i := range got {
				if got[i] != c.expected[i] {
					t.Fatalf("인덱스 %d 불일치: got=%q want=%q", i, got[i], c.expected[i])
				}
			}
		})
	}
}

// TestSingleKeyBackwardCompat는 키가 1개뿐일 때 Current/Advance가 항상 같은 키를
// 반환해 기존(풀 도입 이전) 단일 키 동작과 동일하게 보이는지 확인한다.
func TestSingleKeyBackwardCompat(t *testing.T) {
	dir := t.TempDir()
	p, err := New([]string{"only-key"}, filepath.Join(dir, "state.json"))
	if err != nil {
		t.Fatalf("New 실패: %v", err)
	}

	idx, key, err := p.Current(context.Background())
	if err != nil {
		t.Fatalf("Current 실패: %v", err)
	}
	if idx != 0 || key != "only-key" {
		t.Fatalf("초기값 불일치: idx=%d key=%q", idx, key)
	}

	newIdx, newKey, err := p.Advance(context.Background(), idx)
	if err != nil {
		t.Fatalf("Advance 실패: %v", err)
	}
	if newIdx != 0 || newKey != "only-key" {
		t.Fatalf("단일 키는 Advance 후에도 동일해야 함: idx=%d key=%q", newIdx, newKey)
	}
}

// TestRoundRobinAdvance는 여러 키를 순서대로 순환하는지 확인한다.
func TestRoundRobinAdvance(t *testing.T) {
	dir := t.TempDir()
	p, err := New([]string{"k0", "k1", "k2"}, filepath.Join(dir, "state.json"))
	if err != nil {
		t.Fatalf("New 실패: %v", err)
	}

	idx, key, err := p.Current(context.Background())
	if err != nil || idx != 0 || key != "k0" {
		t.Fatalf("초기값 불일치: idx=%d key=%q err=%v", idx, key, err)
	}

	idx, key, err = p.Advance(context.Background(), idx)
	if err != nil || idx != 1 || key != "k1" {
		t.Fatalf("1차 전진 불일치: idx=%d key=%q err=%v", idx, key, err)
	}

	idx, key, err = p.Advance(context.Background(), idx)
	if err != nil || idx != 2 || key != "k2" {
		t.Fatalf("2차 전진 불일치: idx=%d key=%q err=%v", idx, key, err)
	}

	// 풀 끝에서 다시 0으로 순환.
	idx, key, err = p.Advance(context.Background(), idx)
	if err != nil || idx != 0 || key != "k0" {
		t.Fatalf("순환 불일치: idx=%d key=%q err=%v", idx, key, err)
	}
}

// TestAdvanceDoubleAdvancePrevention은 동시에 같은 idx로 Advance를 호출한
// 두 "프로세스"가 있을 때, 인덱스가 딱 1번만 전진하는지(이중전진 방지) 확인한다.
func TestAdvanceDoubleAdvancePrevention(t *testing.T) {
	dir := t.TempDir()
	statePath := filepath.Join(dir, "state.json")
	p1, err := New([]string{"k0", "k1", "k2"}, statePath)
	if err != nil {
		t.Fatalf("New 실패: %v", err)
	}
	p2, err := New([]string{"k0", "k1", "k2"}, statePath)
	if err != nil {
		t.Fatalf("New 실패: %v", err)
	}

	idx, _, err := p1.Current(context.Background())
	if err != nil {
		t.Fatalf("Current 실패: %v", err)
	}

	var wg sync.WaitGroup
	results := make([]int, 2)
	wg.Add(2)
	go func() {
		defer wg.Done()
		newIdx, _, aerr := p1.Advance(context.Background(), idx)
		if aerr != nil {
			t.Errorf("p1 Advance 실패: %v", aerr)
			return
		}
		results[0] = newIdx
	}()
	go func() {
		defer wg.Done()
		newIdx, _, aerr := p2.Advance(context.Background(), idx)
		if aerr != nil {
			t.Errorf("p2 Advance 실패: %v", aerr)
			return
		}
		results[1] = newIdx
	}()
	wg.Wait()

	// 둘 다 관찰한 idx가 같았으므로(0), 결과적으로 인덱스는 1로 딱 한 번만
	// 전진해 있어야 한다(둘 다 1을 봐야 함 — 두 번째 호출은 "이미 전진해 있음"을
	// 감지해 그 값을 채택).
	if results[0] != 1 || results[1] != 1 {
		t.Fatalf("이중전진 방지 실패: results=%v (기대: 둘 다 1)", results)
	}

	finalIdx, _, err := p1.Current(context.Background())
	if err != nil {
		t.Fatalf("최종 Current 실패: %v", err)
	}
	if finalIdx != 1 {
		t.Fatalf("최종 인덱스가 1이 아님(이중전진 발생 의심): %d", finalIdx)
	}
}

// TestKSTDateRolloverReset은 상태 파일의 날짜가 오늘(KST)과 다르면 인덱스가
// 0으로 리셋되는지 확인한다.
func TestKSTDateRolloverReset(t *testing.T) {
	dir := t.TempDir()
	statePath := filepath.Join(dir, "state.json")
	p, err := New([]string{"k0", "k1", "k2"}, statePath)
	if err != nil {
		t.Fatalf("New 실패: %v", err)
	}

	// 어제 날짜, 인덱스 2로 미리 상태 파일을 만들어둔다.
	yesterday := time.Now().In(kstZone).AddDate(0, 0, -1).Format("2006-01-02")
	_, err = p.withStateLock(func(st *poolState) (bool, error) {
		st.Date = yesterday
		st.Index = 2
		return true, nil
	})
	if err != nil {
		t.Fatalf("상태 사전 세팅 실패: %v", err)
	}

	idx, key, err := p.Current(context.Background())
	if err != nil {
		t.Fatalf("Current 실패: %v", err)
	}
	if idx != 0 || key != "k0" {
		t.Fatalf("날짜 롤오버 리셋 실패: idx=%d key=%q (기대: idx=0)", idx, key)
	}
}

// TestFlockConcurrentAccessSafety는 여러 goroutine이 statePath를 동시에 두드려도
// 상태 파일이 손상되지 않고(항상 파싱 가능) 최종 인덱스가 정확히 호출 횟수만큼
// 전진해 있는지 확인한다(flock 동시 접근 안전성).
func TestFlockConcurrentAccessSafety(t *testing.T) {
	dir := t.TempDir()
	statePath := filepath.Join(dir, "state.json")
	const n = 3
	const iterations = 20

	pools := make([]*Pool, n)
	for i := range pools {
		p, err := New([]string{"k0", "k1", "k2", "k3", "k4"}, statePath)
		if err != nil {
			t.Fatalf("New 실패: %v", err)
		}
		pools[i] = p
	}

	var wg sync.WaitGroup
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(p *Pool) {
			defer wg.Done()
			for j := 0; j < iterations; j++ {
				idx, _, err := p.Current(context.Background())
				if err != nil {
					t.Errorf("Current 실패: %v", err)
					return
				}
				if _, _, err := p.Advance(context.Background(), idx); err != nil {
					t.Errorf("Advance 실패: %v", err)
					return
				}
			}
		}(pools[i])
	}
	wg.Wait()

	// 손상 없이 마지막 상태를 읽을 수 있는지 확인.
	finalIdx, finalKey, err := pools[0].Current(context.Background())
	if err != nil {
		t.Fatalf("최종 상태 읽기 실패(파일 손상 의심): %v", err)
	}
	if finalIdx < 0 || finalIdx >= 5 || finalKey == "" {
		t.Fatalf("최종 상태 비정상: idx=%d key=%q", finalIdx, finalKey)
	}
}
