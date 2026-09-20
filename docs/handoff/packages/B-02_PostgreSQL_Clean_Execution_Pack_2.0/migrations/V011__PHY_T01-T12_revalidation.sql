-- B-02 PHY-T01~T12 Physical Compatibility Re-Validation | PostgreSQL 16+
-- Run AFTER V001~V009 and DEV-002A compatibility patch 2.0a.
\set ON_ERROR_STOP on
BEGIN;
CREATE SCHEMA IF NOT EXISTS b02_test;
CREATE TABLE IF NOT EXISTS b02_test.result(
 test_id text PRIMARY KEY, status text NOT NULL, detail text, checked_at timestamptz NOT NULL DEFAULT now()
);
TRUNCATE b02_test.result;
CREATE OR REPLACE FUNCTION b02_test.put(i text,s text,d text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN INSERT INTO b02_test.result(test_id,status,detail) VALUES(i,s,d)
ON CONFLICT(test_id) DO UPDATE SET status=excluded.status,detail=excluded.detail,checked_at=now(); END $$;

-- PHY-T01 namespace / required parent resolution
DO $$ DECLARE n int; BEGIN
 SELECT count(*) INTO n FROM church_os_compat.parent_resolution WHERE required_for_b02 AND resolved_relation IS NULL;
 PERFORM b02_test.put('PHY-T01',CASE WHEN n=0 THEN 'PASS' ELSE 'FAIL' END,'unresolved required parents='||n);
END $$;

-- PHY-T02 column conflict / forbidden scoring proxy scan
DO $$ DECLARE n int; BEGIN
 SELECT count(*) INTO n FROM information_schema.columns
 WHERE table_schema IN ('church_os','church_identity','church_tenant','church_community','church_access','church_module')
 AND lower(column_name) IN ('spiritual_score','spiritual_rank','spiritual_level','faith_score','faith_rank','maturity_score','maturity_level');
 PERFORM b02_test.put('PHY-T02',CASE WHEN n=0 THEN 'PASS' ELSE 'FAIL' END,'forbidden columns='||n);
END $$;

-- PHY-T03 required FK graph: delta tenant/person bindings exist
DO $$ DECLARE n int; BEGIN
 SELECT count(*) INTO n FROM pg_constraint c JOIN pg_namespace ns ON ns.oid=c.connamespace
 WHERE ns.nspname='church_os' AND c.contype='f' AND (c.conname LIKE '%_tenant' OR c.conname LIKE '%_person');
 PERFORM b02_test.put('PHY-T03',CASE WHEN n>=10 THEN 'PASS' ELSE 'FAIL' END,'tenant/person compatibility FKs='||n);
END $$;

-- PHY-T04 outbox authority is explicitly separated
DO $$ DECLARE a regclass; b regclass; BEGIN
 a:=to_regclass('church_integration.outbox_event'); b:=to_regclass('church_os.integration_event_outbox');
 PERFORM b02_test.put('PHY-T04',CASE WHEN a IS NOT NULL AND b IS NOT NULL THEN 'PASS' ELSE 'FAIL' END,
 'general='||coalesce(a::text,'NULL')||'; chgo_bridge='||coalesce(b::text,'NULL'));
END $$;

-- PHY-T05 RLS enabled on tenant-owned delta tables. Cross-tenant runtime is separately exercised by E2E.
DO $$ DECLARE n int; BEGIN
 SELECT count(*) INTO n FROM pg_class c JOIN pg_namespace nsp ON nsp.oid=c.relnamespace
 WHERE nsp.nspname='church_os' AND c.relrowsecurity AND c.relkind='r';
 PERFORM b02_test.put('PHY-T05',CASE WHEN n>=25 THEN 'PASS' ELSE 'FAIL' END,'RLS-enabled church_os tables='||n||'; cross-tenant runtime requires role fixture');
END $$;

-- PHY-T06 pseudonym grants: pastor/app must not have SELECT, privacy gateway may.
DO $$ DECLARE bad int; BEGIN
 SELECT count(*) INTO bad FROM information_schema.role_table_grants
 WHERE table_schema='church_os' AND table_name='pseudonym_subject_link' AND privilege_type='SELECT'
 AND grantee IN ('church_os_app','church_os_pastor_read');
 PERFORM b02_test.put('PHY-T06',CASE WHEN bad=0 THEN 'PASS' ELSE 'FAIL' END,'forbidden SELECT grants='||bad);
END $$;

-- PHY-T07 raw guard exists on CHGO bridge
DO $$ DECLARE n int; BEGIN
 SELECT count(*) INTO n FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace ns ON ns.oid=c.relnamespace
 WHERE ns.nspname='church_os' AND c.relname='integration_event_outbox'
 AND t.tgname='trg_reject_forbidden_growth_payload' AND NOT t.tgisinternal;
 PERFORM b02_test.put('PHY-T07',CASE WHEN n=1 THEN 'PASS' ELSE 'FAIL' END,'raw/identity guard triggers='||n);
END $$;

-- PHY-T08 legacy compatibility objects retained
DO $$ DECLARE n int:=0; BEGIN
 IF to_regclass('church_community.v_active_membership') IS NOT NULL THEN n:=n+1; END IF;
 IF to_regclass('church_integration.v_outbox_pending') IS NOT NULL THEN n:=n+1; END IF;
 PERFORM b02_test.put('PHY-T08',CASE WHEN n=2 THEN 'PASS' ELSE 'FAIL' END,'legacy compatibility views='||n||'/2');
END $$;

-- PHY-T09 no production suppression numeric seed in delta
DO $$ DECLARE n int; BEGIN
 SELECT count(*) INTO n FROM church_os.vocabulary_value
 WHERE vocabulary_code ILIKE '%suppress%' AND value_code ~ '^[0-9]+$';
 PERFORM b02_test.put('PHY-T09',CASE WHEN n=0 THEN 'PASS' ELSE 'FAIL' END,'numeric suppression seeds='||n);
END $$;

-- PHY-T10 migration apply evidence: ledger APPLIED + readiness assertion
DO $$ DECLARE s text; BEGIN
 PERFORM church_os_compat.assert_b01_ready();
 SELECT status INTO s FROM church_os_compat.migration_ledger WHERE migration_id='DEV-002A-SQL-COMPAT';
 PERFORM b02_test.put('PHY-T10',CASE WHEN s='APPLIED' THEN 'PASS' ELSE 'FAIL' END,'ledger status='||coalesce(s,'NULL'));
EXCEPTION WHEN OTHERS THEN PERFORM b02_test.put('PHY-T10','FAIL',SQLERRM); END $$;

-- PHY-T11 replay safety cannot be proven from a single apply. Runner performs a second patch execution.
-- A marker is recorded here; run_b02.sh upgrades this evidence only if the replay command exits 0.
SELECT b02_test.put('PHY-T11','PENDING','Requires second execution of V010 by runner; see execution log.');

-- PHY-T12 rollback/recovery requires isolated transaction/restore exercise.
SELECT b02_test.put('PHY-T12','PENDING','Requires rollback/recovery fixture; see runbook and execution log.');

TABLE b02_test.result ORDER BY test_id;
COMMIT;
