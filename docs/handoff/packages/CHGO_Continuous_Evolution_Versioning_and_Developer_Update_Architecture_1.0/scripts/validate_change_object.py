import csv,sys,json
rows=list(csv.DictReader(open(sys.argv[1],encoding='utf-8-sig')))
d={r['field']:r.get('value','') for r in rows} if rows and 'field' in rows[0] and 'value' in rows[0] else {}
required=['change_id','title','owner','target_artifact_ids','authority_level','change_type','reason','affected_components','compatibility','migration_required','rollback_strategy','affected_tests','privacy_security_impact','localization_impact']
missing=[k for k in required if not d.get(k)]
print(json.dumps({'status':'PASS' if not missing else 'NOT_READY','missing':missing},indent=2))
raise SystemExit(0 if not missing else 2)
