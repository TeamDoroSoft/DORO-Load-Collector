// lock.go는 cron/systemd timer 겹침 방지용 flock 관련 함수를 담는다.
package main

import (
	"fmt"
	"log"
	"os"
	"syscall"
)

// lockDir는 flock 파일들의 배포 환경 고정 디렉터리다.
const lockDir = "/var/run"

// lockPathForMode는 모드(fast/slow/archive)별 flock 파일 경로를 만든다. 경로를
// 분리해야 fast/slow/archive가 서로 막지 않고 동시에 실행될 수 있다(설계 결정 §3).
func lockPathForMode(mode string) string {
	return fmt.Sprintf("%s/ev-charger-collector-%s.lock", lockDir, mode)
}

// acquireLock은 path에 배타적 non-blocking flock을 건다.
// 이미 다른 프로세스가 잡고 있으면 ok=false를 반환한다(겹침 스킵 신호).
// 반환된 release를 호출하면 락 파일을 닫아 커널이 락을 해제한다. 프로세스가
// 비정상 종료해도 커널이 자동 해제하므로 stale lock 문제가 없다.
func acquireLock(path string) (release func(), ok bool) {
	f, err := os.OpenFile(path, os.O_CREATE|os.O_RDWR, 0o644)
	if err != nil {
		log.Printf("락 파일 열기 실패(%s): %v", path, err)
		return func() {}, false
	}
	if err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX|syscall.LOCK_NB); err != nil {
		// EWOULDBLOCK 등: 이미 다른 실행이 락을 보유 중.
		_ = f.Close()
		return func() {}, false
	}
	return func() {
		_ = syscall.Flock(int(f.Fd()), syscall.LOCK_UN)
		_ = f.Close()
	}, true
}
