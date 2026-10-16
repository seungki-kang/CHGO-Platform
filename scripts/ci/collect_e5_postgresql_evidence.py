#!/usr/bin/env python3
import hashlib
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / os.getenv("E5_EVIDENCE_DIR", "evidence/runtime/E5/github-actions")
OUT.mkdir(parents=True, exist_ok=True)

def command(args):
    run = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    return {"returncode": run.returncode, "stdout": run.stdout.strip(), "stderr": run.stderr.strip()}

db = command(["psql", os.environ["DATABASE_URL"], "-X", "-Atqc",
              "select current_database()||'|'||current_user||'|'||current_setting('server_version_num');"])
tests = command(["psql", os.environ["DATABASE_URL"], "-X", "-Atqc",
                 "select status||'|'||count(*) from b02_test.result group by status order by status;"])
per_test = command(["psql", os.environ["DATABASE_URL"], "-X", "-Atqc",
                    "select test_id||'|'||status from b02_test.result order by test_id;"])

ROLLBACK_TEST_ID = "PHY-T12"


def parse_statuses(result):
    """Map test_id -> status; empty when the query failed or returned nothing."""
    if result["returncode"] != 0:
        return {}
    statuses = {}
    for line in result["stdout"].splitlines():
        test_id, _, status = line.partition("|")
        if test_id and status:
            statuses[test_id] = status
    return statuses


statuses = parse_statuses(per_test)
db_reachable = db["returncode"] == 0 and bool(statuses)
# Runtime passes only when every non-rollback test passed; rollback/restore is judged
# solely by its own test. Previously any single PASS row marked both as PASS.
runtime_pass = db_reachable and all(
    status == "PASS" for test_id, status in statuses.items() if test_id != ROLLBACK_TEST_ID)
rollback_pass = db_reachable and statuses.get(ROLLBACK_TEST_ID) == "PASS"
non_pass_tests = sorted(test_id for test_id, status in statuses.items() if status != "PASS")

files = []
for path in sorted(OUT.glob("*")):
    if path.is_file() and path.name != "E5_postgresql_runtime_evidence_1.0.json":
        files.append({"file": path.name, "size_bytes": path.stat().st_size,
                      "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})

summary = {
    "gate": "E5",
    "generated_at_utc": datetime.now(timezone.utc).isoformat(),
    "execution_environment": "GitHub Actions disposable PostgreSQL 16 service",
    "github_run_id": os.getenv("GITHUB_RUN_ID", "LOCAL_OR_UNKNOWN"),
    "github_sha": os.getenv("GITHUB_SHA", "UNKNOWN"),
    "synthetic_data_only": True,
    "postgresql_runtime": "PASS" if runtime_pass else "FAIL_OR_INCOMPLETE",
    "postgresql_rollback_restore": "PASS" if rollback_pass else "FAIL_OR_INCOMPLETE",
    "api_runtime_regression": "BLOCKED_NO_RUNTIME_IMPLEMENTATION",
    "pdv_provider_kms_runtime": "BLOCKED_NO_RUNTIME_IMPLEMENTATION",
    "overall_e5_runtime": "PARTIAL_PASS" if runtime_pass and rollback_pass else "OPEN",
    "non_pass_tests": non_pass_tests,
    "production_gate": "OPEN",
    "closure_allowed": False,
    "database_probe": db,
    "test_status_counts": tests,
    "evidence_files": files
}
(OUT / "E5_postgresql_runtime_evidence_1.0.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(summary, ensure_ascii=False, indent=2))
