# Repository Split Record 2026-10-17

Status: **EXECUTED**
Decision: product owner, 2026-10-17 (option B; Canonical register owned by CHGO)
Last commit before the split: `b64dd9a`

## 1. What happened

`CHGO-Platform` mixed three products: Church OS, the CHGO engine and Life Diary. The product owner decided that each product is developed in its own repository and connected by API, under the JesusLife One platform with a unified ID.

| Product | Repository | How the content got there |
| --- | --- | --- |
| Church OS | `JesusLife-Church-OS` (this repository, renamed from `CHGO-Platform`) | Stayed; history, pull requests and CI kept |
| CHGO engine: JesusLife textbook ontology, academy, question bank, community health measurement | `CHGO` (new) | Re-uploaded by the owner from the archived originals |
| Life Diary | `CHGO-Life-Diary-Flutter` | Moved earlier under ADR-LD01 (LD-D6); the ADR itself moved there in this change |
| 성경통독 네트워크, 중보기도 네트워크, 너랑나랑 | Separate repositories | Developed independently and connected by API |

Nothing was lost. Every removed file is in this repository's history. To get one back:

```bash
git show b64dd9a:<path> > <file>
```

or open `https://github.com/seungki-kang/JesusLife-Church-OS/tree/b64dd9a`.

## 2. Gate changes

- **E5 static regression.** E5-R01 (CHGO repository structure freeze) and E5-R05 (PDV-008 Vault) are `RETIRED` in `tests/regression/E5_regression_execution_register_1.0.csv`. `tools/validation/validate_e5_regression.py` no longer runs the PDV-008 validation and now checks that every active suite's target exists.
- **B-04, C-02, B-02, B-03.** Unchanged. All static validators still pass.

## 3. Still mixed — to resolve in later changes

These files serve Church OS but still carry content from other products. They stay for now because removing the content would break hash-bound evidence or a gate, or because the owning repository does not exist yet.

| Item | What is mixed | Plan |
| --- | --- | --- |
| `api/openapi/v2/CHGO_Public_and_Headless_OpenAPI_v2_Consolidated_Baseline_1.0.yaml` | 27 Life Diary operations: 23 `/me/vaults*`, 2 `/coach/shared-vault-resources*`, 2 `/integrations/vault/*` | Church OS API baseline 2.0 removes them. The R1, R5, R6 and B-04 packs below are bound to this file's SHA-256 and are updated in the same change |
| `api/compatibility/`, R1/R2, R6 and dual-major packs, B-04 runbook | v1 is the CHGO engine API (episodes, reasoning, question instances). These packs test v1/v2 coexistence | Same change: Church OS API 2.0 drops the v1 lineage; the v1 design stays in the CHGO archive |
| R3/R4 negative test pack (`docs/handoff/packages/CHGO_API_R3_*`, `tests/security/CHGO_API_R3_*`) | R3 (auth) is Church OS. R4 (Vault privacy) is Life Diary | Same change: keep R3, remove R4 |
| C-02 privacy policy (`docs/privacy-security/C-02_*`, `docs/adr/ADR-C02_*`, `registry/C02_*`, `localization/regional-compliance/C02_*`) | Vault rules (C02-01, 02, 05, 06, 09) assume server-held keys, which Life Diary decision LD-D1 (end-to-end encryption) replaced. The rest (MFA, aggregate-only pastor views, pseudonyms, consent, minors) applies to Church OS | Revise into a Church OS privacy baseline. Platform-wide rules move to JesusLife One |
| `docs/architecture/CHGO_Shared_Identity_Membership_and_Product_Consent_Contract_1.0.md`, `api/contracts/shared-identity-membership-consent-v1.yaml`, `services/identity-core/` | Unified ID and consent for all products | Owner is JesusLife One. Moves when that repository exists; Church OS keeps a consumer copy |
| `docs/privacy-security/CHGO_Identity_Tenant_and_Personal_Vault_Boundary_Specification_1.0.docx` | Tenant boundary (Church OS) and Vault boundary (Life Diary) | Keep the tenant part in the Church OS privacy baseline |
| `docs/architecture/CHGO_Church_OS_to_CHGO_Engine_Integration_Contract_1.0.docx` and the 9 CHGO bridge tables in V010 | The Church OS side of the CHGO connection | Stays here as the consumer side. CHGO publishes the provider contract |
| `CHGO_` prefixes in file names | Historical names | Kept, because validators, manifests and evidence refer to them |
| `docs/governance/CHGO_Platform_Runtime_Security_Audit_2.4.md` | Mentions removed paths | Kept verbatim as an audit record |

## 4. Removed files

192 files. The list below is grouped by where the content belongs.

### CHGO (re-uploaded by the owner to the new `CHGO` repository) — 151 files

**CHGO (package/manifest history)** (15)

