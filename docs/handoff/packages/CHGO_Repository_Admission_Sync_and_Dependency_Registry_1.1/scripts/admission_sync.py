import csv,pathlib,shutil,hashlib,argparse
p=argparse.ArgumentParser(); p.add_argument("--register",required=True); p.add_argument("--source-root",required=True); p.add_argument("--repo-root",required=True); p.add_argument("--apply",action="store_true"); a=p.parse_args()
for r in csv.DictReader(open(a.register,encoding="utf-8-sig")):
    c=list(pathlib.Path(a.source_root).rglob(r["filename"]))
    if not c: print("MISSING",r["artifact_id"],r["filename"]); continue
    src=c[0]; dst=pathlib.Path(a.repo_root)/r["target_repository_path"]/r["filename"]; h=hashlib.sha256(src.read_bytes()).hexdigest()
    print("COPY" if a.apply else "DRY-RUN",r["artifact_id"],"->",dst,h)
    if a.apply: dst.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(src,dst)
