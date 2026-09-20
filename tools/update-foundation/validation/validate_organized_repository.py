#!/usr/bin/env python3
from pathlib import Path
import csv, hashlib, sys
root=Path(sys.argv[1] if len(sys.argv)>1 else '.').resolve()
manifest=root/'REPOSITORY_MANIFEST_CANDIDATE_1.2.csv'
missing=[]; mismatch=[]; forbidden=[]
with manifest.open(encoding='utf-8-sig') as f:
    rows=list(csv.DictReader(f))
for r in rows:
    p=root/r['path']
    if not p.is_file(): missing.append(r['path']); continue
    h=hashlib.sha256(p.read_bytes()).hexdigest()
    if h!=r['sha256']: mismatch.append(r['path'])
for p in root.rglob('*'):
    if p.is_file() and (p.suffix=='.pyc' or '.pytest_cache' in p.parts or '__pycache__' in p.parts): forbidden.append(p.relative_to(root).as_posix())
print({'manifest_entries':len(rows),'missing':missing,'hash_mismatch':mismatch,'forbidden_generated_files':forbidden})
raise SystemExit(1 if missing or mismatch or forbidden else 0)
