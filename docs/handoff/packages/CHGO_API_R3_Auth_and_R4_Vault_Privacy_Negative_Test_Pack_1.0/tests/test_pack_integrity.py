import csv
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def test_matrix_has_18_cases():
    rows=list(csv.DictReader((ROOT/"fixtures"/"R3_R4_negative_test_matrix.csv").open(encoding="utf-8-sig")))
    assert len(rows)==18
    assert all(r["expected"] and r["severity"] for r in rows)
def test_env_template_has_no_secrets():
    txt=(ROOT/"fixtures"/".env.example").read_text()
    assert "Bearer " not in txt
    for line in txt.splitlines():
        if line.startswith("CHGO_TOKEN_"): assert line.endswith("=")
def test_runtime_tests_fail_closed_without_target():
    txt=(ROOT/"tests"/"test_r3_r4_runtime_negative.py").read_text()
    assert 'skipif(not BASE' in txt
    assert 'status_code in (403,404)' in txt
