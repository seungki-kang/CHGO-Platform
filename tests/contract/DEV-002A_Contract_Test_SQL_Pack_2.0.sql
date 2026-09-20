-- DEV-002A Contract Test SQL Pack 2.0
-- Document ID: DEV-002A-TEST-SQL-02
-- Target: PostgreSQL 16+
-- Basis: DEV-002A Church OS Schema Delta 2.0 (D2-T01~D2-T16)
-- Companion: Church OS OpenAPI Delta 2.0 / Integration Contract IC-T01~IC-T16
-- Save: Developer Handoff/05.Test Automation
--
-- RUN MODE:
--   psql -v ON_ERROR_STOP=1 -f DEV-002A_Contract_Test_SQL_Pack_2.0.sql
--
-- IMPORTANT:
-- * This pack validates schema/DB invariants that can be proven at PostgreSQL level.
-- * Service/API behaviors (coach dual gate, HTTP status, L2 outage, safety HANDOFF,
--   derived-result reproducibility) are marked API/E2E and must be executed by the
--   companion API acceptance suite.
-- * Production cohort suppression threshold remains policy-governed and is NOT hard-coded.

\set ON_ERROR_STOP on

BEGIN;

CREATE SCHEMA IF NOT EXISTS church_os_test;

CREATE TABLE IF NOT EXISTS church_os_test.test_result (
  run_id uuid NOT NULL,
  test_id text NOT NULL,
  status text NOT NULL CHECK (status IN ('PASS','FAIL','MANUAL')),
  detail text,
  executed_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION church_os_test.assert_true(
  p_run uuid, p_test text, p_condition boolean, p_detail text
) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF COALESCE(p_condition,false) THEN
    INSERT INTO church_os_test.test_result VALUES(p_run,p_test,'PASS',p_detail,now());
  ELSE
    INSERT INTO church_os_test.test_result VALUES(p_run,p_test,'FAIL',p_detail,now());
    RAISE EXCEPTION '% FAILED: %', p_test, p_detail;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION church_os_test.manual(
  p_run uuid, p_test text, p_detail text
) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO church_os_test.test_result VALUES(p_run,p_test,'MANUAL',p_detail,now());
END $$;

CREATE OR REPLACE FUNCTION church_os_test.has_column_like(p_table text, p_patterns text[])
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns c
    WHERE c.table_schema='church_os'
      AND c.table_name=p_table
      AND EXISTS (SELECT 1 FROM unnest(p_patterns) p WHERE lower(c.column_name) LIKE p)
  )
$$;

CREATE OR REPLACE FUNCTION church_os_test.table_exists(p_table text)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT to_regclass('church_os.'||p_table) IS NOT NULL
$$;

DO $tests$
DECLARE
  r uuid := gen_random_uuid();
  bad_count integer;
  has_select boolean;
