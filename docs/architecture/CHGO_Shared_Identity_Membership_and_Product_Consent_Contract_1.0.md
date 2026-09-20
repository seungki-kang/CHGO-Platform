# CHGO Shared Identity, Membership and Product Consent Contract 1.0

상태: CANDIDATE  
작업 ID: F1-001~F1-005  
Canonical 변경: 없음  
목적: 한 번 가입, 독립 제품 로그인, 개인→교회 연결, 제품별 동의와 Vault 권한 분리를 구현 가능한 계약으로 고정한다.

## 1. 핵심 결정

1. 한 사람은 생태계 전체에서 하나의 Global User ID를 가진다.
2. 각 제품은 별도의 Product Profile을 가질 수 있으나 계정을 다시 만들지 않는다.
3. Church Membership은 교회 소속 관계이며 데이터 열람 권한이 아니다.
4. Life Diary Vault Access Grant는 별도 명시적 동의와 목적·범위·기간을 요구한다.
5. 가입, 교회 소속, 코치 배정, Vault 공유, 목회자 집계는 서로 다른 상태 객체다.
6. 제품 간에는 API와 versioned event만 사용하고 서로의 데이터베이스를 직접 읽지 않는다.

## 2. 사용자에게 보이는 경험

### 처음 가입

이메일, 휴대전화 또는 승인된 외부 로그인으로 계정 하나를 만든다. 사용자는 가입 시 특정 교회를 선택하지 않아도 된다.

### 다른 제품 첫 사용

“이미 계정이 있으신가요?”를 기본으로 보여주고 기존 계정 로그인을 우선한다. 새 제품에서 꼭 필요한 추가 약관과 동의만 받는다.

### 교회가 나중에 가입한 경우

사용자는 다음 중 하나로 교회 연결을 요청한다.

- 교회가 보낸 만료시간이 있는 초대 링크
- 교회 코드 입력 후 관리자 승인
- 교회 관리자가 보낸 특정 사용자 초대

연결 전에는 개인 사용자이며, 승인 후에도 개인 기록의 소유권과 Vault 기본 비공개 상태는 유지된다.

## 3. 식별자

| 객체 | 식별자 예 | 범위 | 외부 노출 |
|---|---|---|---|
| Global User | usr_01... | 생태계 전체 | 토큰 subject로 제한 노출 |
| Product Profile | prf_01... | 제품별 | 해당 제품만 |
| Church Tenant | ch_01... | 교회 조직 | 허용 |
| Membership | mem_01... | 사용자-교회 관계 | 당사자와 관리자 |
| Coach Assignment | coa_01... | 코치 관계 | 관계 당사자 |
| Consent Receipt | con_01... | 사용자·제품·목적 | 사용자와 감사 권한 |
| Access Grant | grt_01... | 자료·수신자·범위·기간 | 당사자와 감사 권한 |

이메일과 전화번호를 도메인 식별자로 사용하지 않는다. 변경 가능한 로그인 주소와 안정적인 내부 ID를 분리한다.

## 4. 상태 모델

### Membership

PENDING_INVITE → PENDING_USER_ACCEPTANCE → ACTIVE → SUSPENDED 또는 LEFT

교회 코드 방식은 PENDING_REVIEW → ACTIVE 흐름을 추가한다. 교회 탈퇴는 계정 삭제가 아니다.

### Product Consent

NOT_GRANTED → GRANTED → REVOKED

새 목적이나 중요 정책 변경은 기존 동의를 자동 확장하지 않고 새 version의 동의를 받는다.

### Vault Access Grant

DRAFT → ACTIVE → EXPIRED 또는 REVOKED

Membership이 ACTIVE여도 Grant가 없으면 Vault 접근은 거부된다.

## 5. 필수 불변규칙

