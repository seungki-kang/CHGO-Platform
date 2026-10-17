#!/usr/bin/env python3
import csv
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
checks = [
    ("B04_OPENAPI", [sys.executable, str(ROOT / "tools/validation/validate_b04_openapi.py")]),
    ("C02_POLICY", [sys.executable, str(ROOT / "tools/validation/validate_c02_policy.py")]),
]
results = []
for name, command in checks:
    run = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
    results.append({"check": name, "status": "PASS" if run.returncode == 0 else "FAIL", "returncode": run.returncode})

required = [
    ROOT / "docs/handoff/packages/B-02_PostgreSQL_Clean_Execution_Pack_2.0",
    ROOT / "docs/handoff/packages/CHGO_B03_Acceptance_and_Security_Execution_Pack_1.0",
    ROOT / "releases/rollback/E5/E5_rollback_control_register_1.0.csv",
    ROOT / "docs/operations/E5_Regression_and_Rollback_Execution_Runbook_1.0.md",
]
for path in required:
    results.append({"check": f"PRESENT:{path.relative_to(ROOT)}", "status": "PASS" if path.exists() else "FAIL"})

with (ROOT / "tests/regression/E5_regression_execution_register_1.0.csv").open(encoding="utf-8-sig", newline="") as f:
    rows = list(csv.DictReader(f))
results.append({"check": "REGRESSION_REGISTER_7_ROWS", "status": "PASS" if len(rows) == 7 else "FAIL"})
# E5-R01 (CHGO repository structure freeze) and E5-R05 (PDV-008 Vault) were retired on
# 2026-10-17 when this repository became Church OS only. They stay in the register as RETIRED.
active = [r for r in rows if r["static_status"] != "RETIRED"]
retired = sorted(r["suite_id"] for r in rows if r["static_status"] == "RETIRED")
results.append({"check": "RETIRED_SUITES_ARE_R01_R05", "status": "PASS" if retired == ["E5-R01", "E5-R05"] else "FAIL"})
missing_targets = [r["suite_id"] for r in active
                   if not r["command_or_evidence"].startswith("python ")
                   and not (ROOT / r["command_or_evidence"]).exists()]
results.append({"check": "ACTIVE_SUITE_TARGETS_PRESENT", "status": "PASS" if not missing_targets else "FAIL",
                "missing": missing_targets})

failed = [r for r in results if r["status"] != "PASS"]
print(json.dumps({
    "gate": "E5",
    "static_regression": "FAIL" if failed else "PASS",
    "runtime_regression": "NOT_RUN",
    "rollback_runtime_proof": "NOT_RUN",
    "production_gate": "OPEN",
    "checks": results,
    "errors": failed
}, ensure_ascii=False, indent=2))
raise SystemExit(1 if failed else 0)
