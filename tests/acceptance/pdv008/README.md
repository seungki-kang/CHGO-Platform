# PDV-008 Executable Test Foundation 1.0

This package converts the 84-gate PDV-008 document into a machine-readable execution register and runnable static/preflight checks.

- `fixtures/pdv008_test_register_1.0.csv`: 84 unique tests mapped one-to-one to 84 parent gates.
- `scripts/run_static_validation.py`: validates register integrity and the consolidated OpenAPI baseline.
- `scripts/run_runtime_preflight.py`: fails closed until the controlled test environment and synthetic identities are supplied.
- `evidence/pdv7_static_contract_results_1.0.csv`: 20 executable static API-boundary checks.

Static PASS is not runtime evidence. The 84 runtime statuses remain NOT_RUN. Real Life Diary, prayer, counseling, church member, token or key data is prohibited in fixtures and evidence.
