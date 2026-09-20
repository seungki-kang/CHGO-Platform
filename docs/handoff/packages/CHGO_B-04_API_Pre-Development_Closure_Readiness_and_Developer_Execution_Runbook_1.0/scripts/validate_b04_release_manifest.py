import json,sys
if len(sys.argv)!=2: raise SystemExit("usage: python validate_b04_release_manifest.py manifest.json")
x=json.load(open(sys.argv[1],encoding="utf-8"))
req=x["required_release_evidence"]
mandatory=["environment_identity","build_commit","v1_openapi_sha256","v2_openapi_sha256",
"R1_route_fingerprint","R2_consumer_inventory","R3_auth_negative","R4_vault_privacy_negative",
"R5_webhook","R6_sdk","canary_leak_scan","rollback_test"]
missing=[k for k in mandatory if not req.get(k)]
if not req.get("approvals"): missing.append("approvals")
print(json.dumps({"status":"PASS" if not missing else "NOT_READY","missing":missing},indent=2))
raise SystemExit(0 if not missing else 2)