BEGIN
  RAISE NOTICE 'DEV-002A Contract Test Run: %', r;

  -- D2-T01: no spiritual score/rank/level fields.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os'
    AND (
      lower(column_name) ~ '(spiritual|faith|holy_spirit).*(score|rank|level)'
      OR lower(column_name) ~ 'maturity_(score|rank|level)'
    );
  PERFORM church_os_test.assert_true(r,'D2-T01',bad_count=0,
    'No spiritual_score/rank/level or maturity score/rank/level columns.');

  -- D2-T02: formation completion cannot update maturity because no maturity target exists.
  PERFORM church_os_test.assert_true(r,'D2-T02',
    NOT church_os_test.has_column_like('formation_enrollment',ARRAY['%maturity%','%spiritual_score%','%spiritual_rank%']),
    'Formation enrollment contains no maturity/spiritual scoring target.');

  -- D2-T03: practice record does not own outcome-improvement field.
  PERFORM church_os_test.assert_true(r,'D2-T03',
    church_os_test.table_exists('practice_record')
    AND NOT church_os_test.has_column_like('practice_record',ARRAY['%outcome%','%improved%']),
    'Practice persistence is structurally separate from outcome inference.');

  -- D2-T04: NO_OPPORTUNITY is an explicit state, not failure.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os'
    AND table_name IN ('practice_opportunity','mission_action_record')
    AND lower(column_name) IN ('failure','failed','failure_count','score_delta');
  PERFORM church_os_test.assert_true(r,'D2-T04',
    church_os_test.has_column_like('practice_opportunity',ARRAY['opportunity_state'])
    AND bad_count=0,
    'Opportunity state is explicit and not stored as failure/score decrement.');

  -- D2-T05: missing observation is not forced to numeric 0.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os'
    AND column_default IN ('0','0.0','0::integer','0::numeric')
    AND lower(column_name) ~ '(observation|outcome|growth|signal|evidence|score|value)';
  PERFORM church_os_test.assert_true(r,'D2-T05',bad_count=0,
    'No growth/observation-like field defaults missing values to numeric zero.');

  -- D2-T06: pseudonym link not granted to ordinary app/pastor roles.
  SELECT EXISTS (
    SELECT 1 FROM information_schema.role_table_grants
    WHERE table_schema='church_os' AND table_name='pseudonym_subject_link'
      AND grantee IN ('church_os_app','church_os_pastor_read')
      AND privilege_type='SELECT'
  ) INTO has_select;
  PERFORM church_os_test.assert_true(r,'D2-T06',NOT has_select,
    'pseudonym_subject_link SELECT is denied to app/pastor read roles.');

  -- D2-T07: outbox logical event has unique idempotency constraint/index.
  SELECT count(*) INTO bad_count
  FROM pg_indexes
  WHERE schemaname='church_os' AND tablename='integration_event_outbox'
    AND indexdef ILIKE '%UNIQUE%'
    AND indexdef ILIKE '%idempotency_key%';
  PERFORM church_os_test.assert_true(r,'D2-T07',bad_count>0,
    'Outbox has unique idempotency key protection.');

  -- D2-T08: delivery is decoupled from Church operational transaction.
  PERFORM church_os_test.assert_true(r,'D2-T08',
    church_os_test.table_exists('integration_event_outbox')
    AND church_os_test.table_exists('integration_delivery_ledger'),
    'Transactional outbox and delivery ledger exist as separate persistence.');

  -- D2-T09: protected care note must not be exposed by pastor views.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os'
    AND table_name LIKE 'vw_pastor%'
    AND lower(column_name) IN ('vault_pointer','protected_content','raw_text','care_note','prayer_body');
  PERFORM church_os_test.assert_true(r,'D2-T09',bad_count=0,
    'Pastor views expose no protected care/prayer/raw-content columns.');

  -- D2-T10: pastor CHGO aggregate has no personal reverse keys/raw text.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os' AND table_name IN ('pastor_chgo_aggregate_cache','vw_pastor_chgo_growth')
    AND lower(column_name) IN ('person_id','user_id','subject_key','raw_text','raw_reflection','evidence_id');
  PERFORM church_os_test.assert_true(r,'D2-T10',bad_count=0,
    'Pastor CHGO aggregate/cache has no personal reverse key or raw reflection.');

  -- D2-T11: tenant-owned headless/integration resources use tenant_id and RLS.
  SELECT count(*) INTO bad_count
  FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='church_os'
    AND c.relname IN ('integration_client','integration_module_grant','tenant_navigation_config','api_client_audit')
    AND c.relrowsecurity IS NOT TRUE;
  PERFORM church_os_test.assert_true(r,'D2-T11',bad_count=0,
    'Headless/integration tenant tables have RLS enabled; cross-tenant authorization also requires service tests.');

  -- D2-T12: consent/policy block before protected outbox enqueue is service-policy responsibility.
  PERFORM church_os_test.manual(r,'D2-T12',
    'API/E2E required: revoke consent, then assert protected Privacy Gateway decision DENY and no outbox enqueue.');

  -- D2-T13: Church OS does not collapse Candidate/Evidence into one status table/column.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os'
    AND (
      lower(column_name) ~ 'candidate.*evidence|evidence.*candidate'
      OR (lower(table_name) LIKE '%candidate%' AND lower(column_name) LIKE '%evidence%')
    );
  PERFORM church_os_test.assert_true(r,'D2-T13',bad_count=0,
    'No schema field collapses Candidate and Evidence semantics.');

  -- D2-T14: Today is a source-reference/state read model, not duplicate source SoR.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os' AND table_name IN ('today_action_source','today_action_state')
    AND lower(column_name) IN ('raw_text','care_note','prayer_body','reflection_body','content_body');
  PERFORM church_os_test.assert_true(r,'D2-T14',
    church_os_test.table_exists('today_action_source')
    AND church_os_test.table_exists('today_action_state')
    AND bad_count=0,
    'Today stores source refs/state without duplicating protected source bodies.');

  -- D2-T15: general audit tables contain no raw-sensitive body columns.
  SELECT count(*) INTO bad_count
  FROM information_schema.columns
  WHERE table_schema='church_os'
    AND table_name IN ('api_client_audit','sensitive_access_audit','privacy_gateway_decision')
    AND lower(column_name) IN ('raw_text','body','care_note','prayer_body','life_diary_raw','raw_reflection');
  PERFORM church_os_test.assert_true(r,'D2-T15',bad_count=0,
    'General audit/gateway decision tables do not store raw sensitive body columns.');

  -- D2-T16: rollback/replay requires migration-runner validation outside schema.
  PERFORM church_os_test.manual(r,'D2-T16',
    'Migration CI required: backup/transactional apply, rollback or restore, re-apply, then compare schema checksum.');

  -- Integration-contract DB-visible cross-checks
  PERFORM church_os_test.assert_true(r,'IC-T01-DB',
    church_os_test.table_exists('pseudonym_subject_link'),
    'Pseudonymous subject mapping exists; API test must reject real person_id in L2 payload.');

  PERFORM church_os_test.assert_true(r,'IC-T02-DB',
    church_os_test.table_exists('integration_event_outbox'),
    'Outbox exists for idempotent logical ingestion.');

  PERFORM church_os_test.manual(r,'IC-T03/T04',
    'API/E2E required: Coach Dual Gate — consent without assignment and assignment without consent both POLICY_DENIED.');

  PERFORM church_os_test.manual(r,'IC-T05',
    'L2 API test required: UNCERTAIN/REJECTED candidate cannot produce Evidence; expect CONTRACT_BLOCKED/422.');

  PERFORM church_os_test.assert_true(r,'IC-T06/T07/T08-DB',
    church_os_test.table_exists('practice_opportunity') AND church_os_test.table_exists('practice_record'),
    'DB preserves opportunity/practice separation; API fixtures verify unknown/missing semantics.');

  PERFORM church_os_test.manual(r,'IC-T09/T10/T11',
    'API tests required: no pastor personal growth route; aggregate has no personal keys; rare cohort SUPPRESSED/REJECT.');

  PERFORM church_os_test.manual(r,'IC-T12',
    'API/E2E required: consent revoked -> future protected access DENY.');

  PERFORM church_os_test.manual(r,'IC-T13',
    'Failure-injection required: L2 unavailable while attendance/group/care Church OS core transaction succeeds.');

  PERFORM church_os_test.manual(r,'IC-T14',
    'L2 deterministic/reproducibility test: same input + same ontology/model/policy/calculation versions -> reproducibility target.');

  PERFORM church_os_test.manual(r,'IC-T15',
    'Headless API test: client-supplied other tenant_ref is denied server-side.');

  PERFORM church_os_test.manual(r,'IC-T16',
    'Safety E2E test: safety-critical route overrides normal growth flow with HANDOFF.');

  RAISE NOTICE 'Run summary:';
  RAISE NOTICE '%',
    (SELECT jsonb_object_agg(status,cnt)
     FROM (SELECT status,count(*) cnt FROM church_os_test.test_result WHERE run_id=r GROUP BY status) s);
END
$tests$;

-- Human-readable latest results
SELECT test_id,status,detail,executed_at
FROM church_os_test.test_result
WHERE run_id=(SELECT run_id FROM church_os_test.test_result ORDER BY executed_at DESC LIMIT 1)
ORDER BY test_id;

ROLLBACK;
