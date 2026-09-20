# CHGO Repository Structure Guide 1.0

## One active root

Use this `CHGO-Platform` folder as the only working repository root. Do not place another repository ZIP or another complete `CHGO-Platform` tree inside it.

## Authority and runtime structure

| Path | Purpose |
| --- | --- |
| `canonical` | JesusLife approved meaning authority and source provenance |
| `ontology` | Machine-readable classes, relations, rules, schemas, projections and validation |
| `registry` | Artifact, dependency and physical file registries |
| `docs` | Governance, architecture, product, privacy, roadmap, handoff and research documents |
| `db` | Immutable forward migrations, seeds, views and database validation |
| `api` | Versioned OpenAPI contracts and compatibility records |
| `services` | Growth, evidence, privacy, reasoning, localization and integration services |
| `apps` | Church OS, Life OS and administration applications |
| `packages` | Shared types, ontology SDK and UI components |
| `localization` | Locale content, glossary and regional policy overlays |
| `tests` | Unit, contract, integration, security, acceptance, fixture and end-to-end tests |
| `infrastructure` | CI, deployment, environment templates and observability |
| `changes` | Proposed, approved and released Change Objects |
| `releases` | Release manifests, compatibility, rollback and observation records |
| `feature-flags` | Staged-rollout configuration and policy |
| `tools` | Validation, impact, migration and release automation |
| `backlog` | Implementation backlog and release-slice planning |
| `evidence` | Actual execution evidence only |

## Non-negotiable rules

- JesusLife Canonical meaning is not changed by runtime or AI.
- Candidate is not Evidence and NOT_RUN is not PASS.
- Raw Life Diary belongs in the Personal Vault boundary.
- Pastor access is aggregate-only and Coach access requires the Dual Gate.
- Translation change is not Ontology change.
- Applied migrations are immutable; use forward migrations.
- Do not commit secrets, raw diary text, `.pytest_cache`, `__pycache__` or `.pyc` files.

## Current state

Lifecycle: REPOSITORY STRUCTURE FREEZE CANDIDATE

The structure is organized for continuing development, but final freeze remains blocked by the recorded B-02, B-03, B-04 and C-02 gates.
