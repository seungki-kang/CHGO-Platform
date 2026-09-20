-- DEV-002 V008 | audit + retention + RLS
BEGIN;
CREATE TABLE church_audit.audit_event(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),tenant_id uuid NOT NULL REFERENCES church_tenant.church(id),actor_id uuid,action text NOT NULL,resource_type text NOT NULL,resource_id text,purpose text,result text NOT NULL,policy_version text,occurred_at timestamptz NOT NULL DEFAULT now(),metadata jsonb NOT NULL DEFAULT '{}'::jsonb);
CREATE TABLE church_audit.entity_change(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),tenant_id uuid NOT NULL REFERENCES church_tenant.church(id),entity_type text NOT NULL,entity_id text NOT NULL,before_hash text,after_hash text,change_set jsonb NOT NULL DEFAULT '{}'::jsonb,occurred_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE church_audit.consent_reference(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),tenant_id uuid NOT NULL REFERENCES church_tenant.church(id),consent_id text NOT NULL,status text NOT NULL,checked_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE church_audit.deletion_request(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),tenant_id uuid NOT NULL REFERENCES church_tenant.church(id),person_id uuid REFERENCES church_identity.person(id),scope_json jsonb NOT NULL,status text NOT NULL,requested_at timestamptz NOT NULL DEFAULT now(),completed_at timestamptz);
CREATE TABLE church_audit.legal_hold(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),tenant_id uuid NOT NULL REFERENCES church_tenant.church(id),resource_type text NOT NULL,resource_id text NOT NULL,reason_code text NOT NULL,active boolean NOT NULL DEFAULT true);

CREATE OR REPLACE FUNCTION church_integration.reject_forbidden_outbox() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE t text:=lower(NEW.payload_json::text);
BEGIN
 IF t ~ '"(life_diary_raw|raw_diary|raw_reflection|prayer_body|care_note|counseling_text)"[[:space:]]*:'
 THEN RAISE EXCEPTION 'DEV-002 COS-C08: protected raw text forbidden in general outbox'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER trg_outbox_guard BEFORE INSERT OR UPDATE OF payload_json ON church_integration.outbox_event
FOR EACH ROW EXECUTE FUNCTION church_integration.reject_forbidden_outbox();

-- RLS is enabled on tenant-owned tables. Application/service authorization remains mandatory.
DO $$
DECLARE r record;
BEGIN
 FOR r IN SELECT n.nspname AS s,c.relname AS t FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
          JOIN pg_attribute a ON a.attrelid=c.oid AND a.attname='tenant_id' AND NOT a.attisdropped
          WHERE c.relkind='r' AND n.nspname LIKE 'church_%' LOOP
  EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY',r.s,r.t);
  EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I.%I',r.s,r.t);
  EXECUTE format('CREATE POLICY tenant_isolation ON %I.%I USING (tenant_id=church_access.current_tenant_id()) WITH CHECK (tenant_id=church_access.current_tenant_id())',r.s,r.t);
 END LOOP;
END $$;

CREATE INDEX ix_outbox_pending ON church_integration.outbox_event(status,next_attempt_at) WHERE status='PENDING';
CREATE INDEX ix_audit_tenant_time ON church_audit.audit_event(tenant_id,occurred_at DESC);
CREATE INDEX ix_community_parent ON church_community.community(tenant_id,parent_id);
CREATE INDEX ix_event_schedule ON church_module.event(tenant_id,starts_at) WHERE status IN ('SCHEDULED','LIVE');
COMMIT;
