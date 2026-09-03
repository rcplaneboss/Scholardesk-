# ScholarDesk Project Foundation

## Goal

Create the initial ScholarDesk application foundation from the currently empty repository. Establish a runnable Next.js and TypeScript app, the shared ScholarDesk visual system, the base route structure, and the first authentication and school-selection shell. Do not implement attendance, fees, results, AI, SMS, reporting, or super-admin workflows in this phase.

## Existing Code Inspected

- `AGENTS.md`: product scope, mandatory tenant isolation, security constraints, implementation workflow, and required checks.
- `README.md`: currently contains only the project title.
- `designs/design_system.png`: ScholarDesk brand, color tokens, typography, spacing, components, dashboard layout, mobile patterns, and RTL direction.
- `designs/file_00000000b7fc81f48ccc46ec55ba9069.png`: reference screens for login, school selection, admin dashboard, students, attendance, fees, results, and student profile.
- No application source, package manifest, Supabase configuration, migrations, or environment template currently exists.

## Decisions and Assumptions

- Use the current repository's empty state to scaffold Next.js with TypeScript, Tailwind CSS, and shadcn/ui-compatible components.
- Use the App Router and preserve the required path-based tenant shape: `/{school-slug}/...`.
- Treat `/login` and `/find-school` as public entry points. Keep any platform/super-admin login route unlinked from public pages.
- Build only the visual and routing shell needed to prove the architecture. Use typed mock data only where necessary for static UI previews; do not create fake persistence or bypass security boundaries.
- Supabase integration must be server-safe and environment-driven. Do not add client exposure for service-role, Termii, or AI credentials.
- Use the supplied design references as the source of truth for the warm paper, navy, and gold direction. Use Plus Jakarta Sans and Lora when available through a supported font-loading approach.

## Files Likely To Change

- `package.json` and lockfile
- `app/` routes and layouts
- `components/` shared UI and navigation
- `lib/` typed configuration and Supabase client boundaries
- `app/globals.css` and Tailwind configuration/theme tokens
- `.env.example`
- `README.md`
- Focused tests or validation configuration if the scaffold supports them

## Implementation Requirements

### Project and design foundation

- Scaffold a runnable Next.js TypeScript application using the existing repository rather than introducing another framework.
- Add Tailwind CSS and shadcn/ui-compatible primitives following their local installation pattern.
- Define the design system through theme tokens/CSS variables, including navy blue, warm gold, paper, beige, gray neutrals, semantic states, spacing, radius, elevation, and typography.
- Create reusable primitives for buttons, inputs, selects, badges, cards, tables, alerts, and icons only where needed by the initial screens.
- Keep the visual language restrained, academic, warm, and professional. Match the supplied desktop and mobile references without adding unrelated screens.
- Ensure keyboard focus, labels, error states, disabled states, and responsive behavior are present for the implemented controls.

### Initial routes and shell

- Add a public login route with email/password fields, forgot-password affordance, sign-in action, and a visually distinct school-management panel consistent with the reference.
- Add a public find-school route with search-only behavior: empty input must not reveal a school list, and results must expose only the minimum routing fields needed.
- Add a tenant route shell under `/{school-slug}` with a protected dashboard placeholder and responsive sidebar/header structure based on the reference.
- Add a clear not-found or unavailable state for invalid school slugs.
- Keep tenant resolution in a dedicated server-side boundary so later data operations receive a resolved `school_id` before querying.

### Supabase and configuration boundaries

- Add typed server/client Supabase setup using only `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in browser-capable code.
- Keep `SUPABASE_SERVICE_ROLE_KEY`, `TERMII_API_KEY`, AI keys, and any future private credentials server-only.
- Add `.env.example` with the canonical variables from `AGENTS.md`, without real credentials.
- Do not add blanket public access to a schools table. If school lookup is represented in this phase, keep it as an explicitly isolated server/RPC seam or a clearly marked typed placeholder until the database schema exists.

### Security and tenant isolation

- Do not treat client-side route visibility as authorization.
- Protected tenant routes must have a server-side authentication boundary and must not render tenant data before slug/session validation.
- The tenant boundary must be structured to reject a session belonging to one school when the URL resolves to another school; do not silently switch tenants.
- Do not add database tables or permissive RLS policies in this foundation phase unless strictly required by the scaffold. Database policy work belongs in a dedicated approved task with explicit anon and authenticated tests.

## Visual Interpretation

- Use paper/off-white surfaces with deep navy navigation and text, warm gold for brand emphasis, and restrained semantic colors.
- Use Plus Jakarta Sans for interface text and Lora for prominent headings/brand moments, with a robust fallback.
- Use compact, information-dense dashboard spacing, subtle borders/shadows, small corner radii, and outlined icon treatments.
- Desktop should use a fixed-width navigation rail plus a flexible content area. Mobile should collapse navigation into an accessible menu and preserve comfortable tap targets.
- Do not create a marketing landing page, decorative gradient hero, or extra product feature sections.
- Include direction-aware layout foundations so Arabic/RTL work can be added later without rewriting the shell; do not claim full RTL support in this phase.

## Acceptance Criteria

- The project installs and runs locally with documented commands.
- The initial routes render without TypeScript, lint, or build errors.
- Login, find-school, invalid-school, and tenant dashboard shell states are reachable at the documented paths.
- Find-school does not show all schools on empty input.
- Tenant pages do not render for unauthenticated users, and the route structure preserves `/{school-slug}/...`.
- No server-only secrets are imported into browser code.
- The design tokens and responsive shell visibly follow the supplied references on desktop and mobile widths.
- No attendance, fees, results, AI, SMS, PDF, or unrelated feature implementation is included.

## Checks To Run

- Install dependencies using the selected package manager.
- Type checking, such as `npx tsc --noEmit`.
- Linting, such as `npm run lint`.
- Production build, such as `npm run build`.
- Manually verify each initial route at desktop and mobile viewport widths.
- Verify that no private environment variable is referenced by client components.

## Exact Manual Test Steps

1. Copy `.env.example` to a local environment file and provide only the public Supabase values required for the scaffold.
2. Start the development server using the documented command.
3. Open `/login`; verify the form, labels, focus states, and responsive layout.
4. Open `/find-school`; verify that an empty search shows no school list, then verify the loading, no-result, and result states if implemented.
5. Open an invalid tenant slug; verify the unavailable/not-found state.
6. Open a valid tenant dashboard path while signed out; verify that it is blocked by the server-side auth boundary.
7. Resize to a mobile viewport; verify navigation access, no horizontal overflow, and usable controls.
8. Run the typecheck, lint, and production build commands and record their exact outcomes.