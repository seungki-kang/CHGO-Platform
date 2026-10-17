# ADR-LD01 Life Diary and CHGO Platform Role Separation 1.0

Status: **PROPOSED** — four decisions (LD-D1 to LD-D4) are open  
Date: 2026-10-17  
Companion: `docs/adr/ADR-LD01_Life_Diary_Producer_Responsibilities_1.0.md` in `CHGO-Life-Diary-Flutter`  
Related: `CHGO_Cross-Platform_Modular_Monorepo_ADR_1.0.md`, Review 1.0 of Audit 2.4 (decision LD-P1), `JL-LD-002_Flutter_MVP_Integration_Contract_1.0.md`  
Canonical/Governance meaning changes: none

## 1. Context

### 1.1 Intended roles

- **Life Diary** is developed independently and integrated by API. It owns the diary: the raw text, the selections, drafts, editing, deletion, and restore.
- **CHGO Platform** is an engine that receives Life Diary data only within the limits of personal-information law. It does not evaluate or score anyone. It gives a community enough visibility to understand how its members are growing.

### 1.2 Current state (2026-10-17)

- **The repositories are already separate.** Life Diary lives in `CHGO-Life-Diary-Flutter`. The Monorepo ADR says a product may move to its own repository only after its API/event contract, identity contract, data ownership, migration path and rollback plan are stable. None of these is defined yet for Life Diary.
- **Platform defines the application's internal structure.** It holds the Life Diary runtime schema, the Flutter mapping, the application's SQLite structure, the Flutter backlog, and the application acceptance tests (Section 4). JL-LD-002 assigns "schema versions, privacy classes, growth-event boundaries" to CHGO. This contradicts LD-P1, under which the application is the source of truth for Life Diary.
- **Platform designs a raw-diary vault.** `/me/vaults/{vaultId}/entries` and `db/migrations/chgo/PDV-003_*.sql` store encrypted diary content on the Platform side. This overlaps with an independent Life Diary that keeps its own raw text.
- **The application has no integration code yet.**
  - `LifeDiaryAnalyticsExporter.growthEvent` exists but is never called, and the application has no network client.
  - The event it builds contains `entry_id`, the exact `entry_date`, and `old_person_ids`. Sent as is, these would allow re-identification and would carry likely-sensitive data.
- **Platform already has the parts this design needs.**
  - Outbox guards against raw text
  - Privacy-gateway decision and pseudonym-link tables
  - Aggregate-only pastor endpoints with minimum-cohort suppression (`/pastor/pulse`, `/pastor/community-growth`)
  - A schema assertion that forbids spiritual score columns
  - Monorepo ADR rule 7: raw diary is never a general CHGO growth record

### 1.3 Legal constraints

This section is not legal advice. Counsel specializing in personal information must review the design before release.

- **Sensitive information.** Personal Information Protection Act Art. 23 classifies "thought and belief" (사상·신념) as sensitive information. Processing requires consent separate from any other consent, or a legal basis. Old-person categories, fruits of the Spirit, and communion records arise from religious practice and are likely to be treated as sensitive information.
- **Pseudonymized information.** Art. 28-2 allows pseudonymized information to be processed without consent for statistics, scientific research, or public-interest archiving. Removing direct identifiers is not sufficient by itself: re-identification risk from combinations of attributes, such as dates and affiliation, must also be reduced. Whether this exemption covers sensitive information is unconfirmed.

The design therefore assumes all three safeguards: **separate consent, pseudonymization, and community-level aggregation.**

## 2. Decision (proposed)

### 2.1 Roles

| | Life Diary (application, and an optional Life Diary-only server) | CHGO Platform (engine) |
| --- | --- | --- |
| Owns | Raw text, selections, drafts, revisions, consent records | No raw text. Consented, pseudonymized signals and the aggregates built from them |
| Does | Write, edit, delete, restore; manage consent; build export signals | Accept signals, aggregate per community, suppress small cohorts, show community trends |
| Never does | Send anything without consent | Per-person views, rankings or scores; requests for raw text |
| Repository | `CHGO-Life-Diary-Flutter` | `CHGO-Platform` |

