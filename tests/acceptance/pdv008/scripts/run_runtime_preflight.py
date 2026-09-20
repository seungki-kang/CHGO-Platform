#!/usr/bin/env python3
import json,os,sys
required=["CHGO_API_V2_BASE_URL","CHGO_TEST_OWNER_TOKEN","CHGO_TEST_SECOND_USER_TOKEN","CHGO_TEST_COACH_TOKEN","CHGO_TEST_PASTOR_TOKEN","CHGO_TEST_ADMIN_TOKEN","CHGO_TEST_PROVIDER_SANDBOX","CHGO_TEST_KMS_PROFILE"]
missing=[x for x in required if not os.getenv(x)]
print(json.dumps({"result":"READY" if not missing else "BLOCKED","missing":missing,"fixture_rule":"Synthetic non-production data only"},indent=2))
sys.exit(0 if not missing else 2)