- `COMPLETE_PACKAGE_README_2.2.md`
- `INSTALL_ROADMAP_2.0_UPDATE.md`
- `REPOSITORY_MANIFEST_CANDIDATE_1.1.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.2.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.3.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.4.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.5.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.6.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.7.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.8.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_1.9.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_2.0.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_2.1.csv`
- `REPOSITORY_MANIFEST_CANDIDATE_2.2.csv`
- `changes/CHGO_CHANGE_OBJECT_ROADMAP_2.0.json`

**CHGO (engine API v1 lineage)** (1)

- `api/openapi/v1/.gitkeep`

**CHGO (engine/ecosystem backlog)** (2)

- `backlog/CHGO_Execution_Backlog_2.0.csv`
- `backlog/CHGO_Implementation_Backlog_1.1.xlsx`

**CHGO (canonical)** (10)

- `canonical/governance/CHGO_CONSTITUTION_2.docx`
- `canonical/governance/CHGO_CORE_PHILOSOPHY_3.docx`
- `canonical/governance/CHGO_Definition_JesusLife_Canonical_Highest_Meaning_Authority_1.0.docx`
- `canonical/governance/CHGO_Project_Master_Context_and_Operating_Instructions_1.0.docx`
- `canonical/jesuslife/S0-02_JesusLife_Canonical_Scope_Meaning_Freeze_1.0.docx`
- `canonical/jesuslife/S0-03_JesusLife_Ecclesiology_Extension_1.0.docx`
- `canonical/registry/.gitkeep`
- `canonical/sources/CANONICAL_SOURCE_REGISTER_1.0.csv`
- `canonical/sources/JESUSLIFE_CANONICAL_OBJECT_REGISTER_1.0.csv`
- `canonical/sources/README.md`

**superseded (monorepo plan replaced by separate repositories)** (1)

- `docs/adr/CHGO_Cross-Platform_Modular_Monorepo_ADR_1.0.md`

**CHGO (architecture/governance)** (3)

- `docs/architecture/CHGO_5-Layer_Architecture_Standard_1.0.docx`
- `docs/architecture/CHGO_Artifact_Dependency_Registry_and_Update_Automation_Foundation_1.0.docx`
- `docs/architecture/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0.docx`

**CHGO (governance / repository history)** (26)

- `docs/governance/CHGO_Artifact_Versioning_Naming_and_Repository_Governance_Standard_1.0.docx`
- `docs/governance/CHGO_Bootstrap_27_Re-Admission_Matrix_1.0.xlsx`
- `docs/governance/CHGO_Canonical_Artifact_Manifest_and_Supersession_Matrix_1.0.xlsx`
- `docs/governance/CHGO_Clean_Repository_1.0_Setup_Guide (2).docx`
- `docs/governance/CHGO_Clean_Repository_1.0_Setup_Guide.docx`
- `docs/governance/CHGO_Clean_Repository_Admission_and_Validation_Standard_1.0.docx`
- `docs/governance/CHGO_Clean_Repository_Architecture_and_Migration_Plan_1.0.docx`
- `docs/governance/CHGO_Clean_Repository_Reconciliation_and_Manifest_Migration_1.0.docx`
- `docs/governance/CHGO_Clean_Repository_Reconciliation_and_Manifest_Migration_1.0.xlsx`
- `docs/governance/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/README.md`
- `docs/governance/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/docs/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0.docx`
- `docs/governance/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/policies/continuous_evolution_policy.json`
- `docs/governance/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/scripts/validate_change_object.py`
- `docs/governance/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/templates/change_object_template.csv`
- `docs/governance/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/templates/compatibility_matrix_template.csv`
- `docs/governance/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/templates/platform_release_manifest_template.json`
- `docs/governance/CHGO_Dependency_Registry_1.1_Re-Census.docx`
- `docs/governance/CHGO_GitHub_Baseline_Admission_Report_2.0.md`
- `docs/governance/CHGO_REPOSITORY_MANIFEST_Migrated_1.0.csv`
- `docs/governance/CHGO_Repository_Full_Dependency_Census_1.0.xlsx`
- `docs/governance/CHGO_Repository_Organization_and_Structure_Freeze_Candidate_1.0.md`
- `docs/governance/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0.docx`
- `docs/governance/CHGO_Repository_Structure_Freeze_Validation_and_Approval_Package_1.0.docx`
- `docs/governance/S0-01_JesusLife_CHGO_Boundary_Constitution_1.0.docx`
- `docs/governance/archive/manifests/REPOSITORY_MANIFEST_legacy_pre_1.1.csv`
- `docs/governance/archive/readme/README_Pre_Organization_2026-09-13.md`

**CHGO (repository history)** (25)

