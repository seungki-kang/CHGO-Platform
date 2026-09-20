-- DEV-002A PostgreSQL Migration Compatibility Patch 2.0a
-- Document ID: DEV-002A-SQL-COMPAT-2.0a
-- Status: SUPERSEDING REPLACEMENT FOR PATCH 2.0 / PRE-B02 CANDIDATE
-- Target: PostgreSQL 16+
-- Parent: DEV-002 Church OS Schema 1.0 (Candidate)
-- Delta: DEV-002A Church OS Schema Delta 2.0
-- Architecture: L3 Application OS, governed by L4, L2 integration boundary
-- IMPORTANT: additive-first. This file supersedes Patch 2.0 for new execution.
-- It does NOT claim a live DEV-002 database has been executed; physical parent objects are resolved at runtime.
-- DEV-002 legacy namespaces remain authoritative where present; church_os hosts the 2.0 delta objects.
-- Production thresholds such as community suppression remain policy-governed and are NOT hard-coded here.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS church_os;

CREATE SCHEMA IF NOT EXISTS church_os_compat;

CREATE TABLE IF NOT EXISTS church_os_compat.migration_ledger (
  migration_id text PRIMARY KEY, migration_version text NOT NULL,
  status text NOT NULL, checksum_sha256 text, started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz, notes text,
  CHECK (status IN ('STARTED','APPLIED','FAILED','ROLLED_BACK'))
);
INSERT INTO church_os_compat.migration_ledger(migration_id,migration_version,status,notes)
VALUES ('DEV-002A-SQL-COMPAT','2.0a','STARTED',
'Compatibility replacement; DEV-002 namespaces resolved without destructive rewrite.')
ON CONFLICT (migration_id) DO UPDATE SET migration_version=EXCLUDED.migration_version,status='STARTED',
started_at=now(),completed_at=NULL,notes=EXCLUDED.notes;

CREATE OR REPLACE FUNCTION church_os_compat.resolve_relation(candidates text[])
RETURNS regclass LANGUAGE plpgsql STABLE AS $$
DECLARE c text; r regclass;
BEGIN
 FOREACH c IN ARRAY candidates LOOP
   r:=to_regclass(c); IF r IS NOT NULL THEN RETURN r; END IF;
 END LOOP; RETURN NULL;
END $$;

