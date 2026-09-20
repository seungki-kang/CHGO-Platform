# CHGO Ecosystem Master Roadmap 2.0

상태: EXECUTION BASELINE CANDIDATE  
기준일: 2026-09-21  
최상위 의미 기준: JesusLife Canonical  
저장소 기준: CHGO-Platform GitHub Baseline Candidate 2.0

## 1. 실행 결론

CHGO는 모든 기능을 한 앱에 넣지 않는다. 하나의 계정과 공통 API 계약을 사용하되, 디지털 생명일기와 CHGO 성장 엔진, Church OS, BibleON, 기도 플랫폼은 독립된 제품 경계를 유지하고 단계적으로 연결한다.

첫 사용자 제품은 디지털 생명일기 MVP다. 그 전에 한 번 가입, 교회 소속 연결, 제품별 동의, Personal Vault 권한을 짧은 공통 계약으로 고정한다. 복잡한 Ontology와 데이터 처리는 엔진 내부에 두고 사용자 화면은 단순하게 유지한다.

## 2. 제품 체계

| 영역 | 역할 | 사용자 경험 | 데이터 원칙 |
|---|---|---|---|
| Shared Identity | 한 번 가입, SSO, 동의·세션 관리 | 하나의 간단한 로그인 | 제품별 동의와 권한 분리 |
| Digital Life Diary | 7문항 성찰과 개인 성장 기록 | 첫 번째 MVP | 원문은 Vault, 공유는 명시적 동의 |
| CHGO Engine | Canonical·Ontology·추론·성장 증거 | 앱 뒤에서 작동 | 영성 순위·단일 점수 금지 |
| Church OS | 교회·회원·그룹·코치·목회 운영 | 독립 제품 | 개인 원문 자동 공개 금지 |
| BibleON / Bible OS | 성경통독·지도·인물·연대 | 독립 제품 | 근거·판본·저작권 추적 |
| Prayer Platform | 개인기도·중보·기도방·응답 과정 | 독립 제품 | 민감정보와 공개범위 분리 |
| Integration Gateway | API·이벤트·웹훅 연결 | 사용자에게 숨김 | 제품 간 직접 DB 접근 금지 |

ZOENX는 법인과 생태계 운영 주체다. 소비자에게 모든 내부 기술 이름을 노출하지 않으며 최종 제품명은 브랜드·상표 검토 후 확정한다.

## 3. 사용자 경험 불변 원칙

1. 사용자는 최초 한 번만 계정을 만든다.
2. 다른 제품을 처음 열면 기존 계정으로 로그인하도록 안내한다.
3. 제품마다 필요한 추가 동의만 짧게 받는다.
4. 개인은 교회가 나중에 가입해도 초대 링크, 교회 코드 또는 관리자 승인으로 소속을 연결한다.
5. 교회 membership과 개인 Vault 열람 권한은 완전히 별개다.
6. 사용자는 교회 소속을 변경하거나 연결 해제할 수 있다.
7. 화면은 단순하게, 엔진은 정교하게 설계한다.

## 4. 현재 위치

| 항목 | 상태 | 판정 |
|---|---|---|
| 헌법·핵심철학·JesusLife 의미 기준 | 저장소 편입 | 완료 |
| GitHub 비공개 main 기준선 | 업로드 완료 | 완료 |
| Repository 정리·해시 인벤토리 | Candidate 2.0 | 완료 |
| B04 OpenAPI 정적 검증 | PASS | 완료 |
| C-02 구조 검증 | PASS, 승인 미완료 | 진행 필요 |
| E5 정적 회귀 | PASS | 완료 |
| E5 Runtime·Rollback 증거 | NOT_RUN | 진행 필요 |
| 독립 제품 경계 | 스켈레톤 | 완료 |
| 실행 가능한 앱과 엔진 | 초기 | 개발 필요 |

production_gate: OPEN은 개발 금지가 아니라 운영 배포 승인이 아직 남았다는 뜻이다.

## 5. 단계별 로드맵

### Phase 0 — Governance & GitHub Baseline

헌법, 철학, Canonical, 저장소 기준선을 고정한다. 중복 ZIP과 작업 중간본은 저장소 밖에 둔다.

현재 상태: **완료**

### Phase 1 — Shared Identity & Integration Foundation

- Global User ID와 제품별 Profile ID 분리
- OIDC 기반 SSO와 세션 계약
- 개인 계정, 교회 membership, 코치 assignment 분리
- 교회 초대 링크·코드·관리자 승인
- 제품별 동의와 철회
- API version, event envelope, webhook security
- SQLite 로컬 개발과 managed 운영 DB 경로 분리

종료 Gate: 한 계정으로 두 테스트 제품에 로그인하며, 교회 연결이 Vault 권한을 자동 생성하지 않는다.

### Phase 2 — Canonical & Ontology Runtime

- JesusLife source provenance registry
- Top-Level, Anchor, Life Diary, Growth, AI Reasoning registry
- 안정적인 Canonical ID와 semantic versioning
- CQ, invariant, SHACL 또는 동등 검증
- Canonical 원본과 runtime projection 분리