### 2.2 Data boundary

1. **Raw text stays on the Life Diary side.** No API, event, or Platform table carries diary narrative.
2. **A privacy gateway sits on the boundary (option B in Section 3).**
   - The application sends signals to the gateway.
   - The gateway checks consent, pseudonymizes, and suppresses cohorts below the minimum size (LD-D3).
   - Only community-level aggregates leave the gateway for the engine. Individual-level signals do not reach the engine.
3. **Sensitive items are reduced at the source (option C principles).**
   - Old-person categories, fruits, and communion types leave the device only as counts, or as community distributions, according to LD-D2.
   - Time is coarsened to the ISO week. Entry IDs and exact dates are not sent.
4. **Consent withdrawal stops future signals.** How already-aggregated data is handled is part of LD-D2.

### 2.3 Contract ownership

| Contract | Owner | Verified by |
| --- | --- | --- |
| Life Diary export signal | Life Diary | Life Diary tests, plus a Platform consumer-contract test that the signal is accepted |
| Platform ingest acceptance rules (consent, purpose, suppression) | Platform | Platform tests |
| Canonical IDs and wording (old persons, fruits, questions) | JesusLife Canonical governance (register in Platform) | Life Diary pins a register version |

This supersedes, for Life Diary, the JL-LD-002 statement that CHGO owns "schema versions, privacy classes, growth-event boundaries". Canonical IDs remain under Canonical governance.

### 2.4 Guardrails ("visible, not evaluated")

- **Aggregates only.** No endpoint returns an individual's Life Diary signals to a pastor, coach, or administrator.
- **No scores.** No score, rank, level, or comparison between people or between communities. The existing forbidden-column assertion stays.
- **Small cohorts suppressed.** Cohorts below the minimum size (LD-D3) are suppressed, including secondary suppression of differences.
- **Membership is not consent.** Membership in a community never implies consent to send signals.

## 3. Options considered

### 3.1 Integration

| Option | Platform receives | Privacy risk | Insight | Effort |
| --- | --- | --- | --- | --- |
| A. Individual signals | Pseudonymous person ID and per-session selections | Medium: individual-level, sensitive | Detailed | Low |
| **B. Gateway aggregation** (proposed) | Community aggregates only, after consent check, pseudonymization and suppression | Low | Community trends | Medium |
| C. On-device aggregation / local differential privacy | Pre-aggregated or noised values | Very low | Broad tendencies | High |
| D. Personal vault with access grants | Raw content the user grants to a named person | High within the grant | Individual coaching | High |

- **A** is rejected: Platform would accumulate per-person religious records, which conflicts with "not evaluated" and with Art. 23.
- **C** is adopted as a principle for sensitive items (Section 2.2), not as the whole design.
- **D** is out of scope for the engine. If user-initiated sharing with a coach is needed, it is designed as a separate Life Diary feature.

### 3.2 Contract ownership

| Option | Description | Status |
| --- | --- | --- |
| **1. Life Diary owns the export contract** | Platform runs consumer-contract tests | Proposed; consistent with LD-P1 |
| 2. Separate contract repository | Shared repository for API contracts only | Revisit when more producers exist |
| 3. Platform owns the contract | Life Diary conforms to Platform | Rejected; contradicts LD-P1 |

## 4. Repository relocation (planned, not executed)

No file is moved by this ADR. Relocation happens after LD-D1 to LD-D4 are decided.