- `docs/handoff/CHGO_Clean_Repository_1.0_Setup_Guide.docx`
- `docs/handoff/packages/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/README.md`
- `docs/handoff/packages/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/docs/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0.docx`
- `docs/handoff/packages/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/policies/continuous_evolution_policy.json`
- `docs/handoff/packages/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/scripts/validate_change_object.py`
- `docs/handoff/packages/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/templates/change_object_template.csv`
- `docs/handoff/packages/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/templates/compatibility_matrix_template.csv`
- `docs/handoff/packages/CHGO_Continuous_Evolution_Versioning_and_Developer_Update_Architecture_1.0/templates/platform_release_manifest_template.json`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/README.md`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/admission/admission_register_1.1.csv`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/docs/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1.docx`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/evidence/sync_summary.json`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/registry/dependency_edges_1.1.csv`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/registry/global_rollout_priority_1.1.csv`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/repository-extension/repository_extension_registry_1.1.csv`
- `docs/handoff/packages/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/scripts/admission_sync.py`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/README.md`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/docs/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0.docx`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/evidence/source_manifest_sha256.txt`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/pending-admission/post_snapshot_artifacts_pending_admission.csv`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/CHGO_Repository_Full_Dependency_Census_1.0.xlsx`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/dependency_edges_1.0.csv`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/full_artifact_registry_1.0.csv`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/logical_artifact_rollup_1.0.csv`
- `docs/handoff/packages/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/reports/census_summary.json`

**CHGO / JesusLife One (ecosystem roadmap)** (2)

- `docs/roadmap/CHGO_Ecosystem_Master_Roadmap_2.0.md`
- `docs/roadmap/CHGO_Platform_Development_Roadmap_1.0.docx`

**CHGO (canonical source register)** (2)

- `docs/source-register/JL-CORE-001_JesusLife_Canonical_Source_Registry_1.0.md`
- `docs/source-register/README.md`

**CHGO (repository freeze history)** (3)

- `evidence/pre-release/CHGO_GitHub_Baseline_Validation_2.0.json`
- `evidence/pre-release/CHGO_Repository_Structure_Freeze_Validation_1.0.json`
- `releases/manifests/CHGO_Repository_Structure_Freeze_Candidate_1.0.json`

**CHGO (ontology)** (5)

- `ontology/projections/README.md`
- `ontology/registry/.gitkeep`
- `ontology/rules/.gitkeep`
- `ontology/schemas/README.md`
- `ontology/validation/.gitkeep`

**CHGO (repository registry / ecosystem ownership)** (22)

- `registry/REPOSITORY_STRUCTURE_REGISTRY_1.0.csv`
- `registry/artifact_instances_1.1.csv`
- `registry/dependency_edges_1.1_recensus.csv`
- `registry/duplicate_content_groups_1.1.csv`
- `registry/logical_artifact_registry_1.1.csv`
- `registry/organization_validation_summary_1.0.json`
- `registry/product_domain_ownership_1.0.csv`
- `registry/recensus_anomalies_1.1.csv`
- `registry/recensus_validation_summary_1.1.json`
- `registry/repository_file_inventory_1.2.csv`
- `registry/repository_file_inventory_1.3.csv`
- `registry/repository_file_inventory_1.4.csv`
- `registry/repository_file_inventory_1.5.csv`
- `registry/repository_file_inventory_1.6.csv`
- `registry/repository_file_inventory_1.7.csv`
- `registry/repository_file_inventory_1.8.csv`
- `registry/repository_file_inventory_1.9.csv`
- `registry/repository_file_inventory_2.0.csv`
- `registry/repository_file_inventory_2.1.csv`
- `registry/repository_structure_freeze_gate_1.0.csv`
- `registry/source_admission_inventory_2.0.csv`
- `registry/source_admission_summary_2.0.json`

**CHGO (repository registry tooling)** (34)

- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/README.md`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/docs/CHGO_Dependency_Registry_1.1_Re-Census.docx`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/evidence/build_context.json`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/evidence/recensus_validation_summary_1.1.json`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/registry/artifact_instances_1.1.csv`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/registry/dependency_edges_1.1_recensus.csv`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/registry/duplicate_content_groups_1.1.csv`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/registry/logical_artifact_registry_1.1.csv`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/registry/recensus_anomalies_1.1.csv`
- `tools/update-foundation/CHGO_Dependency_Registry_1.1_Re-Census/scripts/validate_recensus.py`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1.docx`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/README.md`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/admission/admission_register_1.1.csv`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/docs/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1.docx`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/evidence/sync_summary.json`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/registry/dependency_edges_1.1.csv`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/registry/global_rollout_priority_1.1.csv`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/repository-extension/repository_extension_registry_1.1.csv`
- `tools/update-foundation/CHGO_Repository_Admission_Sync_and_Dependency_Registry_1.1/scripts/admission_sync.py`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/README.md`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/docs/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0.docx`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/evidence/source_manifest_sha256.txt`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/pending-admission/post_snapshot_artifacts_pending_admission.csv`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/CHGO_Repository_Full_Dependency_Census_1.0.xlsx`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/dependency_edges_1.0.csv`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/full_artifact_registry_1.0.csv`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/registry/logical_artifact_rollup_1.0.csv`
- `tools/update-foundation/CHGO_Repository_Registry_Migration_and_Full_Dependency_Census_1.0/reports/census_summary.json`
- `tools/update-foundation/impact-analysis/.gitkeep`
- `tools/update-foundation/migration/.gitkeep`
- `tools/update-foundation/release/.gitkeep`
- `tools/update-foundation/validation/.gitkeep`
- `tools/update-foundation/validation/validate_organized_repository.py`
- `tools/update-foundation/validation/validate_structure_freeze.py`


