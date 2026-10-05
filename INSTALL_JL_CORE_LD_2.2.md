# Install JL Core and Life Diary Update 2.2

## Purpose

This additive update introduces the JesusLife Canonical Source Registry candidate and the Life Diary executable data foundation. It does not include raw textbook/workbook files and does not modify existing production data.

## Install on Windows

1. Copy the contents of this `CHGO-Platform` folder over `D:\CHGO-Platform`.
2. From Command Prompt:

```bat
cd /d D:\CHGO-Platform
python tools\validation\validate_jl_life_diary_foundation.py
git status
```

Expected validation:

```text
"gate": "JL-CORE-LD"
"status": "PASS"
"canonical_objects": 24
"acceptance_tests": 15
"sqlite_migration": "PASS"
```

## Review before approval

- The author must review the Q1–Q7 meanings and Q2 explanation.
- Privacy approval remains separate from static structure validation.
- `CANDIDATE` must not be relabeled `APPROVED` automatically.

## Commit after validation

```bat
git add .
git commit -m "Add JesusLife canonical and Life Diary runtime foundation 2.2"
git push
```
