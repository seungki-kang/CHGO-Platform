#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?Set DATABASE_URL}"
command -v psql >/dev/null || { echo 'FAIL: psql not found'; exit 2; }
ver=$(psql "$DATABASE_URL" -Atqc "show server_version_num")
[ "$ver" -ge 160000 ] || { echo "FAIL: PostgreSQL 16+ required, got $ver"; exit 3; }
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -Atqc "select current_database(), current_user, version();"
echo 'PASS: preflight'
