-- DEV-002 V002 | identity + tenant
BEGIN;
CREATE TABLE church_tenant.organization(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), public_id varchar(64) NOT NULL UNIQUE,
 name text NOT NULL, type text NOT NULL, status text NOT NULL DEFAULT 'ACTIVE',
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 row_version bigint NOT NULL DEFAULT 1, deleted_at timestamptz);
CREATE TABLE church_tenant.church(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), public_id varchar(64) NOT NULL UNIQUE,
 organization_id uuid REFERENCES church_tenant.organization(id), slug text NOT NULL UNIQUE,
 legal_name text, display_name text NOT NULL, status text NOT NULL DEFAULT 'ACTIVE',
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 row_version bigint NOT NULL DEFAULT 1, deleted_at timestamptz);
CREATE TABLE church_tenant.campus(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 church_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 code text NOT NULL, name text NOT NULL, timezone text NOT NULL DEFAULT 'Asia/Seoul', status text NOT NULL DEFAULT 'ACTIVE',
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1,
 UNIQUE(church_id,code), CHECK(tenant_id=church_id));
CREATE TABLE church_tenant.tenant_setting(
 tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT, setting_key text NOT NULL,
 value_json jsonb NOT NULL DEFAULT '{}'::jsonb, version integer NOT NULL DEFAULT 1,
 PRIMARY KEY(tenant_id,setting_key));
CREATE TABLE church_tenant.tenant_domain(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 hostname text NOT NULL, status text NOT NULL DEFAULT 'PENDING', verified_at timestamptz,
 UNIQUE(lower(hostname)));

CREATE TABLE church_identity.account(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), public_id varchar(64) NOT NULL UNIQUE, status text NOT NULL DEFAULT 'ACTIVE',
 locale text, last_login_at timestamptz, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 row_version bigint NOT NULL DEFAULT 1, deleted_at timestamptz);
CREATE TABLE church_identity.person(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), public_id varchar(64) NOT NULL UNIQUE, display_name text NOT NULL,
 birth_year integer, status text NOT NULL DEFAULT 'ACTIVE', created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(), row_version bigint NOT NULL DEFAULT 1, deleted_at timestamptz,
 CHECK(birth_year IS NULL OR birth_year BETWEEN 1900 AND 2200));
CREATE TABLE church_identity.credential_link(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), account_id uuid NOT NULL REFERENCES church_identity.account(id) ON DELETE RESTRICT,
 provider text NOT NULL, provider_subject text NOT NULL, verified_at timestamptz, revoked_at timestamptz);
CREATE UNIQUE INDEX uq_credential_active ON church_identity.credential_link(provider,provider_subject) WHERE revoked_at IS NULL;
CREATE TABLE church_identity.account_person_link(
 account_id uuid NOT NULL REFERENCES church_identity.account(id) ON DELETE RESTRICT,
 person_id uuid NOT NULL REFERENCES church_identity.person(id) ON DELETE RESTRICT,
 link_type text NOT NULL, verified_at timestamptz, PRIMARY KEY(account_id,person_id,link_type));
CREATE TABLE church_identity.person_contact(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), person_id uuid NOT NULL REFERENCES church_identity.person(id) ON DELETE CASCADE,
 type text NOT NULL, encrypted_value text NOT NULL, search_hash text, verified_at timestamptz);
CREATE TABLE church_identity.person_profile(
 person_id uuid PRIMARY KEY REFERENCES church_identity.person(id) ON DELETE CASCADE, timezone text, locale text, avatar_ref text);
COMMIT;
