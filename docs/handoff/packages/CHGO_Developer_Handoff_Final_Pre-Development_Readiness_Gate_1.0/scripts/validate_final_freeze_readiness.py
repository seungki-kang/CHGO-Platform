import csv,sys,json
rows=list(csv.DictReader(open(sys.argv[1],encoding='utf-8-sig')))
blocking=[{'gate':r['gate_id'],'state':r['state']} for r in rows if r['gate_id'] in {'B-02','B-03','B-04','C-02'} and r['state'] not in {'PASS','CLOSED','ACTIVE'}]
print(json.dumps({'final_freeze':'READY' if not blocking else 'NOT_READY','blocking':blocking},indent=2))
raise SystemExit(0 if not blocking else 2)
