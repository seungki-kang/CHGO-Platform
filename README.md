# JesusLife Church OS

Church OS is the white-label church app of the JesusLife One platform. Each church that joins gets its own branded app and uses it as the space its community needs: membership, groups, care, formation, mission, prayer requests and church operations.

This repository holds Church OS only. It was renamed from `CHGO-Platform` on 2026-10-17. The CHGO engine and Life Diary now live in their own repositories and connect to Church OS by API. See `docs/governance/Repository_Split_Record_2026-10-17.md` for what moved where and what is still mixed.

## The platform

| Product | Repository | Role |
| --- | --- | --- |
| JesusLife One | (planned) | Unified ID and consent across all products |
| **Church OS** | **`JesusLife-Church-OS`** | White-label church app |
| CHGO | `CHGO` | JesusLife textbook ontology, academy, question bank, community health measurement engine |
| Life Diary | `CHGO-Life-Diary-Flutter` | Personal diary; raw text never leaves it without the user's permission |
| 성경통독 네트워크, 중보기도 네트워크, 너랑나랑 | Separate repositories | Connected by API |

Church OS never reads another product's database. Pastors see community aggregates only, never an individual's diary or growth record.

## State

Pre-development. Static checks pass (B-04 OpenAPI, C-02 privacy policy, E5 static regression). The PostgreSQL migrations V001–V012 passed 12 of 12 tests in a local replay of the E5 workflow on PostgreSQL 16; the GitHub Actions run itself has not been recorded as evidence yet. Runtime API tests, approvals and regional privacy packs remain OPEN or NOT_RUN.

Read `START_HERE.md` first.
