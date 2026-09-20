# CHGO Repository Organization and Structure Freeze Candidate 1.0

Date: 2026-09-13

## Decision

The uploaded `Repository.zip` contained two complete repository roots and two nested delivery ZIP files. This candidate selects `CHGO-Platform_Dependency_Registry_1.1_Re-Census_Candidate` as the source, renames the working root to `CHGO-Platform`, and excludes the older duplicate tree and nested ZIP files from the organized deliverable.

## Changes made

- Created one active repository root named `CHGO-Platform`.
- Preserved all substantive files from the newest Re-Census candidate.
- Removed 18 generated cache and bytecode files from the new candidate.
- Moved the legacy root manifest into `docs/governance/archive/manifests`.
- Preserved the previous README in `docs/governance/archive/readme`.
- Added forward-looking folders for Life OS, administration, reasoning, localization, integration, shared packages, infrastructure, global documentation and end-to-end tests.
- Added a machine-readable structure registry, current file inventory and validator.

## Unchanged boundaries

Canonical and Governance meaning were not edited. Runtime NOT_RUN states remain unchanged. This artifact is a Structure Freeze Candidate, not an approved final freeze.
