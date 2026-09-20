-- DEV-002 V009 | seed + views + validation fixtures
BEGIN;
INSERT INTO church_module.module_catalog(code) VALUES
('PEOPLE'),('GROUPS'),('WORSHIP'),('CARE'),('PRAYER'),('LEARN'),('SERVE'),('EVENTS'),
('GIVING'),('COMMUNICATION'),('CONTENT'),('AI_ASSISTANT') ON CONFLICT DO NOTHING;

INSERT INTO church_access.role(tenant_id,code,name,scope_type,is_system) VALUES
(NULL,'TENANT_ADMIN','Tenant Admin','TENANT',true),(NULL,'PASTOR','Pastor','TENANT',true),
(NULL,'STAFF','Staff','TENANT',true),(NULL,'GROUP_LEADER','Group Leader','COMMUNITY',true),
(NULL,'MEMBER','Member','SELF',true),(NULL,'GUEST','Guest','SELF',true)
ON CONFLICT DO NOTHING;

CREATE OR REPLACE VIEW church_community.v_active_membership AS
SELECT id,tenant_id,person_id,member_no,status,joined_on
FROM church_community.church_membership WHERE status='ACTIVE' AND deleted_at IS NULL;

CREATE OR REPLACE VIEW church_integration.v_outbox_pending AS
SELECT event_id,tenant_id,destination,payload_json,payload_hash,attempts,next_attempt_at
FROM church_integration.outbox_event WHERE status='PENDING';

-- IMPORTANT governance correction:
-- DEV-002 1.0 listed suppression threshold 10 as an initial seed.
-- Later DEV-002A governance keeps the production numeric threshold OPEN.
-- Therefore this executable baseline does NOT seed a production threshold.
-- n=9 is used only by COS-T11 as a legacy validation fixture expectation until L4 policy is approved.

CREATE OR REPLACE FUNCTION church_audit.assert_dev002_baseline() RETURNS void LANGUAGE plpgsql AS $$
DECLARE missing text; bad int;
BEGIN
 SELECT string_agg(x,', ') INTO missing FROM unnest(ARRAY[
 'church_tenant.church','church_identity.person','church_community.church_membership',
 'church_community.community','church_access.role','church_module.module_catalog',
 'church_integration.outbox_event','church_audit.audit_event']) x WHERE to_regclass(x) IS NULL;
 IF missing IS NOT NULL THEN RAISE EXCEPTION 'DEV-002 baseline missing: %',missing; END IF;
 SELECT count(*) INTO bad FROM information_schema.columns
 WHERE table_schema LIKE 'church_%' AND lower(column_name) IN
 ('spiritual_score','spiritual_rank','spiritual_level','faith_score','faith_rank','maturity_score','maturity_level');
 IF bad>0 THEN RAISE EXCEPTION 'DEV-002 forbidden spiritual scoring columns found'; END IF;
END $$;
SELECT church_audit.assert_dev002_baseline();
COMMIT;
