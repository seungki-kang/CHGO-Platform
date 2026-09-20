import os, pytest, requests

BASE=os.getenv("CHGO_API_V2_BASE_URL","").rstrip("/")
USER_A=os.getenv("CHGO_TOKEN_USER_A","")
PASTOR=os.getenv("CHGO_TOKEN_PASTOR","")
COACH=os.getenv("CHGO_TOKEN_COACH","")
HEADLESS=os.getenv("CHGO_TOKEN_HEADLESS","")
VAULT_A=os.getenv("CHGO_VAULT_A","")
ENTRY_A=os.getenv("CHGO_ENTRY_A","")
CHURCH_A=os.getenv("CHGO_CHURCH_A","")

pytestmark=pytest.mark.skipif(not BASE, reason="Runtime API base URL not supplied")

def auth(token):
    return {"Authorization":f"Bearer {token}"} if token else {}

def test_r3_t01_unauthenticated_protected_endpoint_denied():
    r=requests.get(f"{BASE}/me/vaults", timeout=15)
    assert r.status_code in (401,403,404)

def test_r4_t01_pastor_cannot_read_raw_vault_entry():
    if not (PASTOR and VAULT_A and ENTRY_A): pytest.skip("Pastor/Vault fixture not supplied")
    r=requests.get(f"{BASE}/me/vaults/{VAULT_A}/entries/{ENTRY_A}",headers=auth(PASTOR),timeout=15)
    assert r.status_code in (403,404)

def test_r4_t03_coach_role_alone_cannot_read_raw_vault_entry():
    if not (COACH and VAULT_A and ENTRY_A): pytest.skip("Coach/Vault fixture not supplied")
    r=requests.get(f"{BASE}/me/vaults/{VAULT_A}/entries/{ENTRY_A}",headers=auth(COACH),timeout=15)
    assert r.status_code in (403,404)

def test_r4_t06_headless_cannot_read_raw_vault_entry():
    if not (HEADLESS and VAULT_A and ENTRY_A): pytest.skip("Headless/Vault fixture not supplied")
    r=requests.get(f"{BASE}/me/vaults/{VAULT_A}/entries/{ENTRY_A}",headers=auth(HEADLESS),timeout=15)
    assert r.status_code in (403,404)

def test_r4_t02_pastor_aggregate_has_no_obvious_raw_diary_fields():
    if not (PASTOR and CHURCH_A): pytest.skip("Pastor/Church fixture not supplied")
    r=requests.post(f"{BASE}/pastor/community-growth",headers=auth(PASTOR),json={"church_id":CHURCH_A},timeout=15)
    assert r.status_code in (200,400,403,404,422)
    if r.status_code==200:
        text=r.text.lower()
        for forbidden in ("raw_diary","raw_text","diary_body","vault_entry_body"):
            assert forbidden not in text
