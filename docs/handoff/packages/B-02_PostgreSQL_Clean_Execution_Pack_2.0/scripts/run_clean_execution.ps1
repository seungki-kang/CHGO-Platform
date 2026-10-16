param([Parameter(Mandatory=$true)][string]$DatabaseUrl)
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path $PSScriptRoot -Parent
$MigrationRoot = Join-Path $PackRoot "migrations"
$EvidenceRoot = Join-Path $PackRoot "evidence"
$Log = Join-Path $EvidenceRoot "B02_clean_execution_windows.log"
New-Item -ItemType Directory -Force -Path $EvidenceRoot | Out-Null
"" | Set-Content $Log

if (-not (Get-Command psql -ErrorAction SilentlyContinue)) { throw "psql not found. Install PostgreSQL 16 client tools." }
$ServerVersion = & psql $DatabaseUrl -Atqc "show server_version_num"
if ($LASTEXITCODE -ne 0) { throw "Unable to connect to the disposable database." }
if ([int]$ServerVersion -lt 160000) { throw "PostgreSQL 16+ required. server_version_num=$ServerVersion" }
& psql $DatabaseUrl -v ON_ERROR_STOP=1 -Atqc "select current_database(), current_user, version();" 2>&1 | Tee-Object -FilePath $Log -Append

$Files = @(
  "V001__extensions_schemas_shared.sql", "V002__identity_tenant.sql",
  "V003__membership_community.sql", "V004__access_role.sql",
  "V005__brand_module.sql", "V006__operational_modules.sql",
  "V007__integration_events.sql", "V008__audit_retention_rls.sql",
  "V009__seed_views_validation.sql", "V010__DEV-002A_compatibility_patch_2.0a.sql",
  "V011__PHY_T01-T12_revalidation.sql", "V012__DEV-002A_contract_tests_2.0.sql"
)
foreach ($File in $Files) {
  "==> $File" | Tee-Object -FilePath $Log -Append
  & psql $DatabaseUrl -X -v ON_ERROR_STOP=1 -f (Join-Path $MigrationRoot $File) 2>&1 | Tee-Object -FilePath $Log -Append
  if ($LASTEXITCODE -ne 0) { throw "$File failed" }
}
"==> replay V010" | Tee-Object -FilePath $Log -Append
& psql $DatabaseUrl -X -v ON_ERROR_STOP=1 -f (Join-Path $MigrationRoot "V010__DEV-002A_compatibility_patch_2.0a.sql") 2>&1 | Tee-Object -FilePath $Log -Append
if ($LASTEXITCODE -ne 0) { throw "V010 replay failed" }
& psql $DatabaseUrl -X -v ON_ERROR_STOP=1 -c "UPDATE b02_test.result SET status='PASS',detail='V010 replay exited 0' WHERE test_id='PHY-T11';" 2>&1 | Tee-Object -FilePath $Log -Append
& psql $DatabaseUrl -X -P pager=off -c "TABLE b02_test.result ORDER BY test_id;" 2>&1 | Tee-Object -FilePath $Log -Append
# V012 runs its contract tests inside a transaction that ends in ROLLBACK, so
# church_os_test.test_result never persists. Its per-test results are printed in
# the V012 section of this log, and any FAIL makes V012 (and this script) stop above.
Write-Host "Apply and replay complete. B-02 remains OPEN until rollback/restore succeeds."
