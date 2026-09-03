# Super Admin Platform Dashboard

## Goal

Implement the PRD-defined super-admin experience for School Attendance SMS v3.3. Build a protected, role-gated platform dashboard with school management, per-school Attendance/Fees/Results module configuration, platform metrics, SMS analytics presentation, and a restartable onboarding entry point. Establish the server-side seams and database contract needed for real Supabase-backed data without fabricating production records or weakening tenant isolation.

## Existing Code Inspected

- `prd.md`: super-admin role, page hierarchy, school management, module toggles, platform metrics, SMS analytics, onboarding, schema, security, and acceptance criteria.
- `AGENTS.md`: required authentication, role, tenant, module, audit, and server-side security constraints.
- `app/login/page.tsx`: Supabase password authentication and unresolved profile destination seam.
- `app/[school-slug]/page.tsx`: current tenant route and unresolved tenant lookup behavior.
- `lib/auth.ts`: typed but unresolved user destination seam.
- `lib/tenant.ts`: typed but unresolved tenant lookup seam.
- `lib/supabase/server.ts` and `proxy.ts`: server Supabase client and response-cookie refresh boundary.
- `app/page.tsx`, `app/globals.css`, and `app/layout.tsx`: current ScholarDesk visual tokens and application shell.
- No database migrations, generated Supabase types, dashboard components, profile schema, school schema, audit layer, or notification analytics implementation currently exists.

## Decisions and Assumptions

- Implement the super-admin route as `/super-admin` with nested platform sections, because the PRD defines a platform dashboard but does not prescribe a URL.
- Use real server actions/route handlers and typed repository functions as the only data access boundary. Until Supabase migrations and generated types exist, return an explicit unavailable state rather than mock schools, metrics, module states, revenue, or SMS data.
- Super-admin authorization must be checked server-side from the authenticated profile role. Client navigation visibility is not authorization.
- Super-admin access is platform-wide and must not be routed through a school slug. Public pages must not link to the super-admin route.
- All state-changing operations must be prepared for append-only audit logging. Do not add a mutable audit UI that implies writes succeeded when the audit schema is absent.
- The first implementation should favor a coherent usable dashboard shell and secure boundaries over speculative CRUD that cannot be persisted safely.

## Files Likely To Change

- `app/super-admin/layout.tsx`
- `app/super-admin/page.tsx`
- `app/super-admin/schools/page.tsx`
- `app/super-admin/schools/[school-id]/page.tsx`
- `app/super-admin/sms-analytics/page.tsx`
- `components/super-admin/*`
- `lib/auth.ts`
- `lib/supabase/server.ts` or a dedicated server repository module
- `lib/super-admin/*`
- `app/globals.css` only if shared tokens need completion
- `README.md`
- Supabase migrations and generated database types if the project establishes them in this slice

## Implementation Requirements

### Authentication and authorization

- Resolve the authenticated user and profile server-side before rendering any super-admin page.
- Allow only `role = super_admin`; redirect unauthenticated users to `/login?next=/super-admin` and authenticated non-super-admin users to an appropriate safe destination without exposing platform data.
- Complete the login destination seam so a super-admin is sent to `/super-admin` once a profile lookup is available. Do not infer role from email, URL, client state, or metadata that is not server-validated.
- Check subscription and school status only for school-scoped users; super-admin access is platform-level.

### Dashboard shell

- Add responsive platform navigation for Overview, Schools, SMS Analytics, and Help/onboarding entry.
- Display the current platform context and clear loading, unavailable, empty, error, and forbidden states.
- Preserve the supplied navy, warm gold, paper, and typography system. Keep the dashboard dense and operational rather than marketing-oriented.
- Use accessible buttons, labels, table headings, focus states, responsive overflow handling, and keyboard-operable toggles.

### School management

- Provide a server-backed school list contract with school name, subscription status, trial end date, active/inactive status, and minimum identifying fields.
- Provide create, edit, deactivate, and reactivate actions only through server-side authorization. Do not render fake success toasts when persistence is unavailable.
- Provide a school detail view with admin-user summary and module configuration.
- New-school creation must accept initial Attendance, Fees, and Results states, using the configured defaults when fields are omitted.
- Deactivation/reactivation must be auditable and must not delete school data.

### Module configuration

