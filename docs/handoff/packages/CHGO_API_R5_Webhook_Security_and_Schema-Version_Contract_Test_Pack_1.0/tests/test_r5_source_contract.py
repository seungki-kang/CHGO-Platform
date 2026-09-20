import yaml, csv
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
REPOSITORY_ROOT=Path(__file__).resolve().parents[5]
SPEC=REPOSITORY_ROOT/"api"/"openapi"/"v2"/"CHGO_Public_and_Headless_OpenAPI_v2_Consolidated_Baseline_1.0.yaml"
def load(): return yaml.safe_load(SPEC.read_text())
def deref(spec, ref):
    cur=spec
    for token in ref[2:].split("/"): cur=cur[token.replace("~1","/").replace("~0","~")]
    return cur
def test_two_webhook_subscription_surfaces_exist():
    s=load()
    assert "/headless/webhooks" in s["paths"]
    assert "/integrations/vault/webhooks" in s["paths"]
    assert "post" in s["paths"]["/headless/webhooks"]
    assert "post" in s["paths"]["/integrations/vault/webhooks"]
def test_both_require_webhook_manage_service_scope():
    s=load()
    for p in ("/headless/webhooks","/integrations/vault/webhooks"):
        sec=s["paths"][p]["post"]["security"]
        assert any("webhook.manage" in scopes for req in sec for scopes in req.values())
def test_both_require_request_id_and_idempotency_key():
    s=load()
    for p in ("/headless/webhooks","/integrations/vault/webhooks"):
        refs=[x.get("$ref","") for x in s["paths"][p]["post"].get("parameters",[])]
        assert "#/components/parameters/RequestId" in refs
        assert "#/components/parameters/IdempotencyKey" in refs
def test_vault_webhook_is_declared_metadata_only():
    s=load()
    text=s["paths"]["/integrations/vault/webhooks"]["post"].get("description","").lower()
    assert "metadata-only" in text or "opaque ids" in text
    assert "never" in text and ("raw diary" in text or "secrets" in text)
def test_webhook_request_schemas_resolve():
    s=load()
    refs=[]
    for p in ("/headless/webhooks","/integrations/vault/webhooks"):
        ref=s["paths"][p]["post"]["requestBody"]["content"]["application/json"]["schema"]["$ref"]
        assert deref(s,ref)
        refs.append(ref)
    assert len(set(refs))==2
def test_matrix_has_20_cases():
    rows=list(csv.DictReader((ROOT/"fixtures"/"R5_webhook_test_matrix.csv").open(encoding="utf-8-sig")))
    assert len(rows)==20
    assert all(r["expected"] and r["severity"] for r in rows)
def test_env_template_contains_no_secret_values():
    lines=(ROOT/"fixtures"/".env.example").read_text().splitlines()
    for line in lines:
        if line.startswith("CHGO_"): assert line.endswith("=")
