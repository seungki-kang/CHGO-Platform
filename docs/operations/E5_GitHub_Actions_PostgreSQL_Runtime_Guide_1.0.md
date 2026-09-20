# E5 GitHub Actions PostgreSQL Runtime Guide 1.0

## Outcome

This workflow runs the CHGO database tests on a disposable PostgreSQL 16 service without installing or managing PostgreSQL on the user's Windows computer.

## Execution

1. Upload the clean `CHGO-Platform` contents to a private GitHub repository.
2. Open the repository's **Actions** tab.
3. Select **E5 PostgreSQL Runtime and Rollback Evidence**.
4. Choose **Run workflow**.
5. After completion, download the artifact named `E5-PostgreSQL-Runtime-Evidence-<run_id>`.

## Evidence meaning

- `postgresql_runtime=PASS`: V001–V012 and the V010 replay completed in PostgreSQL 16.
- `postgresql_rollback_restore=PASS`: dump, database drop/recreate and restore completed and all B-02 result rows are PASS.
- `overall_e5_runtime=PARTIAL_PASS`: database runtime evidence exists, but API/Vault provider runtime is still unavailable.
- `production_gate=OPEN`: the repository cannot be promoted until the real API, identity tokens, Vault provider and KMS sandbox exist and their suites pass.

## Security

The workflow uses an ephemeral CI-only password and synthetic data. No Life Diary content, production credentials, GitHub secrets or user data are required. The service is destroyed with the job. The evidence artifact is retained for 90 days.