CREATE TABLE IF NOT EXISTS church_os_compat.parent_resolution (
 object_code text PRIMARY KEY, resolved_relation text,
 required_for_b02 boolean NOT NULL DEFAULT true, resolved_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO church_os_compat.parent_resolution(object_code,resolved_relation,required_for_b02) VALUES
('tenant_root',church_os_compat.resolve_relation(ARRAY['church_tenant.church','church_os.church'])::text,true),
('person',church_os_compat.resolve_relation(ARRAY['church_identity.person','church_os.person'])::text,true),
('campus',church_os_compat.resolve_relation(ARRAY['church_tenant.campus','church_os.campus'])::text,false),
('care_request',church_os_compat.resolve_relation(ARRAY['church_module.care_request','church_os.care_request'])::text,false),
('care_assignment',church_os_compat.resolve_relation(ARRAY['church_module.care_assignment','church_os.care_assignment'])::text,false),
('prayer_request',church_os_compat.resolve_relation(ARRAY['church_module.prayer_request','church_os.prayer_request'])::text,false),
('external_app',church_os_compat.resolve_relation(ARRAY['church_integration.external_app','church_os.external_app'])::text,false),
('legacy_outbox',church_os_compat.resolve_relation(ARRAY['church_integration.outbox_event','church_os.outbox_event'])::text,false)
ON CONFLICT (object_code) DO UPDATE SET resolved_relation=EXCLUDED.resolved_relation,
required_for_b02=EXCLUDED.required_for_b02,resolved_at=now();

DO $$
DECLARE missing text;
BEGIN
 SELECT string_agg(object_code,', ') INTO missing FROM church_os_compat.parent_resolution
 WHERE required_for_b02 AND resolved_relation IS NULL;
 IF missing IS NOT NULL THEN
   RAISE EXCEPTION 'DEV-002A 2.0a preflight: required DEV-002 physical parent(s) not found: %. Apply/restore DEV-002 baseline first.',missing;
 END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 0. Helpers / session context
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION church_os.current_tenant_id()
RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.tenant_id', true),'')::uuid
$$;

CREATE OR REPLACE FUNCTION church_os.current_actor_id()
RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.actor_id', true),'')::uuid
$$;

CREATE OR REPLACE FUNCTION church_os.current_purpose()
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.purpose', true),'')
$$;

CREATE OR REPLACE FUNCTION church_os.touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

-- ---------------------------------------------------------------------------
-- 1. Versionable vocabulary registry (preferred over native ENUM)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.vocabulary_value (
  vocabulary_code text NOT NULL,
  value_code text NOT NULL,
  label_key text,
  description text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (vocabulary_code, value_code)
);

INSERT INTO church_os.vocabulary_value(vocabulary_code,value_code,sort_order) VALUES
('gateway_decision','ALLOW',10),('gateway_decision','REDACT',20),('gateway_decision','DENY',30),
('gateway_decision','SUPPRESS',40),('gateway_decision','HANDOFF',50),
('opportunity_state','AVAILABLE',10),('opportunity_state','NO_OPPORTUNITY',20),
('opportunity_state','UNKNOWN',30),('opportunity_state','NOT_APPLICABLE',40),
('formation_progress_state','NOT_STARTED',10),('formation_progress_state','IN_PROGRESS',20),
('formation_progress_state','COMPLETED',30),('formation_progress_state','SKIPPED',40),
('formation_progress_state','WITHDRAWN',50),
('mission_participation_state','INVITED',10),('mission_participation_state','ENROLLED',20),
('mission_participation_state','ACTIVE',30),('mission_participation_state','PAUSED',40),
('mission_participation_state','COMPLETED',50),('mission_participation_state','WITHDRAWN',60),
('delivery_status','PENDING',10),('delivery_status','SENT',20),('delivery_status','FAILED',30),
('delivery_status','DEAD_LETTER',40),
('sensitivity_class','STANDARD',10),('sensitivity_class','SENSITIVE',20),
('sensitivity_class','HIGHLY_SENSITIVE',30)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. People Journey (operational connection journey; NEVER spiritual rank)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.person_journey_state (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  journey_type text NOT NULL,
  state_code text NOT NULL,
  entered_at timestamptz NOT NULL DEFAULT now(),
  exited_at timestamptz,
  source_ref text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (exited_at IS NULL OR exited_at >= entered_at),
  UNIQUE (tenant_id, person_id, journey_type, entered_at)
);
CREATE INDEX IF NOT EXISTS ix_person_journey_state_tenant_person
  ON church_os.person_journey_state(tenant_id,person_id,journey_type,entered_at DESC);

CREATE TABLE IF NOT EXISTS church_os.person_journey_event (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  journey_type text NOT NULL,
  event_type text NOT NULL,
  from_state text,
  to_state text,
  source_type text,
  source_id text,
  occurred_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_person_journey_event_tenant_person_time
  ON church_os.person_journey_event(tenant_id,person_id,occurred_at DESC);

-- ---------------------------------------------------------------------------
-- 3. Care / Prayer privacy additions
-- Existing DEV-002 baseline: care_request, care_assignment, prayer_request,
-- prayer_request_body, prayer_share, care_interaction_meta.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.visibility_policy (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  code text NOT NULL,
  version integer NOT NULL DEFAULT 1,
  scope_code text NOT NULL,
  config_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'ACTIVE',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,code,version)
);

CREATE TABLE IF NOT EXISTS church_os.care_protected_note (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  care_request_id uuid NOT NULL,
  author_person_id uuid,
  vault_pointer text NOT NULL,
  encryption_key_ref text,
  visibility_policy_id uuid,
  sensitivity_class text NOT NULL DEFAULT 'SENSITIVE',
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (sensitivity_class IN ('STANDARD','SENSITIVE','HIGHLY_SENSITIVE'))
);
CREATE INDEX IF NOT EXISTS ix_care_protected_note_request
  ON church_os.care_protected_note(tenant_id,care_request_id,created_at DESC);

CREATE TABLE IF NOT EXISTS church_os.care_handoff_event (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  care_request_id uuid NOT NULL,
  from_assignment_id uuid,
  to_assignment_id uuid,
  reason_code text NOT NULL,
  scope_delta jsonb NOT NULL DEFAULT '{}'::jsonb,
  audit_ref text,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

-- Additive columns only when parent tables exist.
DO $$
BEGIN
  IF to_regclass('church_os.care_request') IS NOT NULL THEN
    EXECUTE 'ALTER TABLE church_os.care_request ADD COLUMN IF NOT EXISTS visibility_policy_id uuid';
    EXECUTE 'ALTER TABLE church_os.care_request ADD COLUMN IF NOT EXISTS sensitivity_class text NOT NULL DEFAULT ''SENSITIVE''';
  END IF;
  IF to_regclass('church_os.prayer_request') IS NOT NULL THEN
    EXECUTE 'ALTER TABLE church_os.prayer_request ADD COLUMN IF NOT EXISTS visibility_policy_id uuid';
    EXECUTE 'ALTER TABLE church_os.prayer_request ADD COLUMN IF NOT EXISTS sensitivity_class text NOT NULL DEFAULT ''SENSITIVE''';
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 4. Formation Pack / Journey
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.formation_pack (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid,
  provider_type text NOT NULL,
  external_ref text,
  code text NOT NULL,
  version text NOT NULL,
  default_locale text,
  status text NOT NULL DEFAULT 'DRAFT',
  config_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,code,version)
);

CREATE TABLE IF NOT EXISTS church_os.formation_journey (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  pack_id uuid REFERENCES church_os.formation_pack(id),
  journey_type text NOT NULL,
  code text NOT NULL,
  title text NOT NULL,
  version text NOT NULL,
  status text NOT NULL DEFAULT 'DRAFT',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,code,version)
);

