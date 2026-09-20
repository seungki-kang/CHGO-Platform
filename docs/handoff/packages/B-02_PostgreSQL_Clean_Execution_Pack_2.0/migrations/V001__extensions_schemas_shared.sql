-- DEV-002 V001 | extensions, schemas, shared functions | PostgreSQL 16+
BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS church_identity;
CREATE SCHEMA IF NOT EXISTS church_tenant;
CREATE SCHEMA IF NOT EXISTS church_community;
CREATE SCHEMA IF NOT EXISTS church_access;
CREATE SCHEMA IF NOT EXISTS church_brand;
CREATE SCHEMA IF NOT EXISTS church_module;
CREATE SCHEMA IF NOT EXISTS church_integration;
CREATE SCHEMA IF NOT EXISTS church_audit;

CREATE OR REPLACE FUNCTION church_access.current_tenant_id() RETURNS uuid
LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('app.tenant_id',true),'')::uuid $$;
CREATE OR REPLACE FUNCTION church_access.current_actor_id() RETURNS uuid
LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('app.actor_id',true),'')::uuid $$;
CREATE OR REPLACE FUNCTION church_access.current_purpose() RETURNS text
LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('app.purpose',true),'') $$;
CREATE OR REPLACE FUNCTION church_audit.touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at=now(); NEW.row_version=OLD.row_version+1; RETURN NEW; END $$;
COMMIT;
