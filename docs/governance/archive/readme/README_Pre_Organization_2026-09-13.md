# CHGO Clean Repository 1.0

**Repository state:** PRE-FREEZE CLEAN DEVELOPMENT REPOSITORY\
**Date:** 2026-09-10

This repository is a controlled development baseline. It is **not yet
the final Source of Truth**.

## Admission rule

Source -\> Review -\> Validate -\> Execute/Verify -\> Approve -\>
Promote.

Files are not ACTIVE merely because they are the newest. See: -
`docs/governance/CHGO_Clean_Repository_Admission_and_Validation_Standard_1.0.docx` -
`docs/governance/CHGO_Bootstrap_27_Re-Admission_Matrix_1.0.xlsx` -
`REPOSITORY_MANIFEST.csv`

## Current blockers

-   B-02: PostgreSQL migrations require live clean-run/replay
    validation.
-   B-03: MVP acceptance tests include NOT_RUN cases; test plan is not
    execution evidence.
-   B-04: API v1/v2 lineage requires downstream alignment under the API
    Versioning ADR.
-   Personal Vault/privacy production decisions remain candidate/open
    where explicitly marked.

## Architecture invariants

-   JesusLife Canonical Meaning cannot be redefined by runtime/AI.
-   Church OS operational core must survive CHGO/L2 outage.
-   Person != GrowthEpisode; Candidate != Evidence; Practice != Outcome.
-   Missing != 0; No Opportunity != Failure; Completion != Maturity.
-   Pastor Aggregate Only; Coach Dual Gate; no spiritual
    score/rank/level.
-   Raw Life Diary is not general Growth Evidence storage.
-   Church membership does not imply Personal Vault ownership/access.
-   White-label/headless must preserve tenant, purpose, consent and
    privacy boundaries.

## Folder policy

`docs/` holds approved/candidate specifications and governance.\
`canonical/` holds meaning authority.\
`ontology/` is reserved for admitted ontology runtime artifacts.\
`db/` contains candidate migrations and validation SQL.\
`api/` contains versioned API contracts.\
`tests/` separates plans, contract tests and execution evidence.\
`evidence/pre-release/` is for actual run evidence only.

## Next promotion sequence

1.  White-Label & Headless Integration Architecture 3.0.
2.  Identity, Tenant & Personal Vault Boundary Specification.
3.  Consolidated Public/Headless OpenAPI v2 baseline and B-04 alignment.
4.  Live PostgreSQL B-02 execution.
5.  B-03 contract/acceptance execution.
6.  DGM handoff re-validation and repository freeze decision.