CREATE TABLE IF NOT EXISTS church_os.formation_unit (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  journey_id uuid NOT NULL REFERENCES church_os.formation_journey(id),
  sequence_no integer NOT NULL,
  unit_type text NOT NULL,
  code text NOT NULL,
  title text NOT NULL,
  prerequisite_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'ACTIVE',
  UNIQUE(journey_id,sequence_no),
  UNIQUE(journey_id,code)
);

CREATE TABLE IF NOT EXISTS church_os.formation_activity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  unit_id uuid NOT NULL REFERENCES church_os.formation_unit(id),
  sequence_no integer NOT NULL,
  activity_type text NOT NULL,
  content_ref text,
  expected_duration_minutes integer,
  config_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  CHECK (expected_duration_minutes IS NULL OR expected_duration_minutes >= 0),
  UNIQUE(unit_id,sequence_no)
);

CREATE TABLE IF NOT EXISTS church_os.formation_enrollment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  journey_id uuid NOT NULL REFERENCES church_os.formation_journey(id),
  status text NOT NULL DEFAULT 'ACTIVE',
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  withdrawn_at timestamptz,
  UNIQUE(tenant_id,person_id,journey_id,started_at),
  CHECK (completed_at IS NULL OR completed_at >= started_at)
);

CREATE TABLE IF NOT EXISTS church_os.formation_activity_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  enrollment_id uuid NOT NULL REFERENCES church_os.formation_enrollment(id),
  activity_id uuid NOT NULL REFERENCES church_os.formation_activity(id),
  progress_state text NOT NULL DEFAULT 'NOT_STARTED',
  occurred_at timestamptz,
  metadata_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE(enrollment_id,activity_id),
  CHECK (progress_state IN ('NOT_STARTED','IN_PROGRESS','COMPLETED','SKIPPED','WITHDRAWN'))
);

CREATE TABLE IF NOT EXISTS church_os.formation_reflection (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  enrollment_id uuid NOT NULL REFERENCES church_os.formation_enrollment(id),
  activity_id uuid REFERENCES church_os.formation_activity(id),
  visibility_policy_id uuid REFERENCES church_os.visibility_policy(id),
  structured_ref jsonb NOT NULL DEFAULT '{}'::jsonb,
  raw_content_vault_pointer text,
  ai_processing_allowed boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS church_os.practice_opportunity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  context_type text NOT NULL,
  context_id text,
  practice_type text NOT NULL,
  opportunity_state text NOT NULL DEFAULT 'UNKNOWN',
  opened_at timestamptz,
  closed_at timestamptz,
  CHECK (opportunity_state IN ('AVAILABLE','NO_OPPORTUNITY','UNKNOWN','NOT_APPLICABLE')),
  CHECK (closed_at IS NULL OR opened_at IS NULL OR closed_at >= opened_at)
);

CREATE TABLE IF NOT EXISTS church_os.practice_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  opportunity_id uuid REFERENCES church_os.practice_opportunity(id),
  practice_type text NOT NULL,
  practice_state text NOT NULL,
  occurred_at timestamptz NOT NULL,
  source_ref text,
  created_at timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE church_os.practice_record IS
'Practice only. MUST NOT be interpreted as Outcome or spiritual maturity.';

-- ---------------------------------------------------------------------------
-- 5. Mission Engine
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.mission_program (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  code text NOT NULL,
  title text NOT NULL,
  duration_days integer,
  objective text,
  status text NOT NULL DEFAULT 'DRAFT',
  config_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,code),
  CHECK (duration_days IS NULL OR duration_days > 0)
);

CREATE TABLE IF NOT EXISTS church_os.mission_run (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  program_id uuid NOT NULL REFERENCES church_os.mission_program(id),
  campus_id uuid,
  target_scope_type text,
  target_scope_id text,
  policy_ref text,
  starts_on date NOT NULL,
  ends_on date,
  status text NOT NULL DEFAULT 'PLANNED',
  CHECK (ends_on IS NULL OR ends_on >= starts_on)
);

CREATE TABLE IF NOT EXISTS church_os.mission_enrollment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  run_id uuid NOT NULL REFERENCES church_os.mission_run(id),
  person_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'ENROLLED',
  joined_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  CHECK (status IN ('INVITED','ENROLLED','ACTIVE','PAUSED','COMPLETED','WITHDRAWN'))
);

CREATE TABLE IF NOT EXISTS church_os.mission_action_definition (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  program_id uuid NOT NULL REFERENCES church_os.mission_program(id),
  sequence_no integer NOT NULL,
  action_type text NOT NULL,
  cadence text,
  config_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE(program_id,sequence_no)
);

CREATE TABLE IF NOT EXISTS church_os.mission_action_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  enrollment_id uuid NOT NULL REFERENCES church_os.mission_enrollment(id),
  action_id uuid NOT NULL REFERENCES church_os.mission_action_definition(id),
  action_state text NOT NULL,
  opportunity_state text NOT NULL DEFAULT 'UNKNOWN',
  occurred_at timestamptz,
  metadata_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  CHECK (opportunity_state IN ('AVAILABLE','NO_OPPORTUNITY','UNKNOWN','NOT_APPLICABLE'))
);

