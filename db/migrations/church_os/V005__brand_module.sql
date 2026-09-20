-- DEV-002 V005 | brand + module
BEGIN;
CREATE TABLE church_brand.brand_profile(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 display_name text NOT NULL, logo_asset_id uuid, support_contact text, status text NOT NULL DEFAULT 'ACTIVE');
CREATE UNIQUE INDEX uq_brand_active ON church_brand.brand_profile(tenant_id) WHERE status='ACTIVE';
CREATE TABLE church_brand.theme_version(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), brand_id uuid NOT NULL REFERENCES church_brand.brand_profile(id) ON DELETE CASCADE,
 version integer NOT NULL, color_tokens jsonb NOT NULL DEFAULT '{}'::jsonb, typography_tokens jsonb NOT NULL DEFAULT '{}'::jsonb,
 status text NOT NULL DEFAULT 'DRAFT', channel text NOT NULL DEFAULT 'WEB', UNIQUE(brand_id,version,channel));
CREATE UNIQUE INDEX uq_theme_published ON church_brand.theme_version(brand_id,channel) WHERE status='PUBLISHED';
CREATE TABLE church_brand.navigation_policy(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 audience text NOT NULL, ordered_items jsonb NOT NULL DEFAULT '[]'::jsonb, version integer NOT NULL, UNIQUE(tenant_id,audience,version));
CREATE TABLE church_brand.canonical_alias(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 canonical_id text NOT NULL, ontology_version text NOT NULL, locale text NOT NULL, label text NOT NULL,
 UNIQUE(tenant_id,canonical_id,ontology_version,locale));
CREATE TABLE church_brand.app_release_binding(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 channel text NOT NULL, theme_version_id uuid REFERENCES church_brand.theme_version(id), config_version integer NOT NULL,
 active boolean NOT NULL DEFAULT true);

CREATE TABLE church_module.module_catalog(
 code text PRIMARY KEY, version integer NOT NULL DEFAULT 1, deprecated boolean NOT NULL DEFAULT false);
CREATE TABLE church_module.tenant_module(
 tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT, module_code text NOT NULL REFERENCES church_module.module_catalog(code),
 enabled boolean NOT NULL DEFAULT true, config_version integer NOT NULL DEFAULT 1, PRIMARY KEY(tenant_id,module_code));
CREATE TABLE church_module.module_dependency(
 required_module text NOT NULL REFERENCES church_module.module_catalog(code),
 dependent_module text NOT NULL REFERENCES church_module.module_catalog(code), PRIMARY KEY(required_module,dependent_module));
CREATE TABLE church_module.feature_flag(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 scope_type text NOT NULL, scope_id uuid, flag_code text NOT NULL, enabled boolean NOT NULL, expires_at timestamptz NOT NULL);
CREATE TABLE church_module.module_policy(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), module_code text NOT NULL REFERENCES church_module.module_catalog(code),
 privacy_level text NOT NULL, consent_required boolean NOT NULL DEFAULT false, minimum_role text);
COMMIT;
