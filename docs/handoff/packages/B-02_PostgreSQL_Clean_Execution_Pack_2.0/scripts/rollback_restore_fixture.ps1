param(
  [Parameter(Mandatory=$true)][string]$DatabaseUrl,
  [Parameter(Mandatory=$true)][string]$AdminDatabaseUrl,
  [Parameter(Mandatory=$true)][ValidatePattern('^[A-Za-z0-9_]+$')][string]$DatabaseName
)
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path $PSScriptRoot -Parent
$EvidenceRoot = Join-Path $PackRoot "evidence"
$Log = Join-Path $EvidenceRoot "B02_rollback_restore_windows.log"
$Dump = Join-Path $EvidenceRoot "$DatabaseName.dump"
foreach ($Command in @("pg_dump","pg_restore","dropdb","createdb","psql")) {
  if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) { throw "$Command not found" }
}
"" | Set-Content $Log
"==> dump" | Tee-Object -FilePath $Log -Append
& pg_dump $DatabaseUrl -Fc -f $Dump
if ($LASTEXITCODE -ne 0) { throw "pg_dump failed" }
"==> drop disposable database" | Tee-Object -FilePath $Log -Append
& dropdb --if-exists --force --maintenance-db=$AdminDatabaseUrl $DatabaseName 2>&1 | Tee-Object -FilePath $Log -Append
if ($LASTEXITCODE -ne 0) { throw "dropdb failed" }
"==> recreate disposable database" | Tee-Object -FilePath $Log -Append
& createdb --maintenance-db=$AdminDatabaseUrl $DatabaseName 2>&1 | Tee-Object -FilePath $Log -Append
if ($LASTEXITCODE -ne 0) { throw "createdb failed" }
"==> restore" | Tee-Object -FilePath $Log -Append
& pg_restore --exit-on-error --clean --if-exists -d $DatabaseUrl $Dump 2>&1 | Tee-Object -FilePath $Log -Append
if ($LASTEXITCODE -ne 0) { throw "pg_restore failed" }
& psql $DatabaseUrl -X -v ON_ERROR_STOP=1 -c "UPDATE b02_test.result SET status='PASS',detail='dump/drop/recreate/restore succeeded' WHERE test_id='PHY-T12';" 2>&1 | Tee-Object -FilePath $Log -Append
& psql $DatabaseUrl -X -P pager=off -c "TABLE b02_test.result ORDER BY test_id;" 2>&1 | Tee-Object -FilePath $Log -Append
Write-Host "Rollback and restore fixture complete. Reviewer evidence review is still required."