종료 Gate: 모든 runtime 의미가 승인 source/version으로 추적되고 build가 재현된다.

### Phase 3 — Digital Life Diary Pilot MVP

- 시즌·회차와 7문항 자유 이동
- 자동·임시 저장, 재개, 수정, 최종완성
- 고정 문장과 확정 용어 보호
- 1번→2번, 4번→1·2번 회귀
- Personal Vault와 구조화 데이터 분리
- 동의 기반 코치 나눔
- 한국어 입력·접근성·4주 파일럿

종료 Gate: 사용자가 실제 모바일 환경에서 안전하게 한 회차 전체를 완주하고 4주간 사용할 수 있다.

### Phase 4 — CHGO Growth Engine MVP

- Life Event → Reflection → Candidate → Confirmation → Evidence
- AI 질문 1~3개와 중단·전문가 인계
- 사용자 확인 전 Evidence 승격 금지
- 출처·모델·프롬프트·중단 이유 추적
- Frequency, Latency, Autonomy, Stability, Expression, Witness, Overflow 다축 표현
- Reduced Judgment와 Reduced Resistance 포함

종료 Gate: AI 추천과 사용자 의미가 분리되고 단일 영성점수·순위가 생성되지 않는다.

### Phase 5 — Church OS Independent MVP

- 교회 tenant, 회원, 그룹, 역할, 초대
- Today, Church, Grow, Community, Me
- 생명일기와 문답지·생명선언·설교 나눔의 두 경로
- Coach Dual Gate와 목회자 최소집단 집계
- white-label, headless API, SDK, webhook

종료 Gate: CHGO 장애 시에도 교회 기본운영이 가능하고 목회자는 개인 원문을 볼 수 없다.

### Phase 6 — BibleON

- 분류순·연대순 통독
- 지도, 인물관계, 족보, 왕·선지자, 시편 맥락
- Gospel Harmony, Jesus Journey, Paul Journey
- 구약은 오실 예수, 신약은 오신 예수, 전체는 하나님 나라라는 승인 해석축
- 근거 graph와 판본·저작권

종료 Gate: BibleON은 단독 사용 가능하며 동의된 최소 event만 CHGO에 전달한다.

### Phase 7 — Prayer Platform

- 개인기도 노트, 요청, 기도방, 알림
- 자녀기도, 작정·금식·릴레이·21일 기도
- 국가·주제별 글로벌 중보
- 응답뿐 아니라 과정·하나님의 뜻 발견·변화 기록
- 비공개 기본값, 익명화, 신고·안전운영

종료 Gate: 민감 기도 원문은 분리되고 동의된 최소 event만 CHGO에 전달된다.

### Phase 8 — Unified Experience & Business

- 통합 홈 또는 제품 전환기
- 한 번 로그인과 통합 알림
- 무료회원 quota와 abuse 방지
- 개인 Premium, 교회 구독, Academy·Coach license, API·white-label
- 비용 관찰, 고객지원, 장애 대응

종료 Gate: 제품 전환 시 재가입이 없고 무료회원 비용 상한이 작동한다.

### Phase 9 — Regional Pilot & Global Expansion

우선순위는 한국 → 멕시코 → 일본 → 영어권 → 기타 남미다. 각 지역은 번역 외에도 신학, 개인정보, UX, 지원, 현지 교회 파일럿 Gate를 독립적으로 통과한다.

## 6. 향후 90일

| 순서 | 작업 | 결과물 |
|---:|---|---|
| 1 | Shared Identity·membership 계약 | Identity & Membership Contract 1.0 |
| 2 | 제품별 동의·Vault 경계 | Consent & Vault Boundary 1.0 |
| 3 | API·event·webhook 공통 규칙 | Integration Contract 1.0 |
| 4 | Canonical source provenance | Canonical Registry 1.0 |
| 5 | Life Diary runtime projection | Life Diary Runtime Schema 1.0 |
| 6 | 생명일기 화면 흐름 | UX Flow & Acceptance 1.0 |
| 7 | SQLite 로컬 MVP skeleton | 실행 가능한 앱 |
| 8 | 저장·재개·완료·회귀 구현 | 통합 테스트 |
| 9 | Vault adapter와 최소 consent | privacy negative test |
| 10 | 4주 파일럿 준비 | Pilot Operations Pack 1.0 |

## 7. 다음 공식 작업

다음 작업은 **F1 Shared Identity, Membership and Product Consent Contract 1.0**이다. 이것을 먼저 고정해야 한 번 가입, 개인에서 교회로의 연결, BibleON·기도 플랫폼·Church OS의 중복 가입 없는 연동이 가능하다.

이와 병행하여 생명일기 MVP 화면과 SQLite 로컬 개발환경을 시작한다. PostgreSQL 없이 로컬 MVP 개발은 가능하고, 운영 배포 전 managed DB 환경에서 runtime과 rollback 증거를 별도로 닫는다.

