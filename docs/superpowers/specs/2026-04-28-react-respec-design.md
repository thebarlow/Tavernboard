# Tavernboard — React Respec Design

**Date:** 2026-04-28
**Status:** Approved
**Scope:** Full framework migration (Flutter → React) + modular widget system

---

## Context

Phase 1 delivered a working Flutter web app with Supabase auth and three hardcoded dashboard widgets (Calendar, Task List, Project Board). This respec addresses three problems:

1. Flutter is a mobile framework being used web-only — no Android target in the near term.
2. The widget system was ad hoc: untyped config, static global registry, hardcoded layout.
3. Drag-to-resize dashboard layout is a first-class requirement; Flutter has no mature library for this. React does (`react-grid-layout`).

The Supabase project, schema, and auth setup carry over unchanged. Only the client is replaced.

---

## Stack

| Layer | Choice | Reason |
|---|---|---|
| Build tool | Vite | Fast dev server, standard for React |
| Language | TypeScript | Required for typed widget configs |
| UI | React 18 | Stable; matches @types and testing-library support |
| Styling | Tailwind CSS | Custom tavern theme tokens, no CSS sprawl |
| Data fetching | TanStack Query v5 | Caching, deduplication, Supabase integration |
| Auth + DB | Supabase JS SDK v2 | Existing Supabase project carries over |
| Dashboard grid | react-grid-layout | Drag, resize, collision detection, layout persistence |

---

## Folder Structure

```
src/
  widgets/
    task-list/
      index.tsx          ← widget component
      config.ts          ← typed config interface + defaults + fromJson
      meta.ts            ← typeKey, displayName, icon, defaultConfig
    calendar/
    project-board/
    widgetRegistry.ts    ← central registry: typeKey → { meta, Component }
  hooks/
    useEntries.ts        ← shared TanStack Query hook for tasks
    useProjects.ts       ← shared TanStack Query hook for campaigns/projects
    useDashboardLayout.ts
  components/            ← shared UI primitives (Button, Card, Dialog, etc.)
  screens/
    DashboardScreen.tsx
    LoginScreen.tsx
  lib/
    supabase.ts          ← typed Supabase client singleton
    queryClient.ts       ← TanStack Query client setup
  contexts/
    AuthContext.tsx      ← session state, protected route logic
```

---

## Widget System

### Widget Module Contract

Each widget folder exports three things:

**`config.ts`** — typed settings interface for widget-specific preferences:

```ts
// BaseWidgetConfig is intentionally empty — a hook for future shared settings.
// Size and position are layout concerns stored as columns in dashboard_widgets,
// not as widget settings. They are handled by the dashboard, not the widget.
export interface BaseWidgetConfig {}

export interface TaskListConfig extends BaseWidgetConfig {
  showCompleted: boolean;
  projectId: string | null;
}

export const defaultTaskListConfig: TaskListConfig = {
  showCompleted: true,
  projectId: null,
};

export const taskListConfigFromJson = (json: Record<string, unknown>): TaskListConfig =>
  ({ ...defaultTaskListConfig, ...json });
```

**`meta.ts`** — registry metadata:

```ts
export const taskListMeta: WidgetMeta = {
  typeKey: 'task_list',
  displayName: 'Task List',
  icon: 'list',
  defaultConfig: defaultTaskListConfig,
  configFromJson: taskListConfigFromJson,
};
```

**`index.tsx`** — the React component:

```tsx
export const TaskListWidget: React.FC<{ config: TaskListConfig }> = ({ config }) => {
  const { data: entries, isLoading, isError } = useEntries();
  if (isLoading) return <WidgetSkeleton />;
  if (isError) return <WidgetError message="Could not load tasks" />;
  // render using config.showCompleted, config.projectId
};
```

### Central Registry

```ts
// widgetRegistry.ts
export const widgetRegistry: Record<string, WidgetDefinition> = {
  task_list:    { meta: taskListMeta,    Component: TaskListWidget    },
  calendar:     { meta: calendarMeta,    Component: CalendarWidget    },
  project_board:{ meta: projectBoardMeta, Component: ProjectBoardWidget },
};
```

**Adding a new widget:** create the folder, add one entry to the registry. Nothing else changes.

### Shared Data

Widgets do not fetch their own data. They call shared hooks:

```ts
const { data: entries } = useEntries();
const { data: projects } = useProjects();
```

TanStack Query deduplicates — if multiple widgets call `useEntries()`, one network request is made and the result is cached across all consumers.

---

## Data Layer

### Existing Tables

`entries`, `projects`, `categories`, and `recurrence_exceptions` carry over from Phase 1 (migration 001). The UI labels projects as "campaigns," but the table name is `projects`. Migration 002 adds `DEFAULT auth.uid()` to `user_id` columns so client inserts can omit it. No other schema changes.

### New Table — `dashboard_widgets` (migration 002)

