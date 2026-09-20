#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
decision_file = ROOT / "registry/C02_privacy_policy_decision_register_1.0.csv"
regional_file = ROOT / "localization/regional-compliance/C02_regional_privacy_policy_matrix_1.0.csv"
evidence_file = ROOT / "evidence/pre-release/C02_policy_gate_validation_1.0.json"

with decision_file.open(encoding="utf-8-sig", newline="") as f:
    decisions = list(csv.DictReader(f))
with regional_file.open(encoding="utf-8-sig", newline="") as f:
    regions = list(csv.DictReader(f))

errors = []
ids = {row["decision_id"] for row in decisions}
required_ids = {f"C02-{n:02d}" for n in range(1, 15)}
if ids != required_ids:
    errors.append(f"decision IDs mismatch: missing={sorted(required_ids-ids)} extra={sorted(ids-required_ids)}")
locales = {row["locale"] for row in regions}
required_locales = {"ko-KR", "ja-JP", "en-US", "es-MX"}
if locales != required_locales:
    errors.append(f"regional rows mismatch: missing={sorted(required_locales-locales)}")

approvals_complete = all(r["approval_status"] == "APPROVED" and r["approved_by"] and r["approved_at_utc"] for r in decisions)
regions_approved = all(r["policy_pack_status"] == "APPROVED" and r["approved_by"] and r["approved_at_utc"] for r in regions)
result = "CLOSED" if approvals_complete and regions_approved and not errors else "OPEN"

evidence = json.loads(evidence_file.read_text(encoding="utf-8"))
if evidence["production_gate"] != result:
    errors.append(f"evidence production_gate={evidence['production_gate']} calculated={result}")

print(json.dumps({
    "gate": "C-02",
    "static_structure": "FAIL" if errors else "PASS",
    "production_gate": result,
    "approvals_complete": approvals_complete,
    "regional_packs_approved": regions_approved,
    "errors": errors
}, ensure_ascii=False, indent=2))
raise SystemExit(1 if errors else 0)