CREATE TABLE IF NOT EXISTS church_os.mission_review (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  run_id uuid NOT NULL REFERENCES church_os.mission_run(id),
  person_id uuid,
  review_type text NOT NULL,
  visibility_policy_id uuid REFERENCES church_os.visibility_policy(id),
  structured_ref jsonb NOT NULL DEFAULT '{}'::jsonb,
  raw_content_vault_pointer text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 6. Today read model (not a source of truth)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.today_action_source (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  source_type text NOT NULL,
  source_id text NOT NULL,
  priority_class text NOT NULL DEFAULT 'NORMAL',
  due_at timestamptz,
  action_route text NOT NULL,
  privacy_class text NOT NULL DEFAULT 'STANDARD',
  model_version text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,person_id,source_type,source_id)
);

CREATE TABLE IF NOT EXISTS church_os.today_action_state (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  source_id uuid NOT NULL REFERENCES church_os.today_action_source(id) ON DELETE CASCADE,
  state text NOT NULL DEFAULT 'OPEN',
  dismissed_at timestamptz,
  completed_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(person_id,source_id)
);

-- ---------------------------------------------------------------------------
-- 7. Privacy Gateway / pseudonymous subject / purpose
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.purpose_registry (
  purpose_code text PRIMARY KEY,
  description text NOT NULL,
  data_profile_code text NOT NULL,
  consent_required boolean NOT NULL DEFAULT true,
  is_active boolean NOT NULL DEFAULT true,
  version integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO church_os.purpose_registry(purpose_code,description,data_profile_code,consent_required)
VALUES
('FORMATION_GROWTH','Formation activity/reflection/practice support','FORMATION_MIN',true),
('GROWTH_COACHING','Participant-authorized growth coaching','REFLECTION_STRUCTURED',true),
('PROGRAM_EVALUATION','Approved program evaluation using minimized data','FORMATION_MIN',true)
ON CONFLICT (purpose_code) DO NOTHING;

CREATE TABLE IF NOT EXISTS church_os.pseudonym_subject_link (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  person_id uuid NOT NULL,
  subject_key_ciphertext bytea NOT NULL,
  subject_key_fingerprint bytea NOT NULL,
  key_version integer NOT NULL,
  status text NOT NULL DEFAULT 'ACTIVE',
  created_at timestamptz NOT NULL DEFAULT now(),
  rotated_at timestamptz,
  revoked_at timestamptz,
  UNIQUE(tenant_id,person_id,key_version),
  UNIQUE(tenant_id,subject_key_fingerprint,key_version)
);

CREATE TABLE IF NOT EXISTS church_os.privacy_gateway_decision (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  actor_id uuid,
  subject_link_id uuid REFERENCES church_os.pseudonym_subject_link(id),
  request_or_event_ref text NOT NULL,
  purpose_code text NOT NULL REFERENCES church_os.purpose_registry(purpose_code),
  consent_ref text,
  policy_version text NOT NULL,
  decision text NOT NULL,
  reason_code text,
  minimized_profile_code text,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  CHECK (decision IN ('ALLOW','REDACT','DENY','SUPPRESS','HANDOFF'))
);

-- ---------------------------------------------------------------------------
-- 8. Integration / outbox delta
-- Parent DEV-002 has external_app, integration_connection, webhook_subscription,
-- domain_event, outbox_event, inbox_event, webhook_delivery, dead_letter.
-- These additive tables formalize client/module/purpose and delivery lineage.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.integration_client (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  external_app_id uuid,
  client_type text NOT NULL,
  client_key text NOT NULL,
  auth_profile_ref text NOT NULL,
  status text NOT NULL DEFAULT 'ACTIVE',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,client_key)
);

CREATE TABLE IF NOT EXISTS church_os.integration_module_grant (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  client_id uuid NOT NULL REFERENCES church_os.integration_client(id) ON DELETE CASCADE,
  module_code text NOT NULL,
  scope_code text NOT NULL,
  purpose_code text REFERENCES church_os.purpose_registry(purpose_code),
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  status text NOT NULL DEFAULT 'ACTIVE',
  CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE TABLE IF NOT EXISTS church_os.integration_event_outbox (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  source_event_id text NOT NULL,
  event_type text NOT NULL,
  schema_version text NOT NULL,
  subject_link_id uuid REFERENCES church_os.pseudonym_subject_link(id),
  purpose_code text REFERENCES church_os.purpose_registry(purpose_code),
  payload_json jsonb NOT NULL,
  payload_hash bytea GENERATED ALWAYS AS (digest(payload_json::text,'sha256')) STORED,
  publish_status text NOT NULL DEFAULT 'PENDING',
  attempts integer NOT NULL DEFAULT 0,
  next_attempt_at timestamptz,
  idempotency_key text NOT NULL,
  correlation_id text NOT NULL,
  policy_version text,
  occurred_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (publish_status IN ('PENDING','SENT','FAILED','DEAD_LETTER')),
  UNIQUE(tenant_id,event_type,idempotency_key)
);
CREATE INDEX IF NOT EXISTS ix_integration_event_outbox_pending
  ON church_os.integration_event_outbox(publish_status,next_attempt_at,created_at)
  WHERE publish_status IN ('PENDING','FAILED');

CREATE TABLE IF NOT EXISTS church_os.integration_delivery_ledger (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  outbox_id uuid NOT NULL REFERENCES church_os.integration_event_outbox(id) ON DELETE CASCADE,
  attempt_no integer NOT NULL,
  delivery_status text NOT NULL,
  correlation_id text NOT NULL,
  response_code integer,
  error_code text,
  attempted_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(outbox_id,attempt_no),
  CHECK (delivery_status IN ('PENDING','SENT','FAILED','DEAD_LETTER'))
);

CREATE TABLE IF NOT EXISTS church_os.chgo_external_reference (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  local_object_type text NOT NULL,
  local_object_id text NOT NULL,
  l2_resource_type text NOT NULL,
  opaque_l2_ref text NOT NULL,
  l2_version text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,local_object_type,local_object_id,l2_resource_type)
);

