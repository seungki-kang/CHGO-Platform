#!/usr/bin/env python3
from pathlib import Path
import csv, hashlib, sys
root=Path(sys.argv[1]).resolve()
reg=root/'registry/artifact_instances_1.1.csv'
missing=[]; mismatch=[]
with reg.open(encoding='utf-8-sig') as f:
    for r in csv.DictReader(f):
        p=root/r['path']
        if not p.exists(): missing.append(r['path']); continue
        h=hashlib.sha256(p.read_bytes()).hexdigest()
        if h!=r['sha256']: mismatch.append(r['path'])
print({'registered':sum(1 for _ in open(reg,encoding='utf-8-sig'))-1,'missing':missing,'hash_mismatch':mismatch})
raise SystemExit(1 if missing or mismatch else 0)
