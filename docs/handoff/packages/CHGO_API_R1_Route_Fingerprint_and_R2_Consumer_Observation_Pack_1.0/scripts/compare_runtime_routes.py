import csv, sys, yaml, json
from pathlib import Path
METHODS={"get","post","put","patch","delete","options","head"}
def load(p):
    with open(p,encoding="utf-8") as f:return yaml.safe_load(f)
def declared(spec):
    return {(m.upper(),p) for p,item in spec["paths"].items() for m in item if m.lower() in METHODS}
if len(sys.argv)!=4:
    raise SystemExit("usage: python compare_runtime_routes.py <v1.yaml> <v2.yaml> <runtime_route_inventory.csv>")
v1,v2=load(sys.argv[1]),load(sys.argv[2])
d1,d2=declared(v1),declared(v2)
obs=set()
with open(sys.argv[3],encoding="utf-8-sig") as f:
    for r in csv.DictReader(f):
        if r.get("method") and r.get("route"):
            obs.add((r["method"].upper().strip(),r["route"].strip()))
decl=d1|d2
result={
 "observed_count":len(obs),
 "declared_count":len(decl),
 "observed_not_declared":sorted([list(x) for x in obs-decl]),
 "declared_not_observed":sorted([list(x) for x in decl-obs]),
 "matched":len(obs&decl)
}
print(json.dumps(result,indent=2))
