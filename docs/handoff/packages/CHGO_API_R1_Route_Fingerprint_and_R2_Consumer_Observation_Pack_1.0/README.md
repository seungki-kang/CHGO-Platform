# CHGO API R1 Route Fingerprint + R2 Consumer Observation Pack 1.0

This pack separates source-declared evidence from runtime evidence.

Already generated:
- declared_route_fingerprint.csv/json from authoritative v1.0 and consolidated v2 OpenAPI.
- SHA-256 fingerprints and declared route inventory.

Not yet executed:
- deployed gateway/service route enumeration.
- real consumer traffic/config/code observation.

To complete R1/R2:
1. Export deployed routes into templates/runtime_route_inventory_template.csv.
2. Record actual clients/integrations in templates/consumer_observation_template.csv.
3. Run scripts/compare_runtime_routes.py against the two OpenAPI files and the completed runtime CSV.
4. Preserve outputs under evidence/ as immutable run evidence.

Never convert UNKNOWN/EVIDENCE_REQUIRED to OBSERVED without a concrete evidence reference.
