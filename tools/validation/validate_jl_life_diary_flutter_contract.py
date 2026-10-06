#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ERRORS = []


def require(condition, message):
    if not condition:
        ERRORS.append(message)


mapping_path = ROOT / "ontology/projections/life-diary-flutter-mapping-v1.json"
backlog_path = ROOT / "docs/product/JL-LD-003_Flutter_MVP_Implementation_Backlog_1.0.csv"
canonical_path = ROOT / "canonical/sources/JESUSLIFE_CANONICAL_OBJECT_REGISTER_1.0.csv"
acceptance_path = ROOT / "tests/acceptance/life-diary/LIFE_DIARY_MVP_ACCEPTANCE_1.0.csv"

for path in (mapping_path, backlog_path, canonical_path, acceptance_path):
    require(path.exists(), f"missing required file: {path.relative_to(ROOT)}")

if not ERRORS:
    mapping = json.loads(mapping_path.read_text(encoding="utf-8"))
    with canonical_path.open(encoding="utf-8-sig", newline="") as handle:
        canonical_rows = list(csv.DictReader(handle))
    canonical_ids = {row["canonical_id"] for row in canonical_rows}
    canonical_labels = {row["canonical_id"]: row["ko_label"] for row in canonical_rows}

    expected_questions = {f"q{i}": f"JL-LD-Q0{i}" for i in range(1, 8)}
    require(mapping.get("question_mapping") == expected_questions, "Q1-Q7 mapping mismatch")
    require(set(expected_questions.values()).issubset(canonical_ids), "question IDs missing from Canonical register")
    confession_id = mapping.get("canonical_confession_id")
    require(confession_id in canonical_ids, "confession ID missing from Canonical register")
    require(mapping.get("canonical_confession_ko") == canonical_labels.get(confession_id), "confession text mismatch")
    require(mapping.get("analytics_excludes_raw_text_by_default") is True, "raw text analytics exclusion must be true")
    require(mapping.get("season_size") == 50, "season size must be 50")

    with acceptance_path.open(encoding="utf-8-sig", newline="") as handle:
        acceptance_ids = {row["test_id"] for row in csv.DictReader(handle)}
    require(acceptance_ids == {f"LD-{i:03d}" for i in range(1, 16)}, "acceptance registry must contain LD-001 through LD-015")

    with backlog_path.open(encoding="utf-8-sig", newline="") as handle:
        backlog_rows = list(csv.DictReader(handle))
    require(len(backlog_rows) == 9, "Flutter backlog must contain 9 work items")
    require(all(row["status"] == "READY" for row in backlog_rows), "all initial backlog items must be READY")

result = {
    "gate": "JL-LD-FLUTTER-CONTRACT",
    "status": "PASS" if not ERRORS else "FAIL",
    "flutter_work_items": 9,
    "acceptance_tests_linked": 15,
    "canonical_change": "NONE",
    "runtime_proof": "NOT_RUN",
    "errors": ERRORS,
}
print(json.dumps(result, ensure_ascii=False, indent=2))
raise SystemExit(0 if not ERRORS else 1)
