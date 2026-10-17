# E5 Regression and Rollback Execution Runbook 1.0

Status: **EXECUTION_READY / RUNTIME_NOT_RUN / GATE_OPEN**  
Base: C-02 Production Privacy Policy Decision Candidate 1.0  
Canonical impact: **NONE**

## Purpose

E5 proves that repository, database, API, security/privacy and Vault changes can be revalidated together and that a failed release can be returned to a known-good boundary without inventing success evidence.

## Regression order

1. Preserve the candidate archive and SHA-256.
2. Run `python tools/validation/validate_e5_regression.py`.
3. Confirm repository and policy static checks are `PASS`.
4. In an approved disposable environment, execute B-02 PostgreSQL clean execution.
5. Execute B-03 acceptance/security tests and B-04 API runtime tests. (PDV-008 Vault tests were retired from E5 on 2026-10-17; Vault belongs to the Life Diary backup service.)
6. Record commands, start/end UTC, environment ID, commit/archive hash, test counts and immutable logs.
7. If any blocking check fails, stop promotion and execute the rollback decision tree.

## Rollback decision tree

| Trigger | Immediate action | Recovery boundary | Required proof |
|---|---|---|---|
| Static/manifest mismatch | Stop before deployment | Re-extract last approved update | hash and validator PASS |
| DB migration failure | Stop writers; preserve logs | B-02 clean fixture/approved backup | schema fingerprint and row checks |
| API contract regression | Disable affected feature flag/version route | last approved OpenAPI/service build | contract suite PASS |
| Privacy/security failure | Disable affected processing/share/export path | deny-by-default policy state | negative tests PASS |
| Vault/provider failure | Stop raw writes; retain encrypted objects | last approved adapter/config | no-loss/no-raw-log evidence |
| Unknown or cross-domain failure | Full promotion halt | last approved release | reviewer-authorized recovery |

## Safety rules

- Rollback is not destructive deletion. Preserve forensic logs and never overwrite the only backup.
- Never restore raw Life Diary content into PostgreSQL, logs, analytics or support systems.
- Restore reconciliation must reapply deletion tombstones and expired share grants.
- Canonical, ontology meaning and user ownership boundaries cannot be rolled back by an operational release.
- A rollback is complete only after regression rerun and reviewer approval.

## Gate criteria

E5 remains `OPEN` while any runtime suite is `NOT_RUN`, any blocking test fails, rollback recovery is unproven, or C-02 remains unapproved. Static readiness alone does not close E5.
