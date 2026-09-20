# CHGO B-03 Acceptance and Security Execution Pack 1.0

This package consolidates the B-03 contract, MVP acceptance, integration, security, privacy, and reliability test gate.

Current decision: `BLOCKED_RUNTIME`. Static integrity is validated, but no executable API/MVP target or synthetic credentials are present. Runtime evidence must never be invented.

## Privacy invariants

- Never place raw Life Diary, prayer, repentance, counseling, or third-party text in general logs, events, analytics, Canonical, or registries.
- Use pseudonymization, minimization, purpose binding, separated consent, retention/deletion/export controls, and tenant/role denial.
- Pastor and coach access is limited to explicitly consented care contexts; role alone does not grant raw-vault access.
- Safety escalation follows a pre-disclosed policy and does not silently expand ordinary access.

## Execution order

1. Close or provide evidence linkage for B-02 database runtime.
2. Provide a controlled non-production API/MVP target and synthetic fixtures only.
3. Close B-04 consolidated OpenAPI v2 source-contract dependency.
4. Run `scripts/run_b03_preflight.py`.
5. Execute the registered suites and attach immutable logs to `evidence/`.
6. Review every BLOCKER case before changing B-03 from OPEN to PASS.
