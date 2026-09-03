# Supabase Database

The initial database is in `migrations/0001_initial_schema.sql`. It creates the tenant, profile, school module, attendance, fee, results, notification, platform settings, audit, ranking, and SMS analytics contracts required by `prd.md`.

## Apply

Use the Supabase CLI against a fresh project:

```sh
supabase db push
```

The migration inserts only the singleton platform-settings row with zero-valued SMS defaults. Optional test fixtures live in `seed.sql`; run them only against a disposable local or test project. They use `.invalid` email domains and non-deliverable phone values, and never create Auth users or call Termii.

## Seed test fixtures

After applying the migration, run `seed.sql` in the Supabase SQL Editor or with the CLI. It creates two labeled schools, one demo class, three demo students, guardians, an active term, subjects, grading ranges, a fee category, and fee assignments. It is idempotent and does not delete or reset records.

Create test Auth users through Supabase Dashboard or the Auth API first. Never put passwords in this repository. After capturing their generated UUIDs, run this template with the UUIDs substituted:

```sql
insert into public.profiles (id, school_id, full_name, role, approval_status)
values
	('<super-admin-auth-uuid>', null, 'Test Super Admin', 'super_admin', 'approved'),
	('<admin-auth-uuid>', '11111111-1111-4111-8111-111111111111', 'Test Demo Admin', 'admin', 'approved'),
	('<teacher-auth-uuid>', '11111111-1111-4111-8111-111111111111', 'Test Demo Teacher', 'teacher', 'approved');

update public.classes
set assigned_teacher = '<teacher-auth-uuid>'
where id = '31111111-1111-4111-8111-111111111111';
```

Profile insertion must be performed with a controlled server/service-role path or SQL Editor, never from browser code. Add profile-dependent attendance, score, payment, notification, and audit fixtures only after real Auth profiles exist.

## Security verification

Run these checks in the Supabase SQL Editor with test accounts for each role:

1. As `anon`, verify direct `select` from `schools`, `profiles`, `school_modules`, and all tenant tables returns no rows or permission errors. Verify `find_schools(NULL)` and `find_schools('')` return no rows, and a two-character query returns only active schools with `id`, `name`, and `slug`.
2. As an approved school admin, verify reads and writes are limited to that admin's `school_id`.
3. As an approved teacher, verify student/attendance/score access is limited to the assigned class and that fee tables do not expose amounts.
4. As an approved user from School A, attempt to read or write a School B record by UUID; verify RLS rejects it.
5. Disable each `school_modules` flag as super-admin and verify the corresponding attendance, fee, or results reads and writes fail for school users while unrelated modules continue to work.
6. Re-enable each flag and verify previously retained module data is accessible again.
7. As super-admin, verify platform school, module, settings, notification, and cross-school analytics access.
8. Attempt `update` and `delete` on `audit_log` as every app role; verify both are rejected. Use `record_audit_event` only through controlled server-side actions.
9. Verify score writes reject locked terms and scores above the configured CA/exam maximums.
10. Verify `class_score_rankings` gives tied students the same rank and skips the next rank.

For a quick seeded smoke test, search for `scholardesk-demo`, sign in as the seeded admin or teacher, and use the stable demo class/student IDs above when exercising policies. To test tenant isolation, use `boundary-school` as the second tenant and attempt to read the demo school's records while authenticated as a boundary-school profile.

The migration must be tested with both `anon` and `authenticated` roles after applying it to a real Supabase project. Do not rely on application UI tests as a substitute for RLS verification.