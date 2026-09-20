import os, pytest, requests
BASE=os.getenv("CHGO_API_V2_BASE_URL","").rstrip("/")
MANAGER=os.getenv("CHGO_SERVICE_TOKEN_WEBHOOK_MANAGER","")
NOSCOPE=os.getenv("CHGO_SERVICE_TOKEN_NO_WEBHOOK_SCOPE","")
RECEIVER=os.getenv("CHGO_WEBHOOK_RECEIVER_URL","")
pytestmark=pytest.mark.skipif(not BASE, reason="Runtime API target not supplied")
def h(token,idem="r5-test"):
    x={"Idempotency-Key":idem,"X-Request-Id":"r5-test-request"}
    if token:x["Authorization"]=f"Bearer {token}"
    return x
def test_r5_t01_unauthenticated_headless_subscription_denied():
    r=requests.post(f"{BASE}/headless/webhooks",headers=h(""),json={"url":RECEIVER or "https://example.invalid/hook"},timeout=15)
    assert r.status_code in (401,403)
def test_r5_t02_missing_scope_denied():
    if not NOSCOPE: pytest.skip("No-scope service token not supplied")
    r=requests.post(f"{BASE}/headless/webhooks",headers=h(NOSCOPE),json={"url":RECEIVER or "https://example.invalid/hook"},timeout=15)
    assert r.status_code in (403,404)
def test_r5_vault_subscription_requires_authorized_manager():
    r=requests.post(f"{BASE}/integrations/vault/webhooks",headers=h(""),json={"url":RECEIVER or "https://example.invalid/hook"},timeout=15)
    assert r.status_code in (401,403)