| Platform path | Target | Condition |
| --- | --- | --- |
| `ontology/schemas/life-diary-runtime-schema-v1.json` | Life Diary | — |
| `ontology/projections/life-diary-flutter-mapping-v1.json` | Life Diary | — |
| `db/migrations/life_diary/V001__life_diary_sqlite_foundation.sql` | Life Diary (or retire; the application's `lib/data/life_diary_database.dart` is authoritative) | — |
| `docs/product/JL-LD-001_Life_Diary_Runtime_Schema_1.0.md` | Life Diary | — |
| `docs/product/JL-LD-002_Flutter_MVP_Integration_Contract_1.0.md` | Life Diary, rewritten as the export signal contract | — |
| `docs/product/JL-LD-003_Flutter_MVP_Implementation_Backlog_1.0.csv` | Life Diary | — |
| `tests/acceptance/life-diary/LIFE_DIARY_MVP_ACCEPTANCE_1.0.csv` | Life Diary | — |
| `tools/validation/validate_jl_life_diary_*.py` | Replaced by Life Diary tests, plus a Platform consumer-contract test | — |
| `docs/privacy-security/PDV-006_Life_Diary_Retention_Deletion_and_Export_Policy_1.0.docx` | Life Diary | Owner of raw data owns retention |
| `db/migrations/chgo/PDV-003_*.sql`, `docs/architecture/PDV-00*`, `docs/privacy-security/CHGO_Personal_Data_Vault_and_Life_Diary_Storage_Architecture_1.0.docx`, `/me/vaults/*` | Depends on LD-D1 | Out of Platform scope if raw text never leaves Life Diary |
| `canonical/sources/JESUSLIFE_CANONICAL_OBJECT_REGISTER_1.0.csv` | Stays in Platform | Life Diary pins a version |

## 5. Open decisions

| ID | Question | Options | Recommendation | Owner |
| --- | --- | --- | --- | --- |
| LD-D1 | Does raw diary text leave the device? | (a) Device only, with user-triggered export. (b) Backup on a Life Diary-only server. (c) Platform vault (current PDV design) | (a) now, (b) later if needed; not (c) | Product owner |
| LD-D2 | How is separate consent for sensitive information obtained and withdrawn? | (a) One consent covering all signals. (b) Per-category consent (activity counts vs. selection distributions). Withdrawal: stop future signals only, or also delete contributions not yet aggregated | (b), with withdrawal stopping future signals and deleting unaggregated contributions | Product owner + counsel |
| LD-D3 | Minimum cohort size for any published aggregate | Policy value (k) plus secondary suppression; Platform currently leaves it OPEN | Decide with counsel; record with C-02 privacy policy | Product owner + counsel |
| LD-D4 | How is an application user linked to a church community? | (a) Community join code entered by the user. (b) Invitation from the church. (c) Shared CHGO identity account. Identity contract must not merge accounts by email (Monorepo ADR rule 4) | (a) or (b) for MVP, producing a per-community pseudonym; (c) later | Product owner + Platform engineering |

## 6. Consequences

- **Monorepo ADR exception.** Life Diary is the first product admitted as a separate repository. This ADR records that exception. The Monorepo ADR's preconditions become this ADR's closure conditions (Section 7).
- **Life Diary changes.** `growthEvent` is redesigned before any transmission: no `entry_id`, week instead of date, sensitive selections only as LD-D2 allows. The Life Diary-side obligations are in the companion ADR.
- **Platform changes.** `/integrations/chgo/events` (currently Church OS events) is either extended or joined by a separate Life Diary ingest endpoint behind the privacy gateway. The pastor endpoints keep their aggregate-only design.
- **Unchanged.** Audit 2.4 Review decisions D-3 and D-4 (database roles) remain open and are unchanged.

## 7. Closure conditions

This ADR moves from PROPOSED to ACCEPTED when:

1. LD-D1 to LD-D4 are decided and recorded here.
2. The Life Diary export signal contract 1.0 is published in `CHGO-Life-Diary-Flutter` (API/event contract).
3. The user-to-community link from LD-D4 is specified (identity contract).
4. Section 4 is executed or explicitly deferred (data ownership).
5. The migration path for existing application data and a rollback plan for the first transmission release are written.
6. Counsel review of Section 1.3 and LD-D2/LD-D3 is recorded.

This ADR establishes boundaries only. It is not runtime evidence.