-- ---------------------------------------------------------------------------
-- 9. White-label / headless delta
-- Parent tables brand_profile/theme_version/navigation_policy/external_app/etc remain.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.tenant_navigation_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  surface_code text NOT NULL,
  item_code text NOT NULL,
  order_no integer NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  config_version integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(tenant_id,surface_code,item_code,config_version)
);

CREATE TABLE IF NOT EXISTS church_os.api_client_audit (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  client_id uuid REFERENCES church_os.integration_client(id),
  actor_id uuid,
  action text NOT NULL,
  resource_type text,
  resource_ref text,
  purpose_code text,
  decision text NOT NULL,
  policy_version text,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 10. Sensitive access audit
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS church_os.sensitive_access_audit (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  actor_id uuid,
  resource_class text NOT NULL,
  resource_ref text NOT NULL,
  action text NOT NULL,
  purpose_code text,
  decision text NOT NULL,
  policy_version text,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 11. Payload guard: prevent common raw/sensitive fields in CHGO outbox.
-- This is defense-in-depth; event JSON Schema allowlists remain authoritative.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION church_os.reject_forbidden_growth_payload()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  txt text := lower(NEW.payload_json::text);
BEGIN
  IF txt ~ '"(display_name|email|phone|prayer_body|care_note|life_diary_raw|raw_diary|raw_reflection)"[[:space:]]*:'
  THEN
    RAISE EXCEPTION 'DEV-002A: forbidden raw/identity field in CHGO integration payload';
  END IF;
  IF NEW.subject_link_id IS NOT NULL AND NEW.purpose_code IS NULL THEN
    RAISE EXCEPTION 'DEV-002A: protected personal event requires purpose_code';
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_reject_forbidden_growth_payload ON church_os.integration_event_outbox;
CREATE TRIGGER trg_reject_forbidden_growth_payload
BEFORE INSERT OR UPDATE OF payload_json,subject_link_id,purpose_code
ON church_os.integration_event_outbox
FOR EACH ROW EXECUTE FUNCTION church_os.reject_forbidden_growth_payload();

-- ---------------------------------------------------------------------------
-- 12. RLS: new tenant-owned tables
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'person_journey_state','person_journey_event','visibility_policy',
    'care_protected_note','care_handoff_event','formation_journey','formation_unit',
    'formation_activity','formation_enrollment','formation_activity_progress',
    'formation_reflection','practice_opportunity','practice_record','mission_program',
    'mission_run','mission_enrollment','mission_action_definition','mission_action_record',
    'mission_review','today_action_source','today_action_state','pseudonym_subject_link',
    'privacy_gateway_decision','integration_client','integration_module_grant',
    'integration_event_outbox','integration_delivery_ledger','chgo_external_reference',
    'tenant_navigation_config','api_client_audit','sensitive_access_audit'
  ]
  LOOP
    EXECUTE format('ALTER TABLE church_os.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON church_os.%I', t);
    EXECUTE format(
      'CREATE POLICY tenant_isolation ON church_os.%I USING (tenant_id = church_os.current_tenant_id()) WITH CHECK (tenant_id = church_os.current_tenant_id())', t
    );
  END LOOP;
END $$;

-- formation_pack may be global (tenant_id NULL) or tenant-owned.
ALTER TABLE church_os.formation_pack ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS formation_pack_read ON church_os.formation_pack;
CREATE POLICY formation_pack_read ON church_os.formation_pack
USING (tenant_id IS NULL OR tenant_id = church_os.current_tenant_id())
WITH CHECK (tenant_id = church_os.current_tenant_id());

-- purpose registry is global read-only catalog at app layer.
ALTER TABLE church_os.purpose_registry ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS purpose_registry_read ON church_os.purpose_registry;
CREATE POLICY purpose_registry_read ON church_os.purpose_registry FOR SELECT USING (is_active);

-- ---------------------------------------------------------------------------
-- 13. Restricted pseudonym access roles
-- ---------------------------------------------------------------------------
DO $$
BEGIN
 BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='church_os_app') THEN CREATE ROLE church_os_app NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='church_os_privacy_gateway') THEN CREATE ROLE church_os_privacy_gateway NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='church_os_pastor_read') THEN CREATE ROLE church_os_pastor_read NOLOGIN; END IF;
 EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'DEV-002A 2.0a: CREATE ROLE skipped; provision equivalent roles via DB admin/IAM.';
 END;
