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

files = []
for path in sorted(OUT.glob("*")):
    if path.is_file() and path.name != "E5_postgresql_runtime_evidence_1.0.json":
        files.append({"file": path.name, "size_bytes": path.stat().st_size,
                      "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})

db_pass = db["returncode"] == 0 and tests["returncode"] == 0 and "PASS|" in tests["stdout"]
summary = {
    "gate": "E5",
    "generated_at_utc": datetime.now(timezone.utc).isoformat(),
    "execution_environment": "GitHub Actions disposable PostgreSQL 16 service",
    "github_run_id": os.getenv("GITHUB_RUN_ID", "LOCAL_OR_UNKNOWN"),
    "github_sha": os.getenv("GITHUB_SHA", "UNKNOWN"),
    "synthetic_data_only": True,
    "postgresql_runtime": "PASS" if db_pass else "FAIL_OR_INCOMPLETE",
    "postgresql_rollback_restore": "PASS" if db_pass else "FAIL_OR_INCOMPLETE",
    "api_runtime_regression": "BLOCKED_NO_RUNTIME_IMPLEMENTATION",
    "pdv_provider_kms_runtime": "BLOCKED_NO_RUNTIME_IMPLEMENTATION",
    "overall_e5_runtime": "PARTIAL_PASS" if db_pass else "OPEN",
    "production_gate": "OPEN",
    "closure_allowed": False,
    "database_probe": db,
    "test_status_counts": tests,
    "evidence_files": files
}
(OUT / "E5_postgresql_runtime_evidence_1.0.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(summary, ensure_ascii=False, indent=2))
