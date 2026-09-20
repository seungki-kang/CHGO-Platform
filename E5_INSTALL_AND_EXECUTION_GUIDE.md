# E5 업데이트 설치 및 실행

1. `E5_UPDATE.zip`을 `D:\CHGO\Archives\E5\`에 저장합니다.
2. 임시 폴더에 압축을 해제합니다.
3. 해제된 `CHGO-Platform` 안의 내용 전체를 `D:\CHGO\Repository\CHGO-Platform\`에 병합합니다.
4. 저장소 루트에서 `python tools\validation\validate_e5_regression.py`를 실행합니다.

정상 준비 결과는 `static_regression: PASS`, `runtime_regression: NOT_RUN`, `production_gate: OPEN`, `errors: []`입니다. `NOT_RUN`과 `OPEN`은 실제 DB/API/rollback 실행 증거가 아직 없다는 정직한 상태입니다.
