-- DEV-002 V003 | membership + community
BEGIN;
CREATE TABLE church_community.church_membership(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 person_id uuid NOT NULL REFERENCES church_identity.person(id) ON DELETE RESTRICT, member_no text, status text NOT NULL,
 joined_on date, ended_on date, created_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz);
CREATE UNIQUE INDEX uq_active_membership ON church_community.church_membership(tenant_id,person_id)
 WHERE status='ACTIVE' AND deleted_at IS NULL;
CREATE TABLE church_community.membership_profile(
 membership_id uuid PRIMARY KEY REFERENCES church_community.church_membership(id) ON DELETE CASCADE,
 preferred_name text, visibility text NOT NULL DEFAULT 'PRIVATE', directory_opt_in boolean NOT NULL DEFAULT false);
CREATE TABLE church_community.membership_status_history(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), membership_id uuid NOT NULL REFERENCES church_community.church_membership(id) ON DELETE CASCADE,
 from_status text, to_status text NOT NULL, reason text, occurred_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE church_community.household(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 name text NOT NULL, visibility text NOT NULL DEFAULT 'PRIVATE');
CREATE TABLE church_community.household_member(
 household_id uuid NOT NULL REFERENCES church_community.household(id) ON DELETE CASCADE,
 person_id uuid NOT NULL REFERENCES church_identity.person(id) ON DELETE RESTRICT, relationship text, is_primary boolean NOT NULL DEFAULT false,
 PRIMARY KEY(household_id,person_id));
CREATE TABLE church_community.community(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 campus_id uuid REFERENCES church_tenant.campus(id) ON DELETE SET NULL, parent_id uuid REFERENCES church_community.community(id) ON DELETE RESTRICT,
 type text NOT NULL, name text NOT NULL, status text NOT NULL DEFAULT 'ACTIVE',
 CHECK(parent_id IS NULL OR parent_id<>id));
CREATE TABLE church_community.community_membership(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 community_id uuid NOT NULL REFERENCES church_community.community(id) ON DELETE CASCADE,
 person_id uuid NOT NULL REFERENCES church_identity.person(id) ON DELETE RESTRICT,
 role_code text, status text NOT NULL DEFAULT 'ACTIVE', valid_from timestamptz NOT NULL DEFAULT now(), valid_to timestamptz,
 CHECK(valid_to IS NULL OR valid_to>valid_from));
CREATE TABLE church_community.community_meeting(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 community_id uuid NOT NULL REFERENCES church_community.community(id) ON DELETE CASCADE, schedule_id uuid,
 occurred_at timestamptz NOT NULL, status text NOT NULL);
CREATE TABLE church_community.meeting_participation(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES church_tenant.church(id) ON DELETE RESTRICT,
 meeting_id uuid NOT NULL REFERENCES church_community.community_meeting(id) ON DELETE CASCADE,
 membership_id uuid NOT NULL REFERENCES church_community.church_membership(id) ON DELETE RESTRICT, attendance_status text NOT NULL);
COMMIT;
