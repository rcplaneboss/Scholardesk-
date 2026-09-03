# Supabase Database Foundation

## Goal

Implement the database foundation required by `prd.md` for School Attendance SMS v3.3. Add an ordered Supabase migration with the core tenant, identity, school-management, module-toggle, attendance, fees, results, notifications, platform-settings, audit, and analytics data contracts. Enforce tenant, role, active-school, and module access in PostgreSQL rather than relying on the UI.

## Existing Code Inspected

- `prd.md`: required entities, SQL examples, business rules, module definitions, RLS requirements, SMS analytics queries, and acceptance criteria.
- `AGENTS.md`: mandatory path-based tenancy, Supabase Auth/RLS, append-only audit rules, server-only secrets, and explicit anon/authenticated policy testing.
- `lib/supabase/server.ts`, `lib/supabase/client.ts`, and `proxy.ts`: existing Supabase client boundaries and session refresh handling.
- `lib/auth.ts`, `lib/tenant.ts`, and `lib/super-admin/access.ts`: current typed lookup seams that must remain compatible with the database contract.
- No `supabase/`, migrations, database types, or existing schema currently exists.

## Decisions and Assumptions

- Use a new `supabase/migrations/0001_initial_schema.sql` migration and keep all database work versioned and repeatable in repository history.
- Use Supabase/Postgres `gen_random_uuid()` and `auth.users` rather than relying on the older `uuid_generate_v4()` extension.
- Use `profiles.id = auth.users.id` as the identity link, with `role` values `super_admin`, `admin`, and `teacher`.
- Store money in integer kobo, timestamps as `timestamptz`, and notification state with explicit enums/check constraints.
- Use `SECURITY DEFINER` helper functions owned by `postgres` (with a fixed `search_path`) for role, school, and module checks so policies do not recursively query RLS-protected profiles/module tables.
- Do not seed fake schools, users, students, payments, or SMS. Seed only safe platform defaults if required for deterministic configuration.
- The migration must be safe to apply to a fresh Supabase project. Existing v1/v2 schema is not present in this repository, so all referenced base tables are created here.
- Public school lookup must be search-only and return only routing-safe fields. Do not grant blanket `select` access to `schools`.

## Files Likely To Change

- `supabase/migrations/0001_initial_schema.sql`
- `supabase/README.md` or root `README.md`
- `lib/supabase/database.types.ts` if generated/manual types are introduced
- `lib/tenant.ts` and `lib/super-admin/data.ts` when wiring queries to the schema
- Focused SQL/RLS verification scripts if supported by the project

## Schema Requirements

Create the following tables with UUID primary keys, appropriate foreign keys, timestamps, indexes, and constraints:

- `schools`: name, slug, contact fields, address, logo URL, subscription status/plan, trial end, active status, creation/update timestamps.
- `profiles`: auth user id, school id nullable for super-admins, full name, role, approval status, `has_seen_onboarding`, created/updated timestamps.
- `classes`: school id, name, grade level, assigned teacher, active state.
- `students`: school id, class id, full name, admission number, date of birth, active state, timestamps.
- `guardians`: school id, name, phone, relationship, timestamps.
- `student_guardians`: student/guardian link, primary flag, unique link constraint.
- `school_modules`: one row per school, independent attendance/fees/results booleans, update timestamp.
- `attendance_records`: school/student/class/teacher/date/status/submitted timestamp, unique student/date constraint.
- `fee_categories`: school, name, amount in kobo, term, academic year, due date, description, active state.
- `fee_assignments`: school/student/category, assigned amount in kobo, payment status derived from payments, unique student/category constraint.
- `fee_payments`: school/assignment, amount in kobo, payment date, method, reference, recorded by, voided state/reason/timestamp.
- `subjects`: school, name, code, active state.
- `class_subjects`: class/subject join with composite primary key.
- `grading_scale`: school, min/max score, grade, remark, with valid non-overlapping range intent documented or constrained where practical.
- `terms`: school, name, academic year, date range, active/locked state, resumption date, CA/exam maximums.
- `score_records`: school/student/subject/term/class, CA/exam scores, generated total, entered by, unique student/subject/term constraint.
- `report_card_remarks`: student/term, teacher/principal remarks, unique student/term constraint.
- `notifications_log`: school/student/guardian, notification type, phone/message, status, delivery status, provider response, timestamps, retry metadata.
- `platform_settings`: singleton/configurable SMS cost, expected messages per student, and revenue-related settings.
- `audit_log`: append-only actor/profile role, school target, action, target type/id, before/after JSON, timestamp.

