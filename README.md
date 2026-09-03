# ScholarDesk

Initial project foundation for ScholarDesk, a path-based multi-tenant school management platform.

## Local development

```bash
npm install
cp .env.example .env.local
npm run dev
```

Open http://localhost:3000. Initial routes are `/`, `/login`, `/reset-password`, `/find-school`, `/{school-slug}`, and `/super-admin` with nested `/super-admin/schools` and `/super-admin/sms-analytics` views.

## Checks

```bash
npx tsc --noEmit
npm run lint
npm run build
```