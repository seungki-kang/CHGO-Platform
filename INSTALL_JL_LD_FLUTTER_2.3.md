# Install JL-LD Flutter Integration 2.3

This is an additive CHGO-Platform update. It does not contain or overwrite the separate Flutter application repository.

## Validate on Windows PowerShell

From `D:\CHGO-Platform` run:

```powershell
& "$env:LocalAppData\Programs\Python\Python314\python.exe" tools\validation\validate_jl_life_diary_flutter_contract.py
```

Expected result:

```text
JL-LD-FLUTTER-CONTRACT: PASS
flutter_work_items: 9
acceptance_tests_linked: 15
canonical_change: NONE
runtime_proof: NOT_RUN
```

`runtime_proof: NOT_RUN` is expected until the actual Flutter app implements the contract and LD-001 through LD-015 are executed.

## Apply to the Flutter repository

Use `docs/product/JL-LD-002_Flutter_MVP_Integration_Contract_1.0.md` and `docs/product/JL-LD-003_Flutter_MVP_Implementation_Backlog_1.0.csv` as the implementation order. Do not copy the CHGO SQLite file blindly over an existing Flutter database; compare its current schema and create the next safe app migration.
