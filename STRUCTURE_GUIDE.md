# Church OS Repository Structure Guide 2.0

## Scope

This repository holds Church OS only. CHGO engine content (Canonical, ontology, academy, question bank, measurement) belongs in `CHGO`. Life Diary content belongs in `CHGO-Life-Diary-Flutter`. Unified ID and consent will belong to JesusLife One.

## Layout

| Path | Purpose |
| --- | --- |
| `docs/product`, `docs/ux` | Church OS requirements, experience architecture, UX and information architecture |
| `docs/architecture` | White-label and headless architecture; contracts with other products (Church OS side) |
| `docs/adr` | Church OS decisions |
| `docs/privacy-security` | Privacy policy (C-02) and tenant boundaries |
| `docs/governance` | Gate reports, audits, carry-forward matrix, split record |
| `docs/handoff` | Developer handoff packages, including the B-02 PostgreSQL execution pack used by CI |
| `docs/operations` | E5 runtime and rollback runbooks |
| `db` | Forward-only PostgreSQL migrations and validation |
| `api` | OpenAPI v2 and compatibility records; `api/contracts` holds consumer copies of cross-product contracts |
| `apps` | Church OS app and admin console |
| `services` | Church service, identity (consumer side), integration and privacy gateways, localization |
| `packages` | Shared types and UI components |
| `localization` | Locales, glossary and regional privacy overlays |
| `tests` | Contract, integration, security, acceptance, regression and database tests |
| `infrastructure`, `.github` | CI, deployment, environments and observability |
| `changes`, `releases`, `feature-flags` | Change objects, release manifests, rollback registers and rollout flags |
| `tools`, `scripts` | Validators and CI helpers |
| `backlog` | Church OS implementation backlog |
| `evidence` | Actual execution evidence only |

## Rules

- Church OS never reads another product's database. It connects through versioned APIs and events.
- Pastor and administrator views are aggregate-only. No spiritual scores, ranks or per-person growth views.
- Church membership never implies consent and never grants access to a member's diary.
- Raw diary, prayer or counseling text is never written to general logs, events, analytics or evidence.
- Candidate is not evidence and NOT_RUN is not PASS.
- Applied migrations are immutable; use forward migrations.
- Do not commit secrets, `.pytest_cache`, `__pycache__` or `.pyc` files.
