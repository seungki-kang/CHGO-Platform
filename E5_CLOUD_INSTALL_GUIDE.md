# E5 Cloud Update 설치 안내

`E5_CLOUD_UPDATE.zip`을 해제한 뒤 `CHGO-Platform` 안의 내용을 기존 `D:\CHGO\Repository\CHGO-Platform\`에 병합합니다. 이 패키지는 `.github\workflows`, `scripts\ci`, 운영 안내문과 manifest만 추가합니다.

로컬 PostgreSQL 암호는 사용하지 않습니다. GitHub 비공개 저장소에 올린 후 Actions에서 `E5 PostgreSQL Runtime and Rollback Evidence`를 수동 실행합니다.

정상 완료 후 GitHub Actions 결과에서 `E5-PostgreSQL-Runtime-Evidence-<run_id>`를 내려받습니다. 이 증거의 예상 전체 상태는 `PARTIAL_PASS / production_gate OPEN`입니다.
