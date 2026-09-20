#!/usr/bin/env python3
"""Validate the CHGO repository structure-freeze candidate using only stdlib."""
from __future__ import annotations

import csv
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MANIFEST = ROOT / "REPOSITORY_MANIFEST_CANDIDATE_1.7.csv"
ALLOWED = {
    "api", "apps", "backlog", "canonical", "changes", "compatibility", "db",
    "docs", "evidence", "feature-flags", "infrastructure", "localization",
    "ontology", "packages", "registry", "releases", "scripts", "services",
    "tests", "tools",
}
REQUIRED = {
    "README.md", "START_HERE.md", "STRUCTURE_GUIDE.md", "canonical",
    "docs/governance", "registry", "evidence/pre-release", "releases/manifests",
}


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    errors: list[str] = []
    extra = sorted(p.name for p in ROOT.iterdir() if p.is_dir() and p.name not in ALLOWED)
    if extra:
        errors.append("unexpected top-level directories: " + ", ".join(extra))
    missing = sorted(item for item in REQUIRED if not (ROOT / item).exists())
    if missing:
        errors.append("missing required paths: " + ", ".join(missing))
    for path in ROOT.rglob("*"):
        rel = path.relative_to(ROOT).as_posix()
        if path.is_file() and (path.suffix.lower() in {".zip", ".pyc", ".pyo"} or "__pycache__" in path.parts):
            errors.append("forbidden generated/archive file: " + rel)
        if path.is_dir() and path != ROOT and (path / ".git").exists():
            errors.append("nested repository: " + rel)
    with MANIFEST.open(encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.DictReader(stream))
    for row in rows:
        path = ROOT / row["path"]
        if not path.is_file():
            errors.append("manifest path missing: " + row["path"])
        elif digest(path) != row["sha256"]:
            errors.append("manifest hash mismatch: " + row["path"])
    result = {"result": "PASS" if not errors else "FAIL", "manifest_entries": len(rows), "errors": errors}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
