import yaml, json, csv, re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
V1=Path("/mnt/data/CHGO_OpenAPI_Baseline_v1.0.yaml")
V2=Path("/mnt/data/CHGO_Public_and_Headless_OpenAPI_v2_Consolidated_Baseline_1.0.yaml")
METHODS={"get","post","put","patch","delete","options","head"}
def load(p): return yaml.safe_load(p.read_text())
def operations(s): return {(m.upper(),p) for p,item in s["paths"].items() for m in item if m.lower() in METHODS}
def test_major_servers_are_explicit_and_distinct():
    a,b=load(V1),load(V2)
    assert any(x["url"]=="/api/v1" for x in a["servers"])
    assert any(x["url"]=="/api/v2" for x in b["servers"])
def test_no_latest_or_unversioned_public_server():
    for s in (load(V1),load(V2)):
        for x in s.get("servers",[]):
            assert "/api/latest" not in x["url"]
            assert x["url"].rstrip("/") not in ("","/api")
def test_operation_surfaces_are_not_drop_in_equivalent():
    a,b=load(V1),load(V2)
    assert len(operations(a)&operations(b))==0
def test_v1_core_and_v2_vault_boundaries_remain_distinct():
    a,b=load(V1),load(V2)
    assert "/evidence" in a["paths"]
    assert any(p.startswith("/episodes") for p in a["paths"])
    assert "/me/vaults" not in a["paths"]
    assert "/me/vaults" in b["paths"]
    assert "/evidence" not in b["paths"]
def test_binding_manifest_records_hash_and_major():
    x=json.loads((ROOT/"fixtures"/"sdk_contract_binding_manifest.json").read_text())
    assert x["contract_bindings"]["v1"]["server"]=="/api/v1"
    assert x["contract_bindings"]["v2"]["server"]=="/api/v2"
    assert len(x["contract_bindings"]["v1"]["sha256"])==64
    assert len(x["contract_bindings"]["v2"]["sha256"])==64
    assert x["sdk_policy"]["silent_major_switch_forbidden"] is True
def test_sdk_inventory_does_not_claim_observed_consumers():
    rows=list(csv.DictReader((ROOT/"fixtures"/"sdk_consumer_inventory_template.csv").open(encoding="utf-8-sig")))
    assert all(r["status"]=="EVIDENCE_REQUIRED" for r in rows)
def test_matrix_has_20_cases():
    rows=list(csv.DictReader((ROOT/"fixtures"/"R6_SDK_API_major_test_matrix.csv").open(encoding="utf-8-sig")))
    assert len(rows)==20
    assert all(r["severity"] and r["expected"] for r in rows)
