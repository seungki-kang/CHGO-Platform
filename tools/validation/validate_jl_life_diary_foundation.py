from __future__ import annotations

import csv
import json
import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    schema_path = ROOT / "ontology/schemas/life-diary-runtime-schema-v1.json"
    register_path = ROOT / "canonical/sources/JESUSLIFE_CANONICAL_OBJECT_REGISTER_1.0.csv"
    migration_path = ROOT / "db/migrations/life_diary/V001__life_diary_sqlite_foundation.sql"
    acceptance_path = ROOT / "tests/acceptance/life-diary/LIFE_DIARY_MVP_ACCEPTANCE_1.0.csv"
    required = [schema_path, register_path, migration_path, acceptance_path]
    errors: list[str] = []

    for path in required:
        if not path.is_file():
            errors.append(f"missing:{path.relative_to(ROOT)}")

    if errors:
        print(json.dumps({"gate": "JL-CORE-LD", "status": "FAIL", "errors": errors}, ensure_ascii=False, indent=2))
        return 1

    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    confession = schema["$defs"]["q2"]["properties"]["confession"]["const"]
    if confession != "예수님과 함께 십자가에 못 박혀 죽었습니다":
        errors.append("q2_confession_mismatch")

    with register_path.open(encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.DictReader(stream))
    ids = {row["canonical_id"] for row in rows}
    expected_ids = {"JL-LD-Q02-CONFESSION"}
    expected_ids.update({f"JL-OLD-{n:02d}" for n in range(1, 8)})
    expected_ids.update({f"JL-FRUIT-{n:02d}" for n in range(1, 10)})
    missing_ids = sorted(expected_ids - ids)
    if missing_ids:
        errors.append("missing_canonical_ids:" + ",".join(missing_ids))

    connection = sqlite3.connect(":memory:")
    try:
        connection.executescript(migration_path.read_text(encoding="utf-8"))
    except sqlite3.Error as exc:
        errors.append(f"sqlite_migration:{exc}")
    finally:
        connection.close()

    with acceptance_path.open(encoding="utf-8-sig", newline="") as stream:
        acceptance_rows = list(csv.DictReader(stream))
    if len(acceptance_rows) < 15:
        errors.append("acceptance_coverage_below_15")

    status = "PASS" if not errors else "FAIL"
    print(json.dumps({
        "gate": "JL-CORE-LD",
        "status": status,
        "canonical_objects": len(rows),
        "acceptance_tests": len(acceptance_rows),
        "sqlite_migration": "PASS" if not any(e.startswith("sqlite_migration") for e in errors) else "FAIL",
        "errors": errors,
    }, ensure_ascii=False, indent=2))
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
