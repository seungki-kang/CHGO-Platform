#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?Set DATABASE_URL}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; M="$ROOT/migrations"; E="$ROOT/evidence"
mkdir -p "$E"; LOG="$E/B02_clean_execution.log"; : > "$LOG"
"$ROOT/scripts/preflight.sh" | tee -a "$LOG"
for f in V001__extensions_schemas_shared.sql V002__identity_tenant.sql V003__membership_community.sql V004__access_role.sql V005__brand_module.sql V006__operational_modules.sql V007__integration_events.sql V008__audit_retention_rls.sql V009__seed_views_validation.sql V010__DEV-002A_compatibility_patch_2.0a.sql V011__PHY_T01-T12_revalidation.sql V012__DEV-002A_contract_tests_2.0.sql; do
  echo "==> $f" | tee -a "$LOG"; psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -f "$M/$f" 2>&1 | tee -a "$LOG"
done
echo '==> replay V010' | tee -a "$LOG"
psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -f "$M/V010__DEV-002A_compatibility_patch_2.0a.sql" 2>&1 | tee -a "$LOG"
psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -c "UPDATE b02_test.result SET status='PASS',detail='V010 replay exited 0' WHERE test_id='PHY-T11';" 2>&1 | tee -a "$LOG"
psql "$DATABASE_URL" -X -P pager=off -c "TABLE b02_test.result ORDER BY test_id;" | tee -a "$LOG"
psql "$DATABASE_URL" -X -P pager=off -c "select status,count(*) from church_os_test.test_result group by status order by status;" | tee -a "$LOG"
echo 'APPLY/REPLAY COMPLETE. B-02 is still NOT PASS until rollback/restore fixture is evidenced.' | tee -a "$LOG"
