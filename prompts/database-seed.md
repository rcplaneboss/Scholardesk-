# Supabase Test Seed Data

## Goal

Add deterministic, clearly labeled local/test seed data for the Supabase schema in `supabase/migrations/0001_initial_schema.sql`, then document how to create authenticated test users and verify the main RLS and module-toggle workflows.

## Existing Code Inspected

- `prd.md`: required school, admin, teacher, attendance, fees, results, notification, module-toggle, and security workflows.
- `AGENTS.md`: tenant isolation, role enforcement, RLS, audit, and credential rules.
- `supabase/migrations/0001_initial_schema.sql`: current 20-table schema, helper functions, RLS policies, ranking view, SMS analytics view, and search RPC.
- `supabase/README.md`: current migration and security verification instructions.

## Decisions and Assumptions

- Add `supabase/seed.sql` as an explicit test/development seed script; do not alter the production migration.
- Seed only clearly labeled demo records. Do not seed real people, credentials, phone numbers, or secrets.
- Use deterministic UUIDs so manual RLS tests can refer to stable school, class, student, guardian, subject, term, fee, attendance, score, and notification records.
- Do not insert rows into `auth.users` from the seed. Supabase Auth users must be created through the Auth API/dashboard, after which their IDs can be used to create profiles.
- Do not create fake profile rows with nonexistent Auth IDs. Provide SQL templates or documented substitution steps for attaching real Auth user IDs to demo admin, teacher, and super-admin profiles.
- Keep the seed idempotent with `insert ... on conflict` behavior where practical. It must not delete user data or reset a shared database.
- Seed the demo school with all three modules enabled initially, then document the toggle tests that disable and re-enable each module.
- Use safe placeholder contact values such as `.invalid` email domains and clearly non-deliverable test phone values. Never call Termii from seed data.

## Files To Change

- `supabase/seed.sql`
- `supabase/README.md`
- `prompts/database-seed.md`

## Seed Requirements

Create a demo tenant with:

- One clearly labeled school with a stable slug and active trial status.
- One `school_modules` row with Attendance, Fees, and Results enabled.
- One class and at least three students with stable admission numbers.
- At least two guardians and student-guardian links, including one primary guardian.
- One active term with default CA maximum 40 and exam maximum 60.
- At least three subjects and class-subject assignments.
- A complete grading scale covering 0 through 100 without overlapping ranges.
- One fee category and fee assignments for the demo students.
- Attendance records only when they can reference a real seeded profile; otherwise leave profile-dependent attendance rows out and document how to add them after creating a teacher Auth user.
- No payment, score, notification, or audit records that claim to have been created by nonexistent users.

## Auth Profile Setup

Document the exact safe workflow:

1. Create three test Auth users through Supabase Dashboard or Auth API using test-only addresses.
2. Capture their generated UUIDs.
3. Insert profiles using those UUIDs: one `super_admin` with `school_id = null`, one approved `admin` tied to the demo school, and one approved `teacher` tied to the demo school.
4. Update the demo class `assigned_teacher` to the teacher profile ID.
5. Add any profile-dependent attendance, score, payment, or audit fixtures only after the corresponding profile exists.
6. Never commit passwords, access tokens, service-role keys, or real contact data.

## Verification Requirements

Document SQL/API checks for:

- Anonymous access cannot directly list schools or tenant tables.
- `find_schools('')` and short queries return no rows; a valid search returns only id, name, and slug.
- Demo admin can access only the demo school.
- A second school or cross-tenant record cannot be read by the demo admin.
- Teacher access is limited to the assigned class and does not expose fee amounts.
- Super-admin can view platform schools and module configuration.
- Disabling Attendance, Fees, or Results blocks the related school-user reads and writes through RLS while retaining the rows.
- Re-enabling a module restores access to retained data.
- Locked terms reject score writes and score maxima are enforced.
- Audit log rows cannot be updated or deleted.
- SMS analytics excludes pending delivery records from its success denominator.

## Acceptance Criteria

- `supabase/seed.sql` can be run after the initial migration on a fresh local/test project.
- Running it twice does not duplicate demo records or delete existing records.
- No Auth users, passwords, secrets, real contact details, or fake actor references are committed.
- The README explains exactly how to create test users, attach profiles, run the seed, test RLS, test module toggles, and clean up the demo tenant manually.
- Existing application lint, typecheck, and build checks remain passing.

## Checks To Run

- Apply the migration, then run `supabase/seed.sql` in a disposable Supabase project or SQL Editor.
- Run the documented anonymous, admin, teacher, cross-tenant, and super-admin RLS checks.
- Toggle each module off/on and verify rejection/restoration.
- Run `npm run lint`.
- Run `npx tsc --noEmit`.
- Run `npm run build`.
- Run `git diff --check`.
