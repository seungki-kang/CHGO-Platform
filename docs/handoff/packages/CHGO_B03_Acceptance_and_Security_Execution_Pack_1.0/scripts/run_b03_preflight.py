#!/usr/bin/env python3
import importlib.util, json, os, sys
required=["CHGO_API_V2_BASE_URL"]
missing=[name for name in required if not os.getenv(name)]
deps={name: bool(importlib.util.find_spec(name)) for name in ("pytest","requests","yaml")}
result={"result":"READY" if not missing and all(deps.values()) else "BLOCKED","missing_environment":missing,"dependencies":deps,"note":"Use synthetic non-production credentials only."}
print(json.dumps(result,indent=2))
sys.exit(0 if result["result"]=="READY" else 2)