- INV-IDENTITY-01: 사용자는 제품마다 새 Global User를 만들지 않는다.
- INV-IDENTITY-02: 계정 병합은 감사 가능한 절차 없이는 수행하지 않는다.
- INV-MEMBERSHIP-01: Membership은 Vault 권한을 암시하지 않는다.
- INV-MEMBERSHIP-02: 교회 관리자는 사용자의 교회 탈퇴를 계정 삭제로 처리할 수 없다.
- INV-CONSENT-01: 동의는 제품, 목적, 데이터 범주, 정책 version으로 제한한다.
- INV-CONSENT-02: 철회 후 미래 접근을 즉시 차단한다.
- INV-GRANT-01: Vault Grant는 수신자, 범위, 목적, 기간을 모두 가진다.
- INV-GRANT-02: 목회자 역할만으로 개인 원문 접근을 허용하지 않는다.
- INV-AGGREGATE-01: 목회자 통계는 최소집단과 secondary suppression을 통과한다.
- INV-API-01: 제품 간 직접 DB 접근을 금지한다.

## 6. 토큰과 권한

공통 로그인 토큰은 최소 claim만 담는다.

- sub: Global User ID
- session_id
- authentication assurance
- issued_at / expires_at

교회 역할, 제품 권한, Vault 권한을 장기 토큰에 고정하지 않는다. 각 서비스가 현재 membership·consent·grant 상태를 권한 서비스에서 확인한다.

## 7. API 최소계약

| Method | Path | 목적 |
|---|---|---|
| POST | /v1/identity/registrations | 최초 계정 생성 |
| POST | /v1/identity/sessions | 로그인 |
| GET | /v1/me/products | 사용 가능한 제품과 추가 동의 상태 |
| POST | /v1/churches/{church_id}/membership-requests | 교회 코드 가입 요청 |
| POST | /v1/membership-invitations/{token}/accept | 교회 초대 수락 |
| GET | /v1/me/memberships | 내 교회 소속 |
| POST | /v1/memberships/{membership_id}/leave | 교회 연결 해제 |
| POST | /v1/consents | 제품별 동의 |
| POST | /v1/consents/{consent_id}/revoke | 동의 철회 |
| POST | /v1/vault/grants | 제한적 공유 권한 생성 |
| POST | /v1/vault/grants/{grant_id}/revoke | 공유 즉시 철회 |

모든 변경 API는 idempotency key와 audit event를 남긴다.

## 8. 제품 연동 이벤트

최소 event:

- identity.user.created.v1
- product.profile.activated.v1
- church.membership.requested.v1
- church.membership.activated.v1
- church.membership.ended.v1
- consent.granted.v1
- consent.revoked.v1
- vault.grant.activated.v1
- vault.grant.revoked.v1

이벤트에는 원문 일기, 기도제목, 상담내용을 넣지 않는다. event_id, occurred_at, actor, subject, tenant, purpose, schema_version과 필요한 최소 참조만 포함한다.

## 9. 계정 중복 처리

동일 이메일이라는 이유만으로 자동 병합하지 않는다. 로그인 수단 검증, 사용자의 명시적 확인, 충돌 검토, 감사 기록을 거친다. 병합 전에는 두 계정의 Membership, Consent, Grant를 자동 합산하지 않는다.

## 10. 삭제와 탈퇴

- 제품 탈퇴: 해당 Product Profile과 동의를 종료한다.
- 교회 탈퇴: Membership만 종료한다.
- 계정 삭제: 법적 보존 예외를 제외한 전 제품 삭제 workflow를 시작한다.
- Vault 삭제: 별도 retention·backup·deletion propagation 증거를 요구한다.

## 11. 수용 테스트

1. 개인이 교회 없이 가입하고 Life Diary를 사용할 수 있다.
2. 같은 계정으로 두 번째 제품에 로그인하며 새 계정을 만들지 않는다.
3. 교회 초대 수락 후 Membership은 ACTIVE지만 Vault 접근은 DENY다.
4. 제한된 Grant를 생성하면 지정 수신자만 기간 안에 지정 범위를 본다.
5. Grant 철회 즉시 접근이 차단된다.
6. 교회 탈퇴 후 개인 계정과 개인 기록은 유지된다.
7. 목회자 집계가 최소집단 미만이면 SUPPRESSED다.
8. consent revoked event에 민감 원문이 포함되지 않는다.

## 12. 다음 구현

이 계약 다음에는 API schema와 로컬 reference implementation을 만든다. 첫 reference flow는 “개인 가입 → Life Diary 활성화 → 교회 초대 수락 → Vault 비공개 유지 → 선택적 코치 Grant”다.

