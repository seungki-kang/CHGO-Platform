#!/usr/bin/env python3
"""Static B-04 validation for the standalone CHGO OpenAPI v2 baseline."""
from __future__ import annotations

import csv
import hashlib
import json
import re
import sys
from pathlib import Path

import yaml

ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'api/openapi/v2/CHGO_Public_and_Headless_OpenAPI_v2_Consolidated_Baseline_1.0.yaml'
DELTA=ROOT/'api/openapi/v2/CHGO_Church_OS_OpenAPI_Delta_2.0.yaml'
COMPAT=ROOT/'api/compatibility/CHGO_API_v1-v2_Endpoint_Compatibility_Matrix_1.1.csv'
METHODS={'get','post','put','patch','delete','head','options','trace'}


def resolve(doc, ref):
    if not ref.startswith('#/'):
        raise KeyError('external ref not allowed: '+ref)
    cur=doc
    for token in ref[2:].split('/'):
        cur=cur[token.replace('~1','/').replace('~0','~')]
    return cur


def walk(value):
    if isinstance(value,dict):
        yield value
        for child in value.values(): yield from walk(child)
    elif isinstance(value,list):
        for child in value: yield from walk(child)


def main():
    spec=yaml.safe_load(SPEC.read_text(encoding='utf-8'))
    delta=yaml.safe_load(DELTA.read_text(encoding='utf-8'))
    errors=[]; operations=[]; refs=[]
    for node in walk(spec):
        if '$ref' in node: refs.append(node['$ref'])
    for ref in refs:
        try: resolve(spec,ref)
        except Exception: errors.append('unresolved ref: '+str(ref))
    for path,item in spec.get('paths',{}).items():
        template=set(re.findall(r'\{([^}]+)\}',path))
        for method,op in item.items():
            if method.lower() not in METHODS: continue
            oid=op.get('operationId'); operations.append((method.lower(),path,oid,op))
            params=[]
            for p in item.get('parameters',[])+op.get('parameters',[]):
                params.append(resolve(spec,p['$ref']) if '$ref' in p else p)
            declared={p.get('name') for p in params if p.get('in')=='path' and p.get('required') is True}
            if declared!=template: errors.append(f'path parameter mismatch {method.upper()} {path}: {declared} != {template}')
    ids=[x[2] for x in operations]
    if any(not x for x in ids): errors.append('missing operationId')
    if len(set(ids))!=len(ids): errors.append('duplicate operationId')
    missing_delta=sorted(set(delta.get('paths',{}))-set(spec.get('paths',{})))
    if missing_delta: errors.append('delta paths missing: '+','.join(missing_delta))
    schemes=spec.get('components',{}).get('securitySchemes',{})
    if not {'userBearer','serviceCredential'} <= set(schemes): errors.append('required security schemes missing')
    for path in ('/headless/webhooks','/integrations/vault/webhooks'):
        op=spec['paths'][path]['post']; scopes=[s for req in op.get('security',[]) for values in req.values() for s in values]
        if 'webhook.manage' not in scopes: errors.append(path+' missing webhook.manage')
    for path in ('/pastor/community-growth','/churches/{churchId}/growth-aggregates'):
        text=json.dumps(spec['paths'][path],ensure_ascii=False).lower()
        if 'aggregate' not in text: errors.append(path+' lacks aggregate-only contract')
    vault_hook=json.dumps(spec['paths']['/integrations/vault/webhooks'],ensure_ascii=False).lower()
    if 'metadata-only' not in vault_hook or 'never raw diary' not in vault_hook: errors.append('Vault webhook privacy contract missing')
    with COMPAT.open(encoding='utf-8-sig',newline='') as f: compat=list(csv.DictReader(f))
    if not compat: errors.append('compatibility matrix empty')
    result={
      'result':'PASS' if not errors else 'FAIL','openapi':spec.get('openapi'),
      'paths':len(spec.get('paths',{})),'operations':len(operations),
      'schemas':len(spec.get('components',{}).get('schemas',{})),'refs':len(refs),
      'delta_paths_covered':len(delta.get('paths',{})),'compatibility_rows':len(compat),
      'sha256':hashlib.sha256(SPEC.read_bytes()).hexdigest(),'errors':errors,
    }
    print(json.dumps(result,ensure_ascii=False,indent=2))
    return 0 if not errors else 1


if __name__=='__main__': sys.exit(main())
