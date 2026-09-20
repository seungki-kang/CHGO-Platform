param([Parameter(Mandatory=$true)][string]$DatabaseUrl)
$ErrorActionPreference="Stop"
$env:DATABASE_URL=$DatabaseUrl
$files=@(
"V001__extensions_schemas_shared.sql","V002__identity_tenant.sql","V003__membership_community.sql",
"V004__access_role.sql","V005__brand_module.sql","V006__operational_modules.sql",
"V007__integration_events.sql","V008__audit_retention_rls.sql","V009__seed_views_validation.sql",
"V010__DEV-002A_compatibility_patch_2.0a.sql","V011__PHY_T01-T12_revalidation.sql",
"V012__DEV-002A_contract_tests_2.0.sql")
$log=Join-Path $PSScriptRoot "B02_execution.log"
"" | Set-Content $log
foreach($f in $files){ "==> $f" | Tee-Object -FilePath $log -Append; & psql $DatabaseUrl -v ON_ERROR_STOP=1 -f (Join-Path $PSScriptRoot $f) 2>&1 | Tee-Object -FilePath $log -Append; if($LASTEXITCODE -ne 0){throw "$f failed"} }
"==> Replay V010 for PHY-T11" | Tee-Object -FilePath $log -Append
& psql $DatabaseUrl -v ON_ERROR_STOP=1 -f (Join-Path $PSScriptRoot "V010__DEV-002A_compatibility_patch_2.0a.sql") 2>&1 | Tee-Object -FilePath $log -Append
if($LASTEXITCODE -eq 0){ & psql $DatabaseUrl -v ON_ERROR_STOP=1 -c "UPDATE b02_test.result SET status='PASS',detail='V010 replay exited 0' WHERE test_id='PHY-T11';" } else { throw "V010 replay failed" }
& psql $DatabaseUrl -P pager=off -c "TABLE b02_test.result ORDER BY test_id;" | Tee-Object -FilePath $log -Append
Write-Host "PHY-T12 remains PENDING until rollback/recovery fixture is executed and evidenced."
