# Supabase Database

The initial database is in `migrations/0001_initial_schema.sql`. It creates the tenant, profile, school module, attendance, fee, results, notification, platform settings, audit, ranking, and SMS analytics contracts required by `prd.md`.

## Apply

Use the Supabase CLI against a fresh project:

```sh
supabase db push
```

No business records are seeded. The migration inserts only the singleton platform-settings row with zero-valued SMS defaults.

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

The migration must be tested with both `anon` and `authenticated` roles after applying it to a real Supabase project. Do not rely on application UI tests as a substitute for RLS verification.