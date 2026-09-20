-- DEV-002 V004 | access + role
BEGIN;
CREATE TABLE church_access.role(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 code text NOT NULL, name text NOT NULL, scope_type text NOT NULL, is_system boolean NOT NULL DEFAULT false,
 UNIQUE(tenant_id,code));
CREATE TABLE church_access.permission(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), code text NOT NULL UNIQUE, resource_type text NOT NULL,
 action text NOT NULL, sensitivity_max text NOT NULL DEFAULT 'STANDARD');
CREATE TABLE church_access.role_permission(
 role_id uuid NOT NULL REFERENCES church_access.role(id) ON DELETE CASCADE,
 permission_id uuid NOT NULL REFERENCES church_access.permission(id) ON DELETE CASCADE,
 condition_json jsonb NOT NULL DEFAULT '{}'::jsonb, PRIMARY KEY(role_id,permission_id));
CREATE TABLE church_access.role_assignment(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 account_id uuid REFERENCES church_identity.account(id) ON DELETE RESTRICT, person_id uuid REFERENCES church_identity.person(id) ON DELETE RESTRICT,
 role_id uuid NOT NULL REFERENCES church_access.role(id) ON DELETE RESTRICT, scope_id uuid,
 valid_from timestamptz NOT NULL DEFAULT now(), valid_to timestamptz,
 CHECK(account_id IS NOT NULL OR person_id IS NOT NULL), CHECK(valid_to IS NULL OR valid_to>valid_from));
CREATE TABLE church_access.delegation(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), grantor_assignment_id uuid NOT NULL REFERENCES church_access.role_assignment(id) ON DELETE RESTRICT,
 grantee_id uuid NOT NULL, permission_subset jsonb NOT NULL DEFAULT '[]'::jsonb, expires_at timestamptz NOT NULL);
CREATE TABLE church_access.consent_ref(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 person_id uuid NOT NULL REFERENCES church_identity.person(id) ON DELETE RESTRICT, purpose_code text NOT NULL,
 consent_id text NOT NULL, status text NOT NULL, checked_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE church_access.access_decision_log(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 actor_id uuid, resource_type text NOT NULL, resource_id text, action text NOT NULL, purpose text,
 policy_version text, result text NOT NULL, occurred_at timestamptz NOT NULL DEFAULT now());
COMMIT;
