#!/usr/bin/env python3
from pathlib import Path
import csv,json,sys,yaml
root=Path(__file__).resolve().parents[1]
repo=Path(__file__).resolve().parents[4]
rows=list(csv.DictReader((root/"fixtures/pdv008_test_register_1.0.csv").open(encoding="utf-8-sig")))
spec=yaml.safe_load((repo/"api/openapi/v2/CHGO_Public_and_Headless_OpenAPI_v2_Consolidated_Baseline_1.0.yaml").read_text())
errors=[]
if len(rows)!=84: errors.append("expected 84 tests")
if len({r["test_id"] for r in rows})!=84: errors.append("duplicate test_id")
if len({r["parent_gate"] for r in rows})!=84: errors.append("duplicate parent_gate")
if len(spec.get("paths",{}))!=42: errors.append("expected 42 OpenAPI paths")
print(json.dumps({"result":"PASS" if not errors else "FAIL","tests":len(rows),"openapi_paths":len(spec.get("paths",{})),"errors":errors},indent=2))
sys.exit(0 if not errors else 1)