### Life Diary — 31 files

**Life Diary / JL Core install history** (5)

- `INSTALL_JL_CORE_LD_2.2.md`
- `INSTALL_JL_LD_FLUTTER_2.3.md`
- `UPDATE_MANIFEST_JL_CORE_LD_2.2.csv`
- `changes/CHGO_CHANGE_OBJECT_JL_CORE_LD_2.2.json`
- `changes/CHGO_CHANGE_OBJECT_JL_LD_FLUTTER_2.3.json`

**Life Diary notice (contract already in CHGO-Life-Diary-Flutter)** (17)

- `db/migrations/chgo/PDV-003_Vault_Data_Model_and_DB_Schema_1.0.sql.MOVED.md`
- `db/migrations/life_diary/V001__life_diary_sqlite_foundation.sql.MOVED.md`
- `docs/architecture/PDV-003_Vault_Data_Model_and_DB_Schema_1.0.docx.MOVED.md`
- `docs/architecture/PDV-004_Vault_Provider_Contract_and_Adapter_Specification_1.0.docx.MOVED.md`
- `docs/architecture/PDV-007_Vault_API_and_OpenAPI_v2_Integration_Specification_1.0.docx.MOVED.md`
- `docs/privacy-security/CHGO_Personal_Data_Vault_and_Life_Diary_Storage_Architecture_1.0.docx.MOVED.md`
- `docs/privacy-security/PDV-002_Personal_Vault_Threat_Model_and_Privacy_Impact_Specification_1.0.docx.MOVED.md`
- `docs/privacy-security/PDV-005_Encryption_Key_Management_and_Recovery_Standard_1.0.docx.MOVED.md`
- `docs/privacy-security/PDV-006_Life_Diary_Retention_Deletion_and_Export_Policy_1.0.docx.MOVED.md`
- `docs/product/JL-LD-001_Life_Diary_Runtime_Schema_1.0.md.MOVED.md`
- `docs/product/JL-LD-002_Flutter_MVP_Integration_Contract_1.0.md.MOVED.md`
- `docs/product/JL-LD-003_Flutter_MVP_Implementation_Backlog_1.0.csv.MOVED.md`
- `ontology/projections/life-diary-flutter-mapping-v1.json.MOVED.md`
- `ontology/schemas/life-diary-runtime-schema-v1.json.MOVED.md`
- `tests/acceptance/life-diary/LIFE_DIARY_MVP_ACCEPTANCE_1.0.csv.MOVED.md`
- `tools/validation/validate_jl_life_diary_flutter_contract.py.MOVED.md`
- `tools/validation/validate_jl_life_diary_foundation.py.MOVED.md`

**moved to CHGO-Life-Diary-Flutter/docs/adr/** (1)

- `docs/adr/ADR-LD01_Life_Diary_Platform_Role_Separation_1.0.md`

**Life Diary backup service (vault test pack)** (8)

- `releases/manifests/CHGO_PDV008_Executable_Test_Foundation_Candidate_1.0.json`
- `tests/acceptance/PDV-008_Vault_Security_Retention_Recovery_and_Provider_Test_Pack_1.0.docx`
- `tests/acceptance/pdv008/README.md`
- `tests/acceptance/pdv008/evidence/pdv7_static_contract_results_1.0.csv`
- `tests/acceptance/pdv008/evidence/static_validation_summary_1.0.json`
- `tests/acceptance/pdv008/fixtures/pdv008_test_register_1.0.csv`
- `tests/acceptance/pdv008/scripts/run_runtime_preflight.py`
- `tests/acceptance/pdv008/scripts/run_static_validation.py`


### Other products — 10 files

**other product placeholder** (10)

- `apps/life-os/README.md`
- `apps/prayer/README.md`
- `apps/scripture/README.md`
- `docs/research/README.md`
- `packages/ontology-sdk/README.md`
- `services/evidence-engine/.gitkeep`
- `services/growth-engine/.gitkeep`
- `services/prayer-service/README.md`
- `services/reasoning-engine/README.md`
- `services/scripture-service/README.md`