```sql
CREATE TABLE dashboard_widgets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  type_key    TEXT NOT NULL,
  pos_x       INT NOT NULL DEFAULT 0,
  pos_y       INT NOT NULL DEFAULT 0,
  width       INT NOT NULL DEFAULT 4,
  height      INT NOT NULL DEFAULT 8,
  settings    JSONB NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_dashboard_widgets_user_id ON dashboard_widgets(user_id);

ALTER TABLE dashboard_widgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own widgets"
  ON dashboard_widgets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

`settings` stores widget-specific config (e.g. `{"showCompleted": true, "projectId": null}`). Layout position and size are top-level columns, not buried in the JSONB blob.

### TanStack Query Pattern

```ts
export const useEntries = () => useQuery({
  queryKey: ['entries'],
  queryFn: async () => {
    const { data, error } = await supabase.from('tasks').select('*');
    if (error) throw error;
    return data;
  },
});
```

Mutations use `useMutation` + `queryClient.invalidateQueries` to keep UI in sync after writes.

---

## Dashboard

### react-grid-layout Integration

The dashboard queries `dashboard_widgets`, maps rows to a layout array, and renders each widget via the registry:

```tsx
const layout = widgets.map(w => ({
  i: w.id,
  x: w.pos_x, y: w.pos_y,
  w: w.width,  h: w.height,
}));

<ReactGridLayout layout={layout} cols={12} rowHeight={40} onLayoutChange={handleLayoutChange}>
  {widgets.map(w => {
    const { Component } = widgetRegistry[w.type_key];
    const config = widgetRegistry[w.type_key].meta.configFromJson(w.settings);
    return <div key={w.id}><Component config={config} /></div>;
  })}
</ReactGridLayout>
```

### Layout Persistence

`onLayoutChange` fires on every drag/resize. A debounced mutation writes changed rows back to `dashboard_widgets`. No save button required.

### Add / Remove Widgets

- **Add:** "+ Add Widget" button opens a dialog listing all registered widget types from `widgetRegistry`. Selecting one inserts a new `dashboard_widgets` row with `meta.defaultConfig`. Query invalidates, widget appears.
- **Remove:** Each widget header has a remove button. Deletes the row, query invalidates, widget disappears.
- **Configure:** Each widget header has a settings button opening a dialog that edits the widget's typed config (fields per widget). Saves merge into the `settings` JSONB column. Without this, widget configs are stuck at defaults.

---

## Auth

Identical to Phase 1 intent: email/password + anonymous guest via Supabase Auth. `AuthContext` wraps the app, exposes `session` and `signOut`. Protected routes redirect to `/login` if no session. Google OAuth remains deferred pending Google Cloud Console setup.

---

## Theming

Tailwind custom tokens in `tailwind.config.js` carry over the tavern palette from Phase 1:

```js
colors: {
  oak:       '#3B1F0A',
  parchment: '#C8A96E',
  ember:     '#B5451B',
  iron:      '#4A4A4A',
},
fontFamily: {
  display: ['Cinzel', 'serif'],
  body:    ['Lora', 'serif'],
},
```

Wood textures and rustic surface treatments via CSS background-image assets, used alongside Tailwind utility classes.

---

## Error Handling

- Data errors handled per-widget via TanStack Query `isLoading` / `isError` states.
- Each widget renders its own `<WidgetSkeleton />` and `<WidgetError />` — no global spinner.
- Auth errors (expired session, network failure) caught in `AuthContext`, redirect to `/login`.
- No silent failures.

---

## Testing

| Layer | Tool | Scope |
|---|---|---|
| Unit | Vitest | Config `fromJson`/`toJson`, pure data transforms |
| Component | React Testing Library | Each widget renders correctly given mock config + mock query data |
| E2E | Deferred | Playwright/Cypress not worth setup cost for a personal app yet |

Widget isolation makes testing straightforward — each widget's hook dependencies are easily mocked.

---

## Widgets In Scope

| Widget | typeKey | Notes |
|---|---|---|
| Task List | `task_list` | Port from Flutter; config: showCompleted, projectId filter |
| Calendar | `calendar` | Port from Flutter; config: TBD (may be empty for now) |
| Project Board | `project_board` | Port from Flutter; config: TBD |

System is designed so adding a widget requires only: new folder + one registry entry.

---

## Out of Scope

- Reminders / notifications (deferred — web push needs a service worker + permission flow; revisit after core dashboard ships)
- Recurrence (deferred — `recurrence_exceptions` table and rrule logic exist server-side in schema only; the Dart `recurrence_engine` is not portable and will be reimplemented in TypeScript when scheduled entries land)
- Categories (table carries over but no UI/hooks until a widget needs it)
- Google OAuth (deferred — needs Google Cloud Console)
- Cloudflare Pages deployment (deferred to PR-to-main time)
- New widgets beyond the 3 above (Habit Tracker, Daily Reminder — separate tasks)
- E2E testing
- Android / React Native