END $$;
DO $$
BEGIN
 REVOKE ALL ON church_os.pseudonym_subject_link FROM PUBLIC;
 IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='church_os_app') THEN
  EXECUTE 'REVOKE ALL ON church_os.pseudonym_subject_link FROM church_os_app';
  EXECUTE 'GRANT SELECT ON church_os.purpose_registry TO church_os_app';
 END IF;
 IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='church_os_pastor_read') THEN
  EXECUTE 'REVOKE ALL ON church_os.pseudonym_subject_link FROM church_os_pastor_read';
 END IF;
 IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='church_os_privacy_gateway') THEN
  EXECUTE 'GRANT SELECT,INSERT,UPDATE ON church_os.pseudonym_subject_link TO church_os_privacy_gateway';
  EXECUTE 'GRANT SELECT ON church_os.purpose_registry TO church_os_privacy_gateway';
 END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 14. Pastor-safe operational views
-- These views intentionally expose operational aggregates only.
-- They are created only when parent tables exist.
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF to_regclass('church_os.church_membership') IS NOT NULL THEN
    EXECUTE $v$
      CREATE OR REPLACE VIEW church_os.vw_pastor_people_journey AS
      SELECT tenant_id, journey_type, state_code, count(*) AS people_count
      FROM church_os.person_journey_state
      WHERE exited_at IS NULL
      GROUP BY tenant_id, journey_type, state_code
    $v$;
  END IF;

  EXECUTE $v$
    CREATE OR REPLACE VIEW church_os.vw_pastor_formation_overview AS
    SELECT tenant_id, journey_id, status, count(*) AS enrollment_count
    FROM church_os.formation_enrollment
    GROUP BY tenant_id, journey_id, status
  $v$;

  EXECUTE $v$
    CREATE OR REPLACE VIEW church_os.vw_pastor_mission_overview AS
    SELECT tenant_id, run_id, status, count(*) AS participant_count
    FROM church_os.mission_enrollment
    GROUP BY tenant_id, run_id, status
  $v$;
END $$;

-- CHGO protected aggregate is deliberately a cache/import table with NO personal keys.
CREATE TABLE IF NOT EXISTS church_os.pastor_chgo_aggregate_cache (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  metric_code text NOT NULL,
  cohort_definition jsonb NOT NULL DEFAULT '{}'::jsonb,
  window_start date NOT NULL,
  window_end date NOT NULL,
  coverage_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  suppression_state text NOT NULL,
  aggregate_value jsonb,
  provenance_json jsonb NOT NULL,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (window_end >= window_start)
);
ALTER TABLE church_os.pastor_chgo_aggregate_cache ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation ON church_os.pastor_chgo_aggregate_cache;
CREATE POLICY tenant_isolation ON church_os.pastor_chgo_aggregate_cache
USING (tenant_id = church_os.current_tenant_id())
WITH CHECK (tenant_id = church_os.current_tenant_id());

CREATE OR REPLACE VIEW church_os.vw_pastor_chgo_growth AS
SELECT tenant_id, metric_code, cohort_definition, window_start, window_end,
       coverage_json, suppression_state, aggregate_value, provenance_json
FROM church_os.pastor_chgo_aggregate_cache
WHERE expires_at > now();

-- ---------------------------------------------------------------------------
-- 15. No-spiritual-score schema lint function
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION church_os.assert_no_spiritual_score_columns()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE bad text;
BEGIN
  SELECT string_agg(table_name||'.'||column_name, ', ')
    INTO bad
  FROM information_schema.columns
  WHERE table_schema='church_os'
    AND lower(column_name) IN (
      'spiritual_score','spiritual_rank','spiritual_level',
      'faith_score','faith_rank','maturity_score','maturity_level'
    );
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION 'DEV-002A invariant violation: forbidden spiritual score/rank columns: %', bad;
  END IF;
END $$;

SELECT church_os.assert_no_spiritual_score_columns();

-- ---------------------------------------------------------------------------
-- 16. Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS ix_formation_enrollment_tenant_person
  ON church_os.formation_enrollment(tenant_id,person_id,status);
CREATE INDEX IF NOT EXISTS ix_practice_opportunity_tenant_person
  ON church_os.practice_opportunity(tenant_id,person_id,practice_type,opened_at DESC);
CREATE INDEX IF NOT EXISTS ix_practice_record_tenant_person
  ON church_os.practice_record(tenant_id,person_id,occurred_at DESC);
CREATE INDEX IF NOT EXISTS ix_mission_enrollment_tenant_person
  ON church_os.mission_enrollment(tenant_id,person_id,status);
