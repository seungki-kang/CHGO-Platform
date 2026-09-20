# CHGO GitHub Baseline Admission Report 2.0

## Decision

The clean E5 cloud repository is the base for the GitHub candidate. The uploaded legacy `CHGO.zip` is retained as a source archive and is not bulk-merged.

## Admitted

- Clean E5 repository contents and recorded static evidence.
- CHGO Project Master Context and Operating Instructions 1.0.
- CHGO definition anchored to JesusLife Canonical.
- CHGO Constitution 2.
- CHGO Core Philosophy 3.
- Cross-platform modular monorepo ADR.
- Neutral module placeholders and product-domain ownership register.

## Indexed but not admitted

The legacy archive contains 1,613 extracted files, including many HWP documents, historical duplicates, working drafts, nested repositories and update ZIP files. These are tracked in `registry/source_admission_inventory_2.0.csv` and remain outside authoritative runtime paths until individually reviewed.

## Excluded from GitHub candidate

- Nested ZIP and full repository copies.
- Generated caches, bytecode and local test caches.
- Local credentials, environment files and secret material.
- Unreviewed HWP drafts and superseded duplicates.
- Raw textbook PDFs; source identity and hash are registered instead.

## Truthful gate state

- Static E5 regression: PASS.
- B-04 OpenAPI static validation: PASS.
- C-02 static structure: PASS.
- Runtime regression: NOT_RUN.
- Rollback runtime proof: NOT_RUN.
- Production gate: OPEN.
- Privacy approvals and regional packs: incomplete.

This candidate is suitable for a private GitHub baseline commit, not for production release.