## Database Logic

- Add indexes for every school-scoped foreign key, lookup slug, active term, attendance date, notification type/status/date, fee status, and score lookup.
- Add updated-at trigger(s) where useful.
- Add constraints for role/status/module/notification/payment method values, score ranges, positive money values, valid date ranges, and one active term per school.
- Add generated or view-level balance logic that excludes voided payments and does not store stale balances.
- Add a rank query/view using `RANK()` over summed term scores; do not store class rank.
- Add a scoped SMS analytics view or stable query contract aggregating notification types, delivery success, cost, allocation usage, and threshold status by active term.
- Add a search-only `find_schools(search_query text)` RPC with minimum result columns and no results for empty/short input. It must not expose a full school list.
- Add helper functions for current profile, current school, super-admin role, and module-enabled checks. Functions must be server-safe, narrowly privileged, and have fixed `search_path`.

## RLS and Authorization

- Enable RLS on every application table, including `schools`, `profiles`, `school_modules`, and `audit_log`.
- Super-admins can manage platform schools, modules, settings, and platform analytics.
- Admins and teachers can access only their profile school. Teachers must be further restricted to assigned class/subject operations where the table semantics allow it.
- Every attendance operation requires Attendance enabled; every fee operation requires Fees enabled; every Results operation requires Results enabled.
- Disabled module data remains stored but is inaccessible through RLS until re-enabled.
- Anonymous users cannot select application tables; school lookup is only through the scoped RPC.
- Authenticated users cannot read another school by guessing UUIDs or IDs.
- Profiles must not allow users to self-promote or change their school/role.
- Audit log must allow inserts only through controlled server-side paths/triggers and must deny update/delete to every app role.
- Super-admin destructive operations must be auditable; school deactivation must not cascade-delete operational data.
- Use separate `USING` and `WITH CHECK` expressions where needed so inserts/updates cannot cross tenants or bypass module state.

## Seed and Verification Requirements

- Do not create fake business data.
- Add only safe default platform settings if required.
- Include SQL verification queries or a documented Supabase SQL Editor checklist covering `anon`, authenticated school user, authenticated cross-tenant user, teacher, admin, and super-admin behavior.
- Explicitly verify disabled-module reads/writes fail for authenticated school users and work again after re-enable.
- Explicitly verify super-admin platform access and cross-tenant school management.
- Verify audit rows cannot be updated or deleted.

## Acceptance Criteria

- A fresh Supabase project can apply the migration successfully.
- All PRD-required tables and core relationships exist with constraints and indexes.
- Tenant and role isolation is enforced by RLS, not just application queries.
- Attendance, Fees, and Results operations are independently blocked when their school module is disabled.
- Public school lookup cannot bulk enumerate schools.
- Fee amounts and payments use integer kobo; voided payments are excluded from balances.
- Scores calculate totals server-side and respect term lock and score maxima.
- Rank and SMS analytics contracts follow PRD rules.
- Audit records are append-only and contain actor, action, target, timestamp, and before/after data where relevant.
- Existing TypeScript clients can be wired to the schema without exposing service-role credentials.
- SQL verification and project checks are documented and pass where a Supabase project is available.

## Checks To Run

- Apply the migration with the Supabase CLI or SQL Editor against a fresh project.
- Run PostgreSQL syntax and migration checks.
- Run explicit RLS tests for `anon`, authenticated same-school users, cross-tenant users, teachers, admins, and super-admins.
- Verify module-disabled read/write rejection for all three module families.
- Run `npm run lint`, `npx tsc --noEmit`, and `npm run build` after any TypeScript wiring.
- Verify `SUPABASE_SERVICE_ROLE_KEY` is never imported by browser code.