CREATE INDEX IF NOT EXISTS ix_today_action_due
  ON church_os.today_action_source(tenant_id,person_id,due_at)
  WHERE due_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_gateway_decision_trace
  ON church_os.privacy_gateway_decision(tenant_id,request_or_event_ref,occurred_at DESC);
CREATE INDEX IF NOT EXISTS ix_chgo_external_ref
  ON church_os.chgo_external_reference(tenant_id,l2_resource_type,opaque_l2_ref);

-- ---------------------------------------------------------------------------
-- 17. Developer verification comments
-- D2-T01 no spiritual score columns: SELECT church_os.assert_no_spiritual_score_columns();
-- D2-T02 completion does not update maturity: no maturity column/trigger exists.
-- D2-T03 practice != outcome: no outcome auto-create trigger exists.
-- D2-T04 NO_OPPORTUNITY is typed state, not failure.
-- D2-T05 missing remains NULL/UNKNOWN, no numeric zero defaults.
-- D2-T06 pseudonym mapping revoked from app/pastor role.
-- D2-T07 outbox unique idempotency key.
-- D2-T08 outbox decouples L2 delivery from Church transaction.
-- D2-T09 protected note is separate from pastor overview.
-- D2-T10 pastor CHGO cache has no person_id/subject_key/raw_text columns.
-- D2-T11 cross-tenant blocked by RLS + server auth.
-- D2-T12 consent revocation enforcement requires Privacy Gateway service policy.
-- D2-T13 Candidate/Evidence are not reimplemented as one Church OS status.
-- D2-T14 Today tables are read-model refs.
-- D2-T15 raw text forbidden in general integration payload/audit by policy/guard.
-- D2-T16 deploy via versioned migration runner with rollback backup.


-- ---------------------------------------------------------------------------
-- 17. DEV-002 physical compatibility bindings
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION church_os_compat.add_resolved_fk(
 child_table regclass, child_column text, parent_candidates text[],
 parent_column text, constraint_name text, on_delete_sql text DEFAULT 'NO ACTION'
) RETURNS void LANGUAGE plpgsql AS $$
DECLARE p regclass; exists_fk boolean;
BEGIN
 p:=church_os_compat.resolve_relation(parent_candidates);
 IF p IS NULL THEN RAISE NOTICE 'Compatibility FK % skipped: no parent among %',constraint_name,parent_candidates; RETURN; END IF;
 SELECT EXISTS(SELECT 1 FROM pg_constraint WHERE conrelid=child_table AND conname=constraint_name) INTO exists_fk;
 IF NOT exists_fk THEN
  EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %s(%I) ON DELETE %s',
                 child_table,constraint_name,child_column,p,parent_column,on_delete_sql);
 END IF;
END $$;

SELECT church_os_compat.add_resolved_fk('church_os.person_journey_state','tenant_id',ARRAY['church_tenant.church','church_os.church'],'id','fk_pjs_tenant','CASCADE');
SELECT church_os_compat.add_resolved_fk('church_os.person_journey_state','person_id',ARRAY['church_identity.person','church_os.person'],'id','fk_pjs_person','RESTRICT');
SELECT church_os_compat.add_resolved_fk('church_os.person_journey_event','tenant_id',ARRAY['church_tenant.church','church_os.church'],'id','fk_pje_tenant','CASCADE');
SELECT church_os_compat.add_resolved_fk('church_os.person_journey_event','person_id',ARRAY['church_identity.person','church_os.person'],'id','fk_pje_person','RESTRICT');

DO $$
DECLARE t text;
BEGIN
 FOREACH t IN ARRAY ARRAY[
 'visibility_policy','care_protected_note','care_handoff_event','formation_journey','formation_unit',
 'formation_activity','formation_enrollment','formation_activity_progress','formation_reflection',
 'practice_opportunity','practice_record','mission_program','mission_run','mission_enrollment',
 'mission_action_definition','mission_action_record','mission_review','today_action_source','today_action_state',
 'pseudonym_subject_link','privacy_gateway_decision','integration_client','integration_module_grant',
 'integration_event_outbox','integration_delivery_ledger','chgo_external_reference','tenant_navigation_config',
 'api_client_audit','sensitive_access_audit','pastor_chgo_aggregate_cache'] LOOP
  PERFORM church_os_compat.add_resolved_fk(format('church_os.%I',t)::regclass,'tenant_id',
  ARRAY['church_tenant.church','church_os.church'],'id','fk_'||left(t,38)||'_tenant','RESTRICT');
 END LOOP;
END $$;

DO $$
DECLARE t text;
BEGIN
 FOREACH t IN ARRAY ARRAY['formation_enrollment','practice_opportunity','practice_record',
 'mission_enrollment','mission_review','today_action_source','today_action_state','pseudonym_subject_link'] LOOP
  PERFORM church_os_compat.add_resolved_fk(format('church_os.%I',t)::regclass,'person_id',
  ARRAY['church_identity.person','church_os.person'],'id','fk_'||left(t,38)||'_person','RESTRICT');
 END LOOP;