- Display exactly three module toggles: Attendance, Fees, Results.
- Persist changes to `school_modules` immediately through a server-side action or route handler.
- Return a confirmation message naming the school and module state only after the write succeeds.
- Preserve module data when disabled.
- Enforce super-admin authorization and school target validation on every toggle request.
- Keep the contract compatible with school-side backend checks: disabled modules must later be rejected by RLS/server checks even if a direct request bypasses the UI.

### Platform metrics and fee overview

- Add cards/tables for total schools, active subscriptions, total students, SMS sent in the last 30 days, current-term fee assignments, and current-term payments.
- Add fee overview values for total assignments, total payments, per-school collection rate, and lowest collection rates.
- Metrics must be clearly marked unavailable when the required schema/query is not present; never substitute invented counts.
- Keep aggregation server-side and platform-scoped.

### SMS analytics

- Add the PRD-required per-school columns: SMS totals by type, estimated cost, student count, allocation usage percentage, alert flag, and delivery success rate.
- Add sortable SMS volume, All/Yellow/Red filtering, expandable per-school notification breakdown, platform totals, cost, revenue/profit margin state, and top-ten ranking.
- Exclude pending delivery records from delivery success-rate denominators as required by the PRD.
- Use the active term by default and provide a past-term selection seam.
- Do not expose guardian phone numbers or unrestricted notification content in the platform table.
- Do not display a numeric revenue/profit figure unless the platform pricing/revenue source exists; show the specified unavailable state.

### Onboarding

- Add a role-specific super-admin onboarding model with the six PRD steps and feature targets.
- Auto-trigger only when `profiles.has_seen_onboarding` is false, and persist completion/dismissal through a server-side profile update.
- Add a persistent Help control that restarts from step one.
- Keep the overlay dismissible and usable without trapping the user in the tour.
- If profile persistence is not yet available, show an explicit setup state rather than silently claiming completion.

### Audit and security

- Prepare append-only audit events for school creation/updates, activation changes, and module toggles, including actor id/role, target school, action, and before/after values.
- No UI path may edit or delete audit events.
- Validate every server action input, including UUIDs, module names, booleans, and school status values.
- Never import service-role credentials into client components.
- Do not create blanket public policies for schools or platform tables.

## Acceptance Criteria

- `/super-admin` is inaccessible to logged-out users and non-super-admin users through server-side checks.
- A validated super-admin can reach Overview, Schools, and SMS Analytics sections.
- School management and module configuration have real server-side data seams and explicit unavailable states until schema-backed persistence is installed.
- The three module toggles are independently represented and prepared for immediate persistence.
- Disabled module state is not treated as tenant access and does not delete retained data.
- Platform metrics and SMS analytics follow the PRD calculations and do not show fabricated values.
- Onboarding steps are role-specific, restartable, dismissible, and profile-backed when the schema exists.
- No public-facing route links to `/super-admin`.
- Lint, typecheck, and production build pass.

## Checks To Run

- `npm run lint`
- `npx tsc --noEmit`
- `npm run build`
- Manually verify unauthenticated, non-super-admin, and super-admin route behavior.
- Manually verify desktop and mobile dashboard layout, table overflow, toggle keyboard access, and unavailable/empty states.
- Verify no private environment variable is imported into client code.
- If migrations are added, run explicit RLS checks for `anon`, authenticated school users, and `super_admin` across school and module operations.

## Exact Manual Test Steps

1. Configure the public Supabase environment values and the profile schema/seed required for a super-admin test account.
2. Start the development server.
3. Open `/super-admin` signed out; verify redirect to login.
4. Sign in as an admin or teacher; verify platform access is denied and no school-wide data is shown.
5. Sign in as a super-admin; verify the platform dashboard opens without a school slug.
6. Open School Management; verify list, empty, loading, and unavailable states according to the configured backend.
7. Open a school detail view; toggle each module and verify success only after persistence, with an audit event recorded.
8. Open SMS Analytics; verify type breakdowns, filtering, sorting, thresholds, delivery-rate handling, and unavailable revenue state.
9. Start, skip, complete, and restart the super-admin onboarding tour.
10. Resize to a mobile viewport and verify navigation, tables, toggles, and controls remain usable.
11. Run lint, typecheck, and production build and record the outcomes.