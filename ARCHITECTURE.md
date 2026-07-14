# Tavernboard — Architecture

## Summary
A personal productivity dashboard: a drag-and-resize board of modular widgets (task list, calendar, project board) backed by Supabase. Single user, web-first. Tavern-themed UI ("campaigns" = projects).

**History:** Phase 1 (complete, on main) was a Flutter web client with Supabase auth and three hardcoded dashboard widgets. Phase 2 is an approved respec migrating the client to React — Flutter was mobile-first with no Android target in sight, and drag-to-resize dashboards need `react-grid-layout`, which has no Flutter equivalent. The Supabase project, schema, and auth carry over unchanged; the Flutter source gets archived to `_flutter_archive/` at the start of Phase 2.

Full details: `docs/superpowers/specs/2026-04-28-react-respec-design.md` (design) and `docs/superpowers/plans/2026-04-28-react-respec.md` (implementation plan, Tasks 1–12).

## Stack (Phase 2)
| Layer | Choice |
|---|---|
| Build | Vite |
| Language | TypeScript (strict) |
| UI | React 18 |
| Styling | Tailwind CSS with custom tavern tokens (oak/parchment/ember/iron; Cinzel + Lora fonts) |
| Data fetching | TanStack Query v5 |
| Auth + DB | Supabase (JS SDK v2); email/password + anonymous guest |
| Dashboard grid | react-grid-layout |
| Testing | Vitest + React Testing Library |

## Major Modules
- **Widget modules** (`src/widgets/<name>/`): each widget owns `config.ts` (typed config + defaults + `fromJson`), `meta.ts` (typeKey, displayName, icon), `index.tsx` (component), and optionally a `SettingsForm`. Adding a widget = new folder + one registry entry.
- **Widget registry** (`src/widgets/widgetRegistry.ts`): maps `type_key` → `{ meta, Component, SettingsForm? }`. Registered via side-effect import in `main.tsx`.
- **Dashboard** (`src/screens/DashboardScreen.tsx`): reads layout rows from the `dashboard_widgets` table, renders via react-grid-layout; drag/resize persists through a debounced mutation (cache patched in place — no invalidation, to avoid write loops).
- **Shared data hooks** (`src/hooks/`): `useEntries`, `useProjects`, `useDashboardLayout` — TanStack Query deduplicates so multiple widgets share one fetch. Widgets never fetch directly.
- **Auth** (`src/contexts/AuthContext.tsx`): session state + protected routes; redirects to `/login` when unauthenticated.

## Data Model (Supabase)
- `entries` — tasks/events/deadlines (+ reserved `habit` types); belongs to a project (nullable)
- `projects` — "campaigns"; name, color, optional category + deadline
- `categories` — user-defined groupings (schema only; no UI in Phase 2)
- `recurrence_exceptions` — skip/reschedule for recurring entries (schema only; recurrence deferred)
- `dashboard_widgets` — one row per placed widget: `type_key`, layout columns (`pos_x`, `pos_y`, `width`, `height`), widget config in `settings` JSONB

All tables have RLS (`user_id = auth.uid()`, USING + WITH CHECK) and `user_id DEFAULT auth.uid()` so clients omit it on insert (migrations 001–002).

## Deferred
Reminders/notifications, recurrence engine (TypeScript reimplementation), categories UI, Google OAuth, Cloudflare Pages deployment, new widgets beyond the initial three, E2E tests.