END $$;

SELECT church_os_compat.add_resolved_fk('church_os.care_protected_note','care_request_id',
ARRAY['church_module.care_request','church_os.care_request'],'id','fk_care_note_request','CASCADE');
SELECT church_os_compat.add_resolved_fk('church_os.care_protected_note','author_person_id',
ARRAY['church_identity.person','church_os.person'],'id','fk_care_note_author','RESTRICT');
ALTER TABLE church_os.care_protected_note DROP CONSTRAINT IF EXISTS fk_care_note_visibility;
ALTER TABLE church_os.care_protected_note ADD CONSTRAINT fk_care_note_visibility
FOREIGN KEY (visibility_policy_id) REFERENCES church_os.visibility_policy(id) ON DELETE RESTRICT;
SELECT church_os_compat.add_resolved_fk('church_os.care_handoff_event','care_request_id',
ARRAY['church_module.care_request','church_os.care_request'],'id','fk_care_handoff_request','CASCADE');
SELECT church_os_compat.add_resolved_fk('church_os.care_handoff_event','from_assignment_id',
ARRAY['church_module.care_assignment','church_os.care_assignment'],'id','fk_care_handoff_from','SET NULL');
SELECT church_os_compat.add_resolved_fk('church_os.care_handoff_event','to_assignment_id',
ARRAY['church_module.care_assignment','church_os.care_assignment'],'id','fk_care_handoff_to','SET NULL');
SELECT church_os_compat.add_resolved_fk('church_os.mission_run','campus_id',
ARRAY['church_tenant.campus','church_os.campus'],'id','fk_mission_run_campus','SET NULL');

DO $$
DECLARE r regclass;
BEGIN
 r:=church_os_compat.resolve_relation(ARRAY['church_module.care_request','church_os.care_request']);
 IF r IS NOT NULL THEN
  EXECUTE format('ALTER TABLE %s ADD COLUMN IF NOT EXISTS visibility_policy_id uuid',r);
  EXECUTE format('ALTER TABLE %s ADD COLUMN IF NOT EXISTS sensitivity_class text NOT NULL DEFAULT ''SENSITIVE''',r);
 END IF;
 r:=church_os_compat.resolve_relation(ARRAY['church_module.prayer_request','church_os.prayer_request']);
 IF r IS NOT NULL THEN
  EXECUTE format('ALTER TABLE %s ADD COLUMN IF NOT EXISTS visibility_policy_id uuid',r);
  EXECUTE format('ALTER TABLE %s ADD COLUMN IF NOT EXISTS sensitivity_class text NOT NULL DEFAULT ''SENSITIVE''',r);
 END IF;
END $$;

-- Event lineage: legacy outbox_event remains GENERAL Church OS integration SoR.
-- integration_event_outbox is authoritative ONLY for privacy-gated CHGO L2 bridge events.
COMMENT ON TABLE church_os.integration_event_outbox IS
'CHGO L2 privacy-gated bridge outbox only. Does not replace DEV-002 general outbox_event.';
COMMENT ON TABLE church_os.integration_delivery_ledger IS
'Delivery attempts for CHGO bridge integration_event_outbox only.';

-- Production cohort suppression threshold intentionally remains policy-governed and unseeded.
CREATE OR REPLACE VIEW church_os.vw_pastor_people_journey AS
SELECT tenant_id,journey_type,state_code,count(*) AS people_count
FROM church_os.person_journey_state WHERE exited_at IS NULL
GROUP BY tenant_id,journey_type,state_code;

CREATE OR REPLACE FUNCTION church_os_compat.assert_b01_ready()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE missing text; bad integer;
BEGIN
 SELECT string_agg(object_code,', ') INTO missing FROM church_os_compat.parent_resolution
 WHERE required_for_b02 AND resolved_relation IS NULL;
 IF missing IS NOT NULL THEN RAISE EXCEPTION 'B-01 not ready: missing physical parents: %',missing; END IF;
 SELECT count(*) INTO bad FROM information_schema.columns WHERE table_schema='church_os'
 AND lower(column_name) IN ('spiritual_score','spiritual_rank','spiritual_level','faith_score','faith_rank','maturity_score','maturity_level');
 IF bad>0 THEN RAISE EXCEPTION 'B-01 not ready: forbidden spiritual score/rank columns found'; END IF;
 IF to_regclass('church_os.integration_event_outbox') IS NULL OR to_regclass('church_os.pseudonym_subject_link') IS NULL
 OR to_regclass('church_os.pastor_chgo_aggregate_cache') IS NULL THEN
  RAISE EXCEPTION 'B-01 not ready: required delta tables missing';
 END IF;
END $$;
SELECT church_os_compat.assert_b01_ready();

UPDATE church_os_compat.migration_ledger SET status='APPLIED',completed_at=now(),
notes='2.0a applied; B-02 still requires clean PostgreSQL execution and PHY-T01~T12 evidence.'
WHERE migration_id='DEV-002A-SQL-COMPAT';

COMMIT;
