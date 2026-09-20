# C-02 Production Privacy Policy Decision Gate 1.0

Status: **OPEN — READY_FOR_OWNER_APPROVAL**  
Decision date: 2026-09-14  
Canonical impact: **NONE**  
Production effect: **BLOCKED until every required approval and evidence item is complete**

## 1. Decision boundary

This record converts the existing Personal Vault principles into enforceable production defaults. It is an engineering and governance baseline, not jurisdiction-specific legal advice. A regional policy pack may strengthen these controls but may not weaken the Personal Vault ownership boundary.

Raw Life Diary content belongs to the user and is not a church record, membership asset, growth score, or administrator-readable field. Tenant membership, pastoral role, employment, support role, or database privilege never creates ownership or raw-content access.

## 2. Binding production defaults

| ID | Area | Production decision |
|---|---|---|
| C02-01 | Data classification | Raw diary, prayer/reflection text, inferred spiritual state, safety disclosure, and precise identity links are `RESTRICTED_VAULT`; derived aggregates must be non-reversible. |
| C02-02 | Storage boundary | Raw content is stored only as an encrypted provider object. The relational DB stores minimal metadata, pointer, key reference and lifecycle state; no raw body, prompt, completion, trace or log. |
| C02-03 | Residency/transfer | Raw Vault data remains in the approved market region by default. Foreign storage, support access, replication or model processing is blocked until the regional transfer row is approved and the user-facing notice/consent basis is implemented. |
| C02-04 | Retention | Active Vault content remains until user deletion or account lifecycle deletion. An account inactive for 24 months enters notice and a 30-day grace period. Regional law or legal hold can override only through a recorded policy exception. |
| C02-05 | Deletion | Verified deletion starts immediately; active systems and processors complete within 30 days. Backup copies expire within 90 days. Tombstones and restore reconciliation prevent resurrection. Completion evidence contains identifiers and timestamps, never raw content. |
| C02-06 | Export | User export is encrypted, available for 24 hours, and protected by a single-use/15-minute download credential. Export events are audited without content. |
| C02-07 | Sharing | Coach access requires both valid assignment/authority and an explicit, scoped, revocable user grant. Pastor/community views are aggregate-only, minimum cohort `n=10`, with primary and secondary suppression and no reverse lookup. |
| C02-08 | Identity/security | Provider-neutral OIDC is required. MFA is mandatory for coach, pastor, tenant admin, support and privileged operators. Export, recovery, provider change and break-glass require step-up authentication. Shared accounts are prohibited. |
| C02-09 | Keys/recovery | Envelope encryption separates DEK and KEK; KMS/HSM access is outside the domain model. AI services never call the storage provider or KMS directly. Recovery is user-authenticated; no pastor/admin unilateral recovery and no key export. |
| C02-10 | Pseudonyms | Tenant-scoped keyed pseudonyms rotate every 12 months and after a material incident or tenant-boundary change. Mapping access is restricted and dual-controlled. |
| C02-11 | Consent | Separate consent/grant records are required for raw storage, AI analysis, personalization, coach sharing, deidentified aggregate contribution, headless integration, and safety escalation. Withdrawal blocks future processing and invalidates shares/caches. |
| C02-12 | Safety/break-glass | Safety may override the normal AI response with `HANDOFF`, but does not create universal raw access. Raw break-glass is disabled by default; any lawful emergency path must be time-boxed, dual-controlled, least-privilege and fully audited. |
| C02-13 | Children | Collection from children/minors is disabled by default. Launch requires a country-specific age threshold, guardian-consent/verification flow, notice, deletion and retention pack approved by Privacy/Legal. |
| C02-14 | Vendors/AI | Written processor terms, purpose limitation, deletion propagation, subprocessor register, regional location, incident notice, audit rights, and no training/secondary use are mandatory. |

## 3. Non-negotiable invariants

- No raw Life Diary content in PostgreSQL, analytics, telemetry, error reporting, support tickets or AI training corpora.
- No tenant administrator, pastor or coach browsing endpoint for raw Vault content.
- No aggregate response below `n=10`; small-cell and complementary suppression are required.
- No foreign transfer caused merely by provider defaults, support access, backup replication or AI routing.
- No production enablement when an approval field is blank, a regional row is `BLOCKED`, or validation evidence is missing.

## 4. Approval gate

The gate closes only when all rows below contain named approvers and UTC timestamps and the regional matrix contains no `BLOCKED` launch market.

| Approval | Accountable role | Current state |
|---|---|---|
| Product ownership and user promise | Corporate/Product Owner | PENDING |
| Legal basis, notices, rights, children and transfers | Privacy/Legal Owner | PENDING |
| IAM, encryption, pseudonyms and break-glass | Security Owner | PENDING |
| residency, backups, deletion SLA and evidence | Infrastructure/Operations Owner | PENDING |
| ko-KR market policy pack | Korea Market Owner | PENDING |
| ja-JP market policy pack | Japan Market Owner | PENDING |
| en-US market policy pack | United States Market Owner | PENDING |
| es-MX market policy pack | Mexico Market Owner | PENDING |

## 5. Closure evidence

Required evidence: approved privacy notices and consent screens by locale; data-flow and processor/subprocessor register; residency/transfer configuration; deletion and restore tests; MFA/step-up tests; coach dual-gate tests; aggregate suppression tests; recovery and break-glass drill; child-access block test; incident response contacts; and legal approval record.

## 6. Source register

- Korea PIPC overseas-transfer guidance: https://pipc.go.kr/np/cop/bbs/selectBoardArticle.do?bbsId=BS292&mCode=I040010000&nttId=10972
- Japan Personal Information Protection Commission, APPI laws and policies: https://www.ppc.go.jp/en/legal/
- California Privacy Protection Agency, CCPA statute effective 2026-01-01: https://cppa.ca.gov/regulations/pdf/ccpa_statute_eff_20260101.pdf
- Mexico Chamber of Deputies, current LFPDPPP: https://www.diputados.gob.mx/LeyesBiblio/pdf/LFPDPPP.pdf
- U.S. Federal Trade Commission, Children's Privacy/COPPA: https://www.ftc.gov/business-guidance/privacy-security/childrens-privacy

These sources define the legal-review inputs; the numeric operational defaults above are CHGO risk decisions and remain subject to owner approval.
