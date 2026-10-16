# CHGO Platform Runtime and Security Audit 2.4

Date: 2026-10-16  
Baseline: `9eda66f8b297d160dca5ea69688fa097ff3e0272`  
Scope: executable migrations, CI/evidence logic, OpenAPI contracts, Life Diary runtime contract, repository validation  
Canonical/Governance meaning changes: none

## Corrected defects

- PostgreSQL V002 expression uniqueness now uses a valid case-insensitive unique index.
- B-02 shell entry points are executable and the parent runner invokes preflight through `bash`.
- Linux and PowerShell runners no longer query the transaction-rolled-back `church_os_test.test_result` table.
- E5 evidence requires exactly 12 PASS results and independent rollback/restore log proof; mixed PASS/FAIL output cannot close the gate.
- System roles use `UNIQUE NULLS NOT DISTINCT`, and system/tenant role consistency is constrained.
- Tenant tables use `FORCE ROW LEVEL SECURITY`; the global system-role read exception is separated from tenant write policy.
- The application role receives schema usage and table DML only where RLS is enabled. Pseudonym mappings remain denied.
- Cross-tenant references between tenant-owned rows are rejected by generated constraint triggers, including FKs added by V010.
- `updated_at`/`row_version` triggers are attached where the matching shared columns exist.
- General and CHGO bridge outboxes reject the actual Life Diary `narrative` field in addition to legacy raw-field aliases.
- Vault version, grant, grant-resource, deletion-job, and export-job tables now have forced owner RLS. Grant expiry is mandatory.
- RLS identity context uses missing-safe `current_setting(..., true)` instead of raising when context is absent.
- Life Diary deleted sessions can be replaced through a partial active-session unique index.
- Life Diary supports the RESTORED event and UI draft persistence.
- Raw narrative and structured selections have separate payload and privacy-class columns.
- A Flutter-shaped completed-entry fixture is validated, including the application's empty Q6 `why` value.
- Canonical UI labels are carried by ID in the Flutter projection without changing canonical source wording.
- Delta OpenAPI operations now have unique `operationId` values.
- Shared identity/membership/consent endpoints now define bearer security and mutation request bodies; Vault grants require recipient, scope, purpose, and expiry.
- Structure validators select the latest versioned manifest and permit `.github`.
- R6 tests no longer depend on `/mnt/data`; a missing unadmitted v1 contract is reported as skipped rather than as an environment path failure.
- Argument-taking validation scripts now return usage messages rather than `IndexError`.
- LF/CRLF behavior is explicit in `.gitattributes`.

## Additional defects found during remediation

1. A blanket application-role grant would expose global identity tables without tenant RLS. The grant was narrowed to RLS-protected tables.
2. V010 creates foreign keys after the V008 cross-tenant trigger sweep. A second idempotent sweep was added to V010.
3. Merely adding split Life Diary columns while retaining the combined `payload_json/privacy_class` fields would preserve the privacy ambiguity. The ambiguous columns were removed from the candidate baseline.
4. Vault owner policies used `current_setting` without `missing_ok`; a request without session context could raise instead of returning no rows.
5. Existing static E5 validation did not validate B-02 migration-copy equality, recorded hashes, executable bits, shell syntax, or the rolled-back-table query. A dedicated B-02 static validator now covers these properties.
6. The original evidence parser had no negative regression tests. Mixed, malformed, and empty status output now have unit coverage.

## Open items that must not be represented as PASS

- PostgreSQL 16 runtime execution, replay, dump/drop/recreate/restore, and non-owner cross-tenant negative tests require the E5 GitHub Actions job or another PostgreSQL 16 environment.
- `api/openapi/v1/CHGO_OpenAPI_Baseline_v1.0.yaml` is not admitted to this repository. R6 v1/v2 compatibility execution remains blocked until the authoritative v1 artifact is supplied and its recorded hash is reconciled.
- Same-name/version binary documents with different contents require owner/governance adjudication. This patch does not delete or silently choose between them.
- The Vault migration remains marked CANDIDATE and still requires identity-SoR integration plus production-equivalent role/pooling tests before activation.

## Verification commands

```bash
python tools/validation/validate_b02_pack.py
python tools/validation/validate_b04_openapi.py
python tools/validation/validate_jl_life_diary_foundation.py
python tools/validation/validate_jl_life_diary_flutter_contract.py
python tools/validation/validate_e5_regression.py
python -m unittest discover -s tests/ci -p 'test_*.py' -v
python tools/update-foundation/validation/validate_structure_freeze.py
```
