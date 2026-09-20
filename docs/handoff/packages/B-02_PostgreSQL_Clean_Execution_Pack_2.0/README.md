# B-02 PostgreSQL Clean Execution Pack 2.0

Purpose: execute CHGO V001-V012 on a disposable clean PostgreSQL 16+ database and collect evidence for B-02.

Order: preflight -> clean apply V001-V012 -> replay V010 -> inspect PHY/contract results -> dump/drop/recreate/restore -> mark PHY-T12 only after successful recovery -> reviewer decision.

Important: this pack does not claim runtime PASS. Current chat environment has no PostgreSQL 16+ runtime. Run against a disposable developer/staging database only. Never point rollback_restore_fixture.sh at production.
