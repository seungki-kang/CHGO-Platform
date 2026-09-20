# C02 Update 설치 및 승인 안내

## 설치 위치

1. `C02_UPDATE.zip`을 `D:\CHGO\Archives\C02\`에 보관합니다.
2. ZIP을 임시 폴더에 해제합니다.
3. 해제된 `CHGO-Platform` 폴더 **안의 내용 전체**를 복사합니다.
4. `D:\CHGO\Repository\CHGO-Platform\`에 붙여넣고 병합/덮어쓰기를 허용합니다.
5. `CHGO-Platform\CHGO-Platform` 이중 폴더가 생기지 않도록 합니다.

## 검증

저장소 루트에서 실행:

`python tools\validation\validate_c02_policy.py`

정상 후보 상태는 `static_structure: PASS`, `production_gate: OPEN`입니다. `OPEN`은 실패가 아니라 승인 전 안전 상태입니다.

## 승인 방법

법률 및 운영 검토가 끝난 뒤 다음 두 CSV에 승인자 실명과 UTC 승인 시각을 기록합니다.

- `registry\C02_privacy_policy_decision_register_1.0.csv`
- `localization\regional-compliance\C02_regional_privacy_policy_matrix_1.0.csv`

런타임 증거까지 확보하기 전에는 증거 JSON의 gate를 임의로 `CLOSED`로 바꾸지 않습니다.
