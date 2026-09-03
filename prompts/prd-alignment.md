# PRD Alignment Corrections

## Goal

Correct only the existing foundation behavior that contradicts `prd.md` for School Attendance SMS v3.3. Preserve the current visual system and avoid implementing the broader attendance, fees, results, SMS, analytics, onboarding, or database feature set in this correction slice.

## Existing Code Inspected

- `prd.md`: current product requirements and route hierarchy.
- `AGENTS.md`: repository workflow and security requirements.
- `app/page.tsx`: currently renders a marketing-style home page not listed in the PRD route hierarchy.
- `app/login/page.tsx`: authenticates with Supabase but currently redirects every successful login to `/find-school` and has no recovery route.
- `app/[school-slug]/page.tsx`: validates a tenant through `resolveTenant`, checks authentication, then redirects to setup; it cannot currently resolve any slug.
- `app/find-school/page.tsx`: public search shell with no database lookup yet.
- `lib/tenant.ts`: typed but unconditional-null tenant lookup seam.
- `lib/supabase/server.ts` and `proxy.ts`: existing server client and session refresh boundary.

## Valid Contradictions To Correct

1. The PRD defines Login and Password Reset as auth entry points, but the rendered login page has no implemented password reset route.
2. The PRD requires successful login to redirect by role to the appropriate dashboard, but the current login action always redirects to `/find-school`.
3. The PRD requires tenant-scoped dashboard routing, but the current resolver returns null for every syntactically valid slug, making every tenant unavailable.
4. The current root route is an extra marketing landing page. Replace it with a concise operational entry point that links to the PRD-defined auth/school lookup flows, without adding new product functionality.

## Decisions and Constraints

- Keep the project runnable without a database schema or real school records.
- Use a clearly typed server-side lookup seam for tenant and profile data. It may return null until migrations/RPCs exist, but it must be the single boundary that will later perform the scoped lookup.
- Do not fabricate tenant records or role data in production behavior.
- Add `/reset-password` using Supabase Auth's recovery-email action. It must be a real form/action, not a dead link.
- Keep private Supabase, Termii, and AI credentials server-only.
- Because role/profile schema is not yet present, do not claim to implement final role redirects. Structure the auth action around a server-side profile lookup seam and use an explicit setup/unavailable response when profile data is not configured.
- Preserve path-based routing `/{school-slug}/...` and reject unresolved tenants without exposing school lists.

## Files Likely To Change

- `app/page.tsx`
- `app/login/page.tsx`
- `app/reset-password/page.tsx`
- `app/[school-slug]/page.tsx`
- `lib/tenant.ts`
- `lib/auth.ts` or another small server-side profile lookup seam if needed
- `README.md`

## Implementation Requirements

- Replace the root marketing composition with an operational entry page containing only ScholarDesk identity, sign-in, and find-school actions.
- Add a functional password-reset page that accepts an email and calls `supabase.auth.resetPasswordForEmail` through a server action. Include a success state and a surfaced error state.
- Keep login fields named `email` and `password`, call Supabase Auth server-side, and route successful authentication through a server-side role/profile resolution seam. Do not hardcode a role or send every user to school lookup.
- Preserve an explicit setup message when the required profile/tenant schema is unavailable rather than silently routing to the wrong dashboard.
- Keep tenant resolution as a server-only typed lookup seam. Valid syntax alone must not create a tenant; unresolved slugs must remain null and fall back to `/find-school`.
- Update route documentation to include `/reset-password` and clarify that final role routing waits for the profile schema/migrations.

## Acceptance Criteria

- `/` is an operational entry point, not a marketing landing page.
- `/login` has a functional recovery link to `/reset-password`.
- `/reset-password` sends a Supabase recovery email through a server action and shows success/error feedback.
- Login does not hardcode a universal `/find-school` redirect.
- Tenant lookup remains server-side, typed, scoped, and null for unresolved slugs.
- No fake tenant, profile, role, or school data is introduced.
- Existing lint, typecheck, and production build checks pass.

## Checks To Run

- `npm run lint`
- `npx tsc --noEmit`
- `npm run build`
- Manually verify `/`, `/login`, `/reset-password`, `/find-school`, and an unresolved tenant slug.