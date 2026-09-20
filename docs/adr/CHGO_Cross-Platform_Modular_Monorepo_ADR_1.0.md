# CHGO Cross-Platform Modular Monorepo ADR 1.0

Status: CANDIDATE — architecture decision for implementation baseline

## Decision

CHGO Engine, Scripture, Prayer and Church OS are independent product and data domains. During the initial development stage they are developed in one private modular monorepo. Physical repository separation is deferred until team, release, security or deployment boundaries require it.

Consumer-facing names are not fixed by this ADR. Internal technical names remain neutral so trademark or marketing changes do not require API, database or service renaming.

## Non-negotiable authority flow

JesusLife Canonical defines meaning. CHGO structures growth intelligence. Product applications consume capabilities without redefining Canonical meaning.

## Domain ownership

- `chgo-engine`: pseudonymous growth signals, evidence, reasoning and recommendations.
- `scripture-service`: Scripture content metadata, reading progress and contextual links.
- `prayer-service`: prayer requests, participation, lifecycle and privacy-scoped testimony metadata.
- `church-service`: church tenant, membership, role, group and operational records.
- `identity-core`: canonical person identity, authentication, account linking and church membership linkage.
- `privacy-gateway`: consent, purpose, scope, retention and protected-data decisions.
- `integration-gateway`: versioned APIs, events, webhooks, adapters and rate limits.

## Integration rules

1. No product reads another product's database directly.
2. Cross-domain access uses versioned API or event contracts.
3. Login unification does not imply automatic personal-data sharing.
4. Email alone must not merge accounts or church memberships.
5. Church OS remains operational when CHGO intelligence is unavailable.
6. Scripture and Prayer products remain independently usable.
7. Raw diary and highly sensitive prayer text are never general CHGO growth records.
8. Every protected exchange requires consent, purpose, scope and audit evidence.

## Repository strategy

The initial repository remains `CHGO-Platform` with independent modules. A product may later move to a separate repository only after its API/event contract, identity contract, data ownership, migration path and rollback plan are stable.

## Gate

This ADR establishes boundaries only. It is not runtime evidence and does not close B-02, B-03, B-04, C-02 or E5 runtime gates.
