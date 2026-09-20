# Roadmap 2.0 Update 설치

이 업데이트는 Canonical 의미를 변경하지 않는다. 전체 로드맵, 실행 백로그, Change Object와 CHANGELOG만 추가·갱신한다.

## 포함 파일

- docs/roadmap/CHGO_Ecosystem_Master_Roadmap_2.0.md
- backlog/CHGO_Execution_Backlog_2.0.csv
- changes/CHGO_CHANGE_OBJECT_ROADMAP_2.0.json
- CHANGELOG.md
- REPOSITORY_MANIFEST_CANDIDATE_2.1.csv
- registry/repository_file_inventory_2.1.csv

## Windows 적용

업데이트 ZIP 안의 CHGO-Platform 폴더를 D:\CHGO-Platform에 덮어쓴다. 이 팩은 새 파일과 교체 파일만 포함한다.

적용 후 다음을 실행한다.

    cd /d D:\CHGO-Platform
    git add .
    git commit -m "Add CHGO ecosystem master roadmap 2.0"
    git push

