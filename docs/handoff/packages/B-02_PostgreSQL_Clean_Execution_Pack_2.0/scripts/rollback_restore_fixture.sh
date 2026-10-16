#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?Set DATABASE_URL}"; : "${ADMIN_DATABASE_URL:?Set ADMIN_DATABASE_URL (connection to postgres/admin DB)}"
: "${B02_DB_NAME:?Set B02_DB_NAME to disposable B-02 database name}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; E="$ROOT/evidence"; LOG="$E/B02_rollback_restore.log"; : > "$LOG"
command -v pg_dump >/dev/null; command -v pg_restore >/dev/null; command -v dropdb >/dev/null; command -v createdb >/dev/null
DUMP="$E/${B02_DB_NAME}.dump"
echo '==> dump clean-applied DB' | tee -a "$LOG"; pg_dump "$DATABASE_URL" -Fc -f "$DUMP"
echo '==> drop disposable DB' | tee -a "$LOG"; dropdb --if-exists --force --maintenance-db="$ADMIN_DATABASE_URL" "$B02_DB_NAME" | tee -a "$LOG"
echo '==> recreate disposable DB' | tee -a "$LOG"; createdb --maintenance-db="$ADMIN_DATABASE_URL" "$B02_DB_NAME" | tee -a "$LOG"
echo '==> restore' | tee -a "$LOG"; pg_restore --exit-on-error --clean --if-exists -d "$DATABASE_URL" "$DUMP" 2>&1 | tee -a "$LOG"
psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -c "UPDATE b02_test.result SET status='PASS',detail='dump/drop/recreate/restore succeeded' WHERE test_id='PHY-T12';" | tee -a "$LOG"
psql "$DATABASE_URL" -X -P pager=off -c "TABLE b02_test.result ORDER BY test_id;" | tee -a "$LOG"
echo 'ROLLBACK/RESTORE FIXTURE COMPLETE; reviewer must verify evidence before B-02 PASS.' | tee -a "$LOG"
