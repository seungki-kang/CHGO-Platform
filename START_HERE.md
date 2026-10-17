# Start Here

1. Read `README.md` for what Church OS is and how it relates to the other JesusLife One products.
2. Read `STRUCTURE_GUIDE.md` before adding or moving files.
3. Product: `docs/product/` (requirements 2.0, product and experience architecture 3.0) and `docs/ux/`.
4. Architecture: `docs/architecture/` (white-label and headless integration 3.0, Church OS to CHGO engine integration contract).
5. Database: `db/migrations/church_os/` (V001–V010) and `db/validation/` (V011–V012).
6. Run the static checks after any change:

```bash
pip install PyYAML
python tools/validation/validate_e5_regression.py   # runs B-04 and C-02 too
```

The PostgreSQL runtime check runs in GitHub Actions: workflow `E5 PostgreSQL Runtime and Rollback Evidence` (manual dispatch). See `docs/operations/E5_GitHub_Actions_PostgreSQL_Runtime_Guide_1.0.md`.

Content that belongs to CHGO or Life Diary does not go in this repository. Use `CHGO` or `CHGO-Life-Diary-Flutter`.
