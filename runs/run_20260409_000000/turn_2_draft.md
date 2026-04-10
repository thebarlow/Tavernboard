# PROMPT.md — Tavernboard

## Mission Statement

Tavernboard is a web-first personal productivity dashboard built in Flutter/Dart, backed by Supabase, and deployed on Cloudflare Pages. It presents a warm rustic tavern aesthetic and provides a configurable grid of modular widgets covering calendar scheduling, task and project management, habit tracking, acting-career tooling, polls, and social event planning. It is designed to operate indefinitely at zero cost for fewer than five users while serving as a professional portfolio piece. All features are implemented across five strictly sequential phases; no phase may begin until the prior phase is fully deployed and verified.

---

## Architecture Overview

```
tavernboard/
├── lib/
│   ├── main.dart                        # App entry point, ProviderScope, router init
│   ├── app.dart                         # MaterialApp.router, theme injection
│   ├── router.dart                      # GoRouter routes + auth redirect guard
│   │
│   ├── theme/
│   │   └── tavern_theme.dart            # Full palette, text styles, component themes
│   │
│   ├── models/                          # Pure Dart data classes, fromJson/toJson
│   │   ├── user_profile.dart
│   │   ├── project.dart
│   │   ├── entry.dart
│   │   ├── category.dart
│   │   ├── recurrence_exception.dart
│   │   ├── widget_config.dart
│   │   ├── dashboard_layout.dart
│   │   ├── poll.dart
│   │   ├── poll_option.dart
│   │   ├── poll_vote.dart
│   │   ├── share_link.dart
│   │   ├── audition.dart
│   │   ├── callback.dart
│   │   ├── contact.dart
│   │   ├── group_event.dart
│   │   └── group_vote.dart
│   │
│   ├── services/
│   │   ├── supabase_client.dart         # Singleton Supabase client init
│   │   ├── auth_service.dart            # Sign-in, sign-out, session stream
│   │   ├── entry_service.dart           # CRUD for entries
│   │   ├── project_service.dart         # CRUD for projects
│   │   ├── category_service.dart        # CRUD for categories
│   │   ├── recurrence_engine.dart       # KEEP AS-IS — no modifications
│   │   ├── widget_config_service.dart   # Load/save widget configs per user
│   │   ├── dashboard_layout_service.dart# Load/save dashboard grid layout per user
│   │   ├── poll_service.dart            # CRUD for polls + vote submission
│   │   ├── share_link_service.dart      # Create/resolve/expire share links
│   │   ├── storage_service.dart         # Supabase Storage upload/download/delete
│   │   ├── audition_service.dart        # CRUD for auditions, callbacks, contacts
│   │   └── group_event_service.dart     # CRUD for group events + votes
│   │
│   ├── providers/                       # Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── entry_provider.dart
│   │   ├── project_provider.dart
│   │   ├── category_provider.dart
│   │   ├── dashboard_provider.dart
│   │   ├── poll_provider.dart
│   │   ├── share_link_provider.dart
│   │   ├── storage_provider.dart
│   │   ├── audition_provider.dart
│   │   └── group_event_provider.dart
│   │
│   ├── widgets/                         # Reusable UI primitives (not dashboard widgets)
│   │   ├── tavern_card.dart             # Styled card container used throughout
│   │   ├── tavern_button.dart
│   │   ├── tavern_text_field.dart
│   │   ├── tavern_dialog.dart
│   │   ├── tavern_snackbar.dart
│   │   └── loading_overlay.dart
│   │
│   ├── dashboard/
│   │   ├── dashboard_screen.dart        # Root dashboard: grid + sidebar
│   │   ├── dashboard_grid.dart          # Renders slot grid from layout config
│   │   ├── widget_slot.dart             # Single slot: resolves widget type + passes config
│   │   ├── widget_registry.dart         # Static registry: type string → builder function
│   │   ├── widget_config_editor.dart    # Generic config editor driven by widget schema
│   │   └── add_widget_dialog.dart       # Dialog to pick widget type + set initial config
│   │
│   ├── dashboard_widgets/               # Self-contained dashboard widget modules
│   │   ├── base_widget.dart             # Abstract class all dashboard widgets extend
│   │   ├── calendar_widget/
│   │   │   ├── calendar_widget.dart
│   │   │   └── calendar_widget_config.dart
│   │   ├── task_list_widget/
│   │   │   ├── task_list_widget.dart
│   │   │   └── task_list_widget_config.dart
│   │   ├── project_board_widget/
│   │   │   ├── project_board_widget.dart
│   │   │   └── project_board_widget_config.dart
│   │   ├── habit_tracker_widget/
│   │   │   ├── habit_tracker_widget.dart
│   │   │   └── habit_tracker_widget_config.dart
│   │   ├── daily_reminder_widget/
│   │   │   ├── daily_reminder_widget.dart
│   │   │   └── daily_reminder_widget_config.dart
│   │   ├── poll_widget/
│   │   │   ├── poll_widget.dart
│   │   │   └── poll_widget_config.dart
│   │   ├── audition_tracker_widget/
│   │   │   ├── audition_tracker_widget.dart
│   │   │   └── audition_tracker_widget_config.dart
│   │   ├── callback_log_widget/
│   │   │   ├── callback_log_widget.dart
│   │   │   └── callback_log_widget_config.dart
│   │   ├── script_viewer_widget/
│   │   │   ├── script_viewer_widget.dart
│   │   │   └── script_viewer_widget_config.dart
│   │   ├── contact_book_widget/
│   │   │   ├── contact_book_widget.dart
│   │   │   └── contact_book_widget_config.dart
│   │   ├── progress_meter_widget/
│   │   │   ├── progress_meter_widget.dart
│   │   │   └── progress_meter_widget_config.dart
│   │   ├── group_planner_widget/
│   │   │   ├── group_planner_widget.dart
│   │   │   └── group_planner_widget_config.dart
│   │   └── custom_chart_widget/
│   │       ├── custom_chart_widget.dart
│   │       └── custom_chart_widget_config.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── auth_callback_screen.dart   # OAuth redirect handler
│   │   ├── shared_view_screen.dart          # Public view for share links (no auth)
│   │   ├── poll_vote_screen.dart            # Public poll voting via share link
│   │   └── settings_screen.dart
│   │
│   └── utils/
│       ├── date_utils.dart
│       ├── color_utils.dart
│       └── validators.dart
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_widget_system.sql
│   │   ├── 003_sharing_polls.sql
│   │   ├── 004_acting_widgets.sql
│   │   └── 005_group_planning.sql
│   └── functions/
│       └── generate-share-link/
│           └── index.ts                 # Edge function: creates signed share URLs
│
├── test/
│   ├── unit/
│   │   ├── recurrence_engine_test.dart
│   │   ├── widget_registry_test.dart
│   │   ├── poll_service_test.dart
│   │   └── share_link_service_test.dart
│   └── widget/
│       ├── calendar_widget_test.dart
│       ├── task_list_widget_test.dart
│       └── login_screen_test.dart
│
├── web/
│   └── index.html                       # Flutter web entry (already exists, keep)
│
├── .env                                 # Never committed
├── .env.template
├── pubspec.yaml
├── ARCHITECTURE.md
└── CLAUDE.md
```

---

## Tech Stack

| Layer | Technology | Version | Reason |
|---|---|---|---|
| UI Framework | Flutter | 3.24.x (stable channel) | Already chosen; compiles to web + mobile from one codebase |
| Language | Dart | 3.5.x | Bundled with Flutter 3.24 |
| Auth + Database | Supabase | supabase_flutter ^2.5.0 | Free tier supports <5 users indefinitely; built-in RLS, auth, realtime |
| State Management | Riverpod | flutter_riverpod ^2.5.1 | Already chosen; code-gen optional but not required |
| Routing | go_router | ^14.2.0 | Standard Flutter web router; supports deep links for share URLs |
| File Storage | Supabase Storage | (included in supabase_flutter) | Same free tier; handles headshots, scripts, sides |
| PDF Viewer | pdfx | ^2.7.0 | flutter_pdfview does not support bytes loading on Flutter web — pdfx does via `PdfDocument.openData` — do not substitute |
| Serverless Functions | Supabase Edge Functions | Deno runtime | Share-link generation; free tier |
| Dashboard Grid | flutter_layout_grid | ^2.0.3 | CSS-grid-equivalent for Flutter; required for widget slot system — do not substitute with Wrap or GridView |
| Charts | fl_chart | ^0.68.0 | Habit tracker sparklines, custom chart widgets |
| Calendar UI | table_calendar | ^3.1.2 | Calendar widget base |
| File Viewer | flutter_pdfview | ^1.3.2 | Script/sides PDF viewing |
| Deployment | Cloudflare Pages | N/A | Already in CI; zero cost static host |
| Linting | flutter_lints | ^4.0.0 | Standard |

**Non-substitutable packages:** `flutter_layout_grid` (the widget slot system is designed around its API), `supabase_flutter` (all backend integration), `go_router` (share-link deep routing).

---

## Environment Configuration

All secrets are injected as environment variables at build time for Cloudflare Pages. Locally, use a `.env` file loaded via `--dart-define-from-file`.

### `.env.template`

```
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<anon-public-key>
SUPABASE_REDIRECT_URL=https://<your-cloudflare-domain>/auth/callback
```

### Access in Dart

```dart
// lib/services/supabase_client.dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

### `pubspec.yaml` flutter section — no flutter_dotenv

Do not use `flutter_dotenv`. All env vars are passed via `--dart-define-from-file=.env` at build and via Cloudflare Pages environment variables at deploy. This keeps secrets out of the compiled web bundle's asset manifest.

### Cloudflare Pages Build Command

```
flutter build web --dart-define-from-file=.env
```

Set `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_REDIRECT_URL` as environment variables in the Cloudflare Pages dashboard.

---

## Phase 1 — Foundation

**Complete this phase entirely before starting the next.**

### 1.1 Supabase Project Setup

1. Create a Supabase project. Enable email/password auth and Google OAuth provider in the Supabase dashboard under Authentication → Providers.
2. Set the OAuth redirect URL to `https://<your-domain>/auth/callback` in both the Supabase Auth settings and the Google Cloud Console OAuth app.
3. Run migration `001_initial_schema.sql` (see Data Models section).
4. Enable Row Level Security on all tables. Apply policies as specified per table.

### 1.2 Flutter Supabase Init

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const ProviderScope(child: TavernboardApp()));
}
```

Supabase.instance.client is accessed throughout via a provider, not a global. Define:

```dart
// lib/providers/auth_provider.dart
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseClientProvider).auth.onAuthStateChange,
);
```

### 1.3 Auth Screens

`login_screen.dart`: email/password form + "Sign in with Google" button. On Google tap, call `supabase.auth.signInWithOAuth(OAuthProvider.google, redirectTo: redirectUrl)`. The redirect URL must match exactly what is registered in Supabase and Google Console — a mismatch produces a silent failure with no error message.

`auth_callback_screen.dart`: mounted at `/auth/callback`. On `initState`, calls `supabase.auth.getSessionFromUrl(Uri.parse(currentUrl))`. This screen exists solely to capture the OAuth token from the URL fragment and hand it to the Supabase client. After session capture, navigate to `/dashboard`.

GoRouter auth redirect guard: if `authStateProvider` resolves to `AuthChangeEvent.signedOut` and the current route is not `/login` or `/auth/callback` or `/share/*`, redirect to `/login`.

### 1.4 Theme

Extend `lib/theme/tavern_theme.dart`. The full palette must be defined here — no hardcoded colors elsewhere in the app.

```
Primary background:   #2C1A0E   (dark oak)
Surface/card:         #3D2512   (medium walnut)
Elevated surface:     #4E3220   (lighter walnut)
Primary accent:       #C8860A   (amber candlelight)
Secondary accent:     #8B4513   (saddle brown)
Text primary:         #F5E6C8   (parchment)
Text secondary:       #C9A96E   (aged paper)
Divider/border:       #5C3D1E   (dark grain)
Error:                #C0392B
Success:              #27AE60
```

Typography: use Google Fonts `MedievalSharp` or `Cinzel` for headings, `Lora` for body text. These must be declared in `pubspec.yaml` under `google_fonts` or as bundled assets in `assets/fonts/`. Do not rely on system fonts.

`TavernCard`, `TavernButton`, `TavernTextField`, and `TavernDialog` must all draw from the theme and never declare their own colors.

### 1.5 Dashboard Shell (Phase 1 — Fixed Widgets)

In Phase 1 the dashboard is not yet configurable. Render three fixed widget slots in a responsive layout:
- Wide screen (≥1024px): 3-column grid
- Medium (≥600px): 2-column grid
- Narrow (<600px): 1-column stack

The three fixed widgets are: `CalendarWidget`, `TaskListWidget`, `ProjectBoardWidget`.

Each widget renders inside a `TavernCard`. The dashboard has a left sidebar (collapsible on mobile) containing nav links: Dashboard, Settings, and (Phase 4+) Acting Studio.

### 1.6 CRUD — Entries and Projects

Implement full create/read/update/delete for:
- **Entry** (tasks, events, deadlines): forms presented in `TavernDialog`
- **Project**: name, color picker (swatch of 8 preset tavern-palette colors), category, deadline

`entry_service.dart` and `project_service.dart` call Supabase PostgREST. All queries filter by `auth.uid()` — never fetch across users.

### 1.7 Phase 1 Verification Gate

Before moving to Phase 2, the following must be true:
- A new user can register, verify email, and reach the dashboard
- Google OAuth completes without error
- A task can be created, edited, marked complete, and deleted
- A project can be created and a task assigned to it
- The calendar widget renders events for the current month
- The deployed Cloudflare Pages URL redirects unauthenticated visitors to `/login`
- No hardcoded colors exist outside `tavern_theme.dart`

---

## Phase 2 — Widget System

**Complete this phase entirely before starting the next.**

### 2.1 Widget Registry

Every dashboard widget is identified by a string type key (e.g., `"calendar"`, `"task_list"`). The registry maps type keys to builder functions:

```dart
// lib/dashboard/widget_registry.dart
typedef WidgetBuilder = Widget Function(WidgetConfig config);

class WidgetRegistry {
  static final Map<String, WidgetBuilder> _registry = {};

  static void register(String typeKey, WidgetBuilder builder) {
    _registry[typeKey] = builder;
  }

  static Widget build(String typeKey, WidgetConfig config) {
    final builder = _registry[typeKey];
    if (builder == null) return const UnknownWidgetPlaceholder();
    return builder(config);
  }
}
```

Register all built-in widgets in `main.dart` before `runApp`. Each widget module exports a static `register()` method that calls `WidgetRegistry.register(...)`.

### 2.2 Widget Config Schema

Each widget declares its own config schema as a `List<ConfigField>`. A `ConfigField` has:
- `key` (String)
- `label` (String)
- `type` (enum: text, integer, boolean, color, enum, entry_list_ref)
- `defaultValue` (dynamic)
- `options` (List<String>? — used when type is enum)

`widget_config_editor.dart` reads this schema and renders the appropriate input for each field type. This drives the generic config UI without any widget needing to know about the editor.

### 2.3 Dashboard Layout Persistence

`DashboardLayout` is a list of `DashboardSlot` objects, each containing:
- `slotId` (String — UUID)
- `widgetTypeKey` (String)
- `gridColumn` (int)
- `gridRow` (int)
- `columnSpan` (int, default 1)
- `rowSpan` (int, default 1)
- `config` (Map<String, dynamic> — serialized widget config values)

The full layout is stored as a single JSONB column in the `dashboard_layouts` table, keyed by user_id. Load on login, save on any layout change (debounced 1 second — do not call Supabase on every drag event).

### 2.4 Built-in Widgets for Phase 2

Implement these five widgets (Calendar and Task List already exist from Phase 1 — wire them into the registry):

**CalendarWidget**: Monthly calendar view using `table_calendar`. Displays entries by date. Tap a date to open a day-detail drawer showing all entries. Tap an entry to edit.

**TaskListWidget**: Filterable list of Entry records where type = 'task'. Config fields: `filter_project_id` (entry_list_ref), `show_completed` (boolean, default false), `sort_order` (enum: due_date|created_at, default due_date).

**HabitTrackerWidget**: Tracks a named habit with a daily boolean check-in. Config fields: `habit_name` (text), `streak_goal` (integer, default 7). Stores check-ins as entries with type = 'habit_checkin' in the entries table, with the `title` field set to the habit name and `date` set to the check-in date. Renders a 7-day sparkline using `fl_chart`.

**DailyReminderWidget**: Displays a single configurable text reminder, optionally recurring. Config fields: `message` (text), `display_time` (text — HH:mm), `repeat` (enum: daily|weekdays|weekends|none), `dismissed_on` (text — ISO date string, e.g. "2026-04-09"). Widget shows the message and a dismiss button. On dismiss, write today's ISO date string into the `dismissed_on` config field and save. On widget load, compare `dismissed_on` to today's date: if they match, render the dismissed state; otherwise render the active reminder. This allows midnight reset without any scheduled logic — the date comparison is stateless and correct across page reloads.

**ProjectBoardWidget**: Kanban-style view grouping tasks by project. Columns are projects; cards are tasks. Config fields: `max_projects` (integer, default 5), `show_completed` (boolean, default false).

### 2.5 Phase 2 Verification Gate

- User can add a HabitTrackerWidget to the dashboard from the add-widget dialog
- Widget config editor opens, user sets habit name and goal, saves
- Layout change persists after page reload
- All five widget types render without errors
- An unknown widget type key renders `UnknownWidgetPlaceholder` without crashing

---

## Phase 3 — Sharing & Polls

**Complete this phase entirely before starting the next.**

### 3.1 Share Links

Share links allow unauthenticated users to view or interact with a specific artifact (a poll, a project, a task list). A share link is a UUID-based token stored in the `share_links` table with:
- The target resource type and ID
- Permission level (view | vote | edit)
- Expiry timestamp (nullable — null = no expiry)
- Creator user_id

The Supabase Edge Function `generate-share-link/index.ts` is the only code that writes to the `share_links` table. It validates the caller is authenticated (checks the Authorization header against Supabase JWT), generates a UUID token, inserts the row, and returns the full URL in the form `https://<domain>/share/<token>`.

The Flutter route `/share/:token` maps to `SharedViewScreen`, which calls `share_link_service.dart` to resolve the token. If expired, display a `TavernCard` with an "This invitation has expired" message. If valid, render the appropriate read-only or interactive view.

### 3.2 Poll Widget

A poll has a question, 2–6 options, an optional expiry, and a creator. It is created by the owner via `PollWidget` in their dashboard. Once created, the owner copies a share link.

`PollVoteScreen` is the public-facing screen (no auth required). It shows the question and options. A voter identifies themselves by entering a display name (stored locally in localStorage, not in a user account). One vote per browser session per poll (enforced by storing a `voted_polls` key in `window.localStorage` — no server-side dedup needed at this scale).

Results are shown live (via Supabase Realtime `poll_votes` table subscription) as a horizontal bar chart using `fl_chart`.

Config fields for `PollWidget`: `poll_id` (links to an existing poll created by the user).

### 3.3 User-to-User Sharing

An owner can invite another user by email address via a share invitation. The system:
1. Owner submits an email + permission level (view | edit) via the settings screen
2. `share_link_service.dart` inserts a row into `collaborators` with status = 'pending'
3. The invited user, upon next login, sees a banner: "You have a pending collaboration invite from [owner]"
4. Accepting the invite sets `status = 'accepted'`; rejecting sets `status = 'rejected'`
5. A collaborator with 'view' permission can read the owner's public data; 'edit' can also write entries

RLS policies on the `entries`, `projects`, and `categories` tables must check the `collaborators` table as well as `auth.uid()`. The policy pattern is:

```sql
-- entries SELECT policy
CREATE POLICY "entries_select" ON entries
  FOR SELECT USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM collaborators
      WHERE collaborators.owner_id = entries.user_id
        AND collaborators.collaborator_id = auth.uid()
        AND collaborators.status = 'accepted'
    )
  );
```

### 3.4 Phase 3 Verification Gate

- Owner creates a poll, copies share link, opens it in a private/incognito window without signing in
- Visitor sees the poll, submits a vote, results bar chart updates in real time in the owner's browser
- Owner invites a second user account by email; second user accepts; second user can view owner's task list
- An expired share link shows the expiry message, not an error page

---

## Phase 4 — Acting Widgets & Storage

**Complete this phase entirely before starting the next.**

### 4.1 Supabase Storage Setup

Create one Storage bucket named `user-files`. Enable RLS. Policy: a user may only read/write/delete objects whose path begins with `{auth.uid()}/`. Path structure: `{user_id}/{resource_type}/{filename}` (e.g., `abc123/headshots/jane_doe_2024.jpg`).

`storage_service.dart` methods:
- `uploadFile(String bucket, String path, Uint8List bytes, String mimeType) → String` — returns public URL
- `downloadFile(String bucket, String path) → Uint8List`
- `deleteFile(String bucket, String path) → void`
- `listFiles(String bucket, String prefix) → List<FileObject>`

### 4.2 Audition Tracker Widget

Tracks auditions with fields: role, project, casting_director, date, location, notes, status (enum: scheduled|completed|callback|booked|passed). Supports filter by status and sort by date.

**AuditionTrackerWidget** renders a sortable, filterable table. Add/edit via `TavernDialog`. Config fields: `default_status_filter` (enum: all|scheduled|callback|booked, default all).

### 4.3 Callback Log Widget

A callback is linked to an audition. Fields: audition_id, callback_date, notes, outcome (enum: pending|booked|passed). **CallbackLogWidget** renders linked pairs (audition → callback) with outcome status pills.

### 4.4 Script/Sides Viewer Widget

Allows the actor to upload PDF files (sides, full scripts) and view them in-app. Upload stores the file in Supabase Storage under `{user_id}/scripts/{filename}`. The widget renders a file picker list; selecting a file opens a full-screen overlay using `pdfx`. Config fields: `default_folder` (text, default "scripts").

Use `pdfx` for PDF rendering on all platforms including web. Load the file bytes from Supabase Storage via `storage_service.dart`, then open with `PdfDocument.openData(bytes)`. Do not use `flutter_pdfview` — it lacks a working bytes constructor on Flutter web. If the file exceeds 20 MB, show a warning dialog before initiating the download.

### 4.5 Agent/Contact Book Widget

Stores contacts relevant to the acting career: agents, casting directors, managers, coaches. Fields: name, role (enum: agent|casting_director|manager|coach|other), agency, email, phone, notes. **ContactBookWidget** renders a searchable card list. Config fields: `default_role_filter` (enum: all|agent|casting_director|..., default all).

### 4.6 Progress Meter Widget

A configurable progress bar that the user links to a data source. Config fields:
- `label` (text)
- `source_type` (enum: task_completion|manual|counter)
- `source_id` (String — project_id if task_completion, or a named counter key)
- `goal_value` (integer — used when source_type = counter or manual)
- `current_value` (integer — used when source_type = manual or counter; stored in widget config)
- `color` (color)

When `source_type = task_completion`, the widget queries the linked project's tasks and computes `completed / total` automatically.

### 4.7 Phase 4 Verification Gate

- Actor user uploads a headshot; it appears in the file list under storage
- Actor user creates an audition; it appears in AuditionTrackerWidget
- Actor user links an audition to a callback; CallbackLogWidget shows the pair
- Actor user uploads a PDF script; it opens in the viewer overlay without errors
- ProgressMeterWidget linked to a project reflects correct completion %

---

## Phase 5 — Social Planning & Custom Widgets

**Complete this phase entirely before starting the next.**

### 5.1 Group Planner Widget

Allows one user to propose an event and solicit input from others. Flow:
1. Organizer creates a `group_event` with a title, description, and 2–5 proposed time slots
2. System generates a share link for the event (same mechanism as Phase 3)
3. Participants open the link, enter a display name, and vote on their preferred time slot(s) (multi-select)
4. Organizer's `GroupPlannerWidget` shows a consensus view: each slot ranked by vote count
5. Organizer confirms one slot; event is marked `confirmed` and displays the chosen time

`GroupPlannerWidget` config fields: `event_id` (links to a group_event).

### 5.2 User-Defined Widget Builder

A UI-driven tool for building simple display widgets without code. Accessible from the add-widget dialog via "Build Custom Widget." Supports three widget types:

**Counter**: displays a named integer counter with + / - buttons. Config: `label`, `step` (integer, default 1), `min`, `max`.

**Progress Bar**: manually set current and goal values. Config: `label`, `goal_value`, `current_value`, `bar_color`.

**Chart**: renders a bar or pie chart from a manually entered dataset. Config: `chart_type` (enum: bar|pie), `title`, `data_points` (List of {label: string, value: number} — edited in the config editor as a JSON text field, validated on save).

Custom widget definitions are stored in the `custom_widget_definitions` table with a JSONB `schema` column. When instantiated, they follow the same `WidgetRegistry` path as built-in widgets, using the type key `"custom:{definition_id}"`.

### 5.3 Plugin API

The plugin API is a documented Dart interface, not a runtime plugin loader. It defines the contract that a power user (developer) would implement to add a new widget to the registry.

Document in `ARCHITECTURE.md`:

```dart
// The contract a custom plugin widget must satisfy:
abstract class TavernWidget extends StatelessWidget {
  const TavernWidget({required this.config, super.key});
  final WidgetConfig config;

  // Declare the config schema for the generic config editor
  static List<ConfigField> get schema => [];

  // Called by WidgetRegistry.register — must be called in main.dart
  static void register() {}
}
```

Document: to add a plugin widget, implement `TavernWidget`, call `WidgetRegistry.register('my_type', (config) => MyWidget(config: config))` in `main.dart`, and add its schema to the registry's schema map. No hot-reload or dynamic loading — the app must be rebuilt.

### 5.4 Phase 5 Verification Gate

- Organizer creates group event with 3 time slots; shares link; two participants vote from different browsers
- Consensus view updates live as votes come in
- Organizer confirms a slot; widget updates to show confirmed time
- User builds a Counter widget via the UI; it increments correctly on the dashboard
- User builds a Bar Chart with 4 data points; it renders correctly

---

## Data Models

### SQL Migration 001 — Initial Schema

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL
);
CREATE INDEX idx_categories_user_id ON categories(user_id);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_owner" ON categories
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Projects
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#C8860A',
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  deadline TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_category_id ON projects(category_id);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "projects_owner" ON projects
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Entries (tasks, events, deadlines, habits)
CREATE TABLE entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  type TEXT NOT NULL CHECK (type IN ('task','event','deadline','habit','habit_checkin')),
  title TEXT NOT NULL,
  description TEXT,
  date DATE,
  start_time TIME,
  end_time TIME,
  color_override TEXT,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  reminder_time TIMESTAMPTZ,
  recurrence_rule TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_entries_user_id ON entries(user_id);
CREATE INDEX idx_entries_project_id ON entries(project_id);
CREATE INDEX idx_entries_date ON entries(date);
CREATE INDEX idx_entries_type ON entries(type);

ALTER TABLE entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "entries_owner" ON entries
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Recurrence exceptions
CREATE TABLE recurrence_exceptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
  original_date DATE NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('skip','reschedule')),
  new_date DATE
);
CREATE INDEX idx_recurrence_exceptions_entry_id ON recurrence_exceptions(entry_id);

ALTER TABLE recurrence_exceptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "recurrence_exceptions_owner" ON recurrence_exceptions
  USING (
    EXISTS (SELECT 1 FROM entries WHERE entries.id = entry_id AND entries.user_id = auth.uid())
  );
```

### SQL Migration 002 — Widget System

```sql
CREATE TABLE dashboard_layouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  layout JSONB NOT NULL DEFAULT '[]'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE dashboard_layouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "dashboard_layouts_owner" ON dashboard_layouts
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

### SQL Migration 003 — Sharing & Polls

```sql
CREATE TABLE share_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  token UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  resource_type TEXT NOT NULL,  -- 'poll' | 'project' | 'task_list' | 'group_event'
  resource_id UUID NOT NULL,
  permission TEXT NOT NULL CHECK (permission IN ('view','vote','edit')),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_share_links_token ON share_links(token);
CREATE INDEX idx_share_links_creator_id ON share_links(creator_id);

ALTER TABLE share_links ENABLE ROW LEVEL SECURITY;
-- Only edge function (service role key) may insert; anyone may select by token
CREATE POLICY "share_links_read_by_token" ON share_links
  FOR SELECT USING (true);
CREATE POLICY "share_links_owner_delete" ON share_links
  FOR DELETE USING (creator_id = auth.uid());

CREATE TABLE polls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_polls_creator_id ON polls(creator_id);
ALTER TABLE polls ENABLE ROW LEVEL SECURITY;
CREATE POLICY "polls_owner" ON polls USING (creator_id = auth.uid()) WITH CHECK (creator_id = auth.uid());
CREATE POLICY "polls_public_read" ON polls FOR SELECT USING (true);

CREATE TABLE poll_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0
);
ALTER TABLE poll_options ENABLE ROW LEVEL SECURITY;
CREATE POLICY "poll_options_public_read" ON poll_options FOR SELECT USING (true);
CREATE POLICY "poll_options_owner_write" ON poll_options
  USING (EXISTS (SELECT 1 FROM polls WHERE polls.id = poll_id AND polls.creator_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM polls WHERE polls.id = poll_id AND polls.creator_id = auth.uid()));

CREATE TABLE poll_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poll_id UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  option_id UUID NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE,
  voter_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_poll_votes_poll_id ON poll_votes(poll_id);
ALTER TABLE poll_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "poll_votes_public_insert" ON poll_votes FOR INSERT WITH CHECK (true);
CREATE POLICY "poll_votes_public_read" ON poll_votes FOR SELECT USING (true);

CREATE TABLE collaborators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  collaborator_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  invited_email TEXT NOT NULL,
  permission TEXT NOT NULL CHECK (permission IN ('view','edit')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_collaborators_owner_id ON collaborators(owner_id);
CREATE INDEX idx_collaborators_collaborator_id ON collaborators(collaborator_id);
ALTER TABLE collaborators ENABLE ROW LEVEL SECURITY;
CREATE POLICY "collaborators_owner_manage" ON collaborators
  USING (owner_id = auth.uid() OR collaborator_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());
```

Update entries, projects, categories SELECT policies to include collaborator check (see Phase 3.3 SQL pattern above).

### SQL Migration 004 — Acting Widgets

```sql
CREATE TABLE auditions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  project TEXT,
  casting_director TEXT,
  date DATE,
  location TEXT,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled','completed','callback','booked','passed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_auditions_user_id ON auditions(user_id);
CREATE INDEX idx_auditions_status ON auditions(status);
ALTER TABLE auditions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "auditions_owner" ON auditions USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE TABLE callbacks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  audition_id UUID NOT NULL REFERENCES auditions(id) ON DELETE CASCADE,
  callback_date DATE,
  notes TEXT,
  outcome TEXT NOT NULL DEFAULT 'pending' CHECK (outcome IN ('pending','booked','passed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_callbacks_user_id ON callbacks(user_id);
CREATE INDEX idx_callbacks_audition_id ON callbacks(audition_id);
ALTER TABLE callbacks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "callbacks_owner" ON callbacks USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE TABLE contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('agent','casting_director','manager','coach','other')),
  agency TEXT,
  email TEXT,
  phone TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_contacts_user_id ON contacts(user_id);
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "contacts_owner" ON contacts USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
```

### SQL Migration 005 — Group Planning

```sql
CREATE TABLE group_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','confirmed','cancelled')),
  confirmed_slot_id UUID,  -- FK set after confirmation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_group_events_organizer_id ON group_events(organizer_id);
ALTER TABLE group_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "group_events_public_read" ON group_events FOR SELECT USING (true);
CREATE POLICY "group_events_organizer_write" ON group_events
  USING (organizer_id = auth.uid())
  WITH CHECK (organizer_id = auth.uid());

CREATE TABLE group_event_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES group_events(id) ON DELETE CASCADE,
  proposed_time TIMESTAMPTZ NOT NULL,
  label TEXT
);
ALTER TABLE group_event_slots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "slots_public_read" ON group_event_slots FOR SELECT USING (true);
CREATE POLICY "slots_organizer_write" ON group_event_slots
  USING (EXISTS (SELECT 1 FROM group_events WHERE group_events.id = event_id AND group_events.organizer_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM group_events WHERE group_events.id = event_id AND group_events.organizer_id = auth.uid()));

-- Add FK back on group_events after slots table exists
ALTER TABLE group_events ADD CONSTRAINT fk_confirmed_slot
  FOREIGN KEY (confirmed_slot_id) REFERENCES group_event_slots(id) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE group_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES group_events(id) ON DELETE CASCADE,
  slot_id UUID NOT NULL REFERENCES group_event_slots(id) ON DELETE CASCADE,
  voter_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_group_votes_event_id ON group_votes(event_id);
ALTER TABLE group_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "group_votes_public_insert" ON group_votes FOR INSERT WITH CHECK (true);
CREATE POLICY "group_votes_public_read" ON group_votes FOR SELECT USING (true);

CREATE TABLE custom_widget_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  widget_type TEXT NOT NULL CHECK (widget_type IN ('counter','progress_bar','chart')),
  schema JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_custom_widget_definitions_user_id ON custom_widget_definitions(user_id);
ALTER TABLE custom_widget_definitions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "custom_widgets_owner" ON custom_widget_definitions
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
```

---

## Dart Model Classes

All models live in `lib/models/`. Every model implements `fromJson(Map<String, dynamic>)` and `toJson() → Map<String, dynamic>`. No code generation required — write these by hand. Do not use `json_serializable` unless the developer prefers it; if used, pin to `^6.8.0` and add `build_runner ^2.4.0` to dev_dependencies.

Key model fields not listed in the SQL but required in Dart:
- `WidgetConfig`: `slotId` (String), `widgetTypeKey` (String), `values` (Map<String, dynamic>)
- `DashboardLayout`: `slots` (List<DashboardSlot>)
- `DashboardSlot`: `slotId`, `widgetTypeKey`, `gridColumn`, `gridRow`, `columnSpan`, `rowSpan`, `config` (WidgetConfig)
- `ShareLink`: `token` (String), `resourceType` (String), `resourceId` (String), `permission` (String), `expiresAt` (DateTime?)

---

## Supabase Edge Function — generate-share-link

```typescript
// supabase/functions/generate-share-link/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return new Response("Unauthorized", { status: 401 });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Verify the caller's JWT
  const { data: { user }, error: authError } = await supabase.auth.getUser(
    authHeader.replace("Bearer ", "")
  );
  if (authError || !user) return new Response("Unauthorized", { status: 401 });

  const { resourceType, resourceId, permission, expiresIn } = await req.json();

  const { data, error } = await supabase
    .from("share_links")
    .insert({
      creator_id: user.id,
      resource_type: resourceType,
      resource_id: resourceId,
      permission,
      expires_at: expiresIn
        ? new Date(Date.now() + expiresIn * 1000).toISOString()
        : null,
    })
    .select("token")
    .single();

  if (error) return new Response(error.message, { status: 500 });

  const appUrl = Deno.env.get("APP_URL")!;
  return Response.json({ url: `${appUrl}/share/${data.token}` });
});
```

Set `APP_URL` and `SUPABASE_SERVICE_ROLE_KEY` as Supabase Edge Function secrets — never expose the service role key to the Flutter client.

---

## API / Interface Contracts

All data access goes through Supabase PostgREST. There is no custom REST API. The contracts below define the Flutter service method signatures and their expected Supabase operations.

### auth_service.dart

```dart
Future<void> signInWithEmail(String email, String password);
Future<void> signUpWithEmail(String email, String password);
Future<void> signInWithGoogle();
Future<void> signOut();
Stream<AuthState> get authStateStream;
User? get currentUser;
```

### entry_service.dart

```dart
Future<List<Entry>> getEntries({String? projectId, String? type, DateTimeRange? range});
Future<Entry> createEntry(Entry entry);
Future<Entry> updateEntry(Entry entry);
Future<void> deleteEntry(String id);
```

All methods throw `PostgrestException` on failure. Callers (providers) catch and expose error state to the UI. Do not swallow exceptions silently.

### dashboard_layout_service.dart

```dart
Future<DashboardLayout> loadLayout(String userId);
Future<void> saveLayout(String userId, DashboardLayout layout);
```

`saveLayout` performs an upsert on `dashboard_layouts` by user_id. It is always called through a 1-second debounce wrapper in `dashboard_provider.dart` — never called directly from widget code.

### poll_service.dart

```dart
Future<Poll> createPoll(String question, List<String> options, DateTime? expiresAt);
Future<Poll> getPoll(String pollId);
Future<void> submitVote(String pollId, String optionId, String voterName);
Stream<List<PollVote>> watchVotes(String pollId);
```

`watchVotes` uses Supabase Realtime: `supabase.from('poll_votes').stream(primaryKey: ['id']).eq('poll_id', pollId)`.

### share_link_service.dart

```dart
Future<String> createShareLink({
  required String resourceType,
  required String resourceId,
  required String permission,
  int? expiresInSeconds,
});
Future<ShareLink?> resolveToken(String token);
```

`createShareLink` calls the `generate-share-link` edge function via `supabase.functions.invoke(...)`. `resolveToken` queries the `share_links` table and returns null if expired or not found.

---

## Non-Obvious Constraints

1. **Flutter web OAuth redirect**: `signInWithOAuth` opens a new tab on web. The app must listen for the auth state change on the original tab, not the redirect tab. Supabase handles this automatically via `onAuthStateChange` if the redirect URL is correctly set. Do not write custom redirect handling — trust the Supabase SDK.

2. **`--dart-define-from-file` does not work with `flutter test`**: For unit tests requiring env vars, either mock the Supabase client entirely or pass `--dart-define` individually. Do not attempt to load a `.env` file at runtime.

3. **flutter_layout_grid column/row definitions**: `WidgetRegistry` slot positions use 1-based column/row indices matching CSS Grid. flutter_layout_grid uses the same convention. However, a slot with `columnSpan: 2` starting at column 1 occupies columns 1 and 2 — it does not wrap. The grid template must declare enough tracks to accommodate the widest slot. Always define the grid template from the layout data before rendering slots.

4. **Supabase Realtime on free tier**: The free tier supports up to 200 concurrent Realtime connections. For this app (<5 users), this is not a concern. However, do not open more than one Realtime subscription per screen — unsubscribe in `dispose()`. Leaving orphaned subscriptions will accumulate and eventually hit the channel limit.

5. **`table_calendar` and DST**: `table_calendar` uses `DateTime` objects. If a user is in a DST-affected timezone, midnight `DateTime` values will shift. Always use `DateTime.utc(year, month, day)` when creating date-only values for calendar display, and convert to local only for display strings.

6. **Supabase Storage on web**: `flutter_pdfview` requires the file bytes, not a URL. On web, use `storage_service.dart`'s `downloadFile` to fetch bytes, then pass to `flutter_pdfview`. Do not use `url_launcher` to open Storage URLs directly — they are signed and expire.

7. **GoRouter and Supabase auth on web**: On hard page refresh, `Supabase.initialize()` must complete before `GoRouter` evaluates the redirect guard. Use a `FutureProvider` for the initialization state and gate the router's `redirect` on it. Without this, authenticated users are redirected to `/login` on every refresh.

8. **RLS on `collaborators` and performance**: At <5 users the collaborator subquery in every RLS policy is fast. If this app ever scales, these policies must be replaced with materialized views or cached permission rows. Document this in `ARCHITECTURE.md`.

9. **`fl_chart` version lock**: `fl_chart ^0.68.0` has breaking API changes from 0.66.x. Do not upgrade without auditing the chart widget code. The `BarChartGroupData` constructor signature changed in 0.67.

10. **Edge Function cold starts**: The `generate-share-link` function on the Supabase free tier may have a cold start delay of 1–3 seconds. Show a loading indicator in the share-link dialog while the function call is in flight. Do not assume it is instant.

11. **Collaborator email-to-ID resolution**: When an owner invites a user by email, `collaborators.collaborator_id` is NULL at insert time (the invited user may not yet exist in `auth.users`). On every login, `auth_service.dart` must run a resolution step: query `collaborators` where `invited_email = currentUser.email AND status = 'pending' AND collaborator_id IS NULL`, and update those rows to set `collaborator_id = currentUser.id`. This must happen before the dashboard loads. Without this step, RLS policies that check `collaborator_id = auth.uid()` will never match for newly registered invited users.

12. **`pdfx` on Flutter web requires `canvaskit` renderer**: The `pdfx` package on Flutter web requires the CanvasKit renderer, not the HTML renderer. Ensure the build command uses `--web-renderer canvaskit` (or omit the flag — CanvasKit is the default in Flutter 3.22+). If the HTML renderer is used, `pdfx` will throw an unsupported platform error at runtime.

---

## Auth & Security

- **Session storage**: Supabase Flutter SDK stores the session in `localStorage` on web. This is the standard approach. Do not implement custom session storage.
- **Token refresh**: The Supabase SDK auto-refreshes the access token before expiry. No manual refresh logic is required.
- **Service role key**: Never included in Flutter code or build artifacts. Only used in the Edge Function runtime environment.
- **RLS enforcement**: Every table has RLS enabled. Every service method queries through the Supabase anon key. The anon key is safe to expose in the Flutter client because RLS prevents cross-user data access.
- **Share link security**: Share link tokens are UUIDs (128 bits of entropy). Brute-force is not a realistic threat. Expiry is the primary access control. Do not add additional security layers at this scale.
- **Google OAuth**: The only redirect URL registered in Google Cloud Console is the production Cloudflare Pages domain plus `/auth/callback`. For local dev, add `http://localhost:8080/auth/callback` as an additional authorized redirect URI in the Google Console.

---

## Error Handling & Edge Cases

- All `PostgrestException` errors from service methods are caught in the corresponding Riverpod provider and exposed as `AsyncError` states.
- UI screens use `AsyncValue.when(data:, loading:, error:)` pattern from Riverpod. The `error` case always renders a `TavernSnackbar` with a human-readable message derived from the exception — never the raw Supabase error string.
- If `dashboard_layout_service.loadLayout` returns no row (new user), return `DashboardLayout` with three default slots: Calendar (col 1), TaskList (col 2), ProjectBoard (col 3).
- If `WidgetRegistry.build` receives an unregistered type key, render `UnknownWidgetPlaceholder` — a `TavernCard` with the text "Widget type not found: {typeKey}" and a remove button.
- If a share link token is not found in the database, `shared_view_screen.dart` renders a `TavernCard` with "This link is invalid or has been removed."
- File uploads in `storage_service.dart` that exceed the Supabase free tier storage limit (1 GB) will return a Supabase error — catch and display "Storage limit reached."
- Poll vote submission failures (e.g., network error) must not silently lose the vote. Show an error and allow retry. Do not mark the poll as voted in `localStorage` until the server insert succeeds.

---

## Testing Strategy

### `test/unit/recurrence_engine_test.dart`
Tests the existing `recurrence_engine.dart` logic. Cover: daily recurrence generation, weekly with specific days, monthly, exception skipping, exception rescheduling, boundary at end of month.

### `test/unit/widget_registry_test.dart`
Tests `WidgetRegistry.register` and `WidgetRegistry.build`. Cover: registration of a mock widget, build with registered key returns widget, build with unregistered key returns `UnknownWidgetPlaceholder`, re-registration overwrites previous.

### `test/unit/poll_service_test.dart`
Mock the Supabase client. Cover: `createPoll` inserts correct rows, `submitVote` inserts correct vote row, `getPoll` returns expected poll, expired poll's `expiresAt` is in the past.

### `test/unit/share_link_service_test.dart`
Mock Supabase functions invocation. Cover: `createShareLink` calls edge function with correct parameters, `resolveToken` returns null for expired token, `resolveToken` returns `ShareLink` for valid token.

### `test/widget/login_screen_test.dart`
Pump `LoginScreen` with mocked `authStateProvider`. Cover: email and password fields render, sign-in button triggers `auth_service.signInWithEmail`, Google button renders, error state shows `TavernSnackbar`.

### `test/widget/calendar_widget_test.dart`
Pump `CalendarWidget` with mocked `entryProvider`. Cover: current month renders without errors, days with entries display indicators, tapping a date opens the day detail drawer.

### `test/widget/task_list_widget_test.dart`
Pump `TaskListWidget` with mocked entries. Cover: tasks render in list, completed tasks are hidden when `show_completed = false`, tapping a task opens edit dialog.

Run tests with: `flutter test`. All tests must pass before any phase gate is declared complete.

---

## Deployment

### Local Development

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=.env
```

For the Edge Function locally:
```bash
supabase start
supabase functions serve generate-share-link --env-file .env.local
```

### Cloudflare Pages (already configured in CI)

Build command: `flutter build web --dart-define-from-file=.env`
Output directory: `build/web`

Environment variables to set in Cloudflare Pages dashboard:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_REDIRECT_URL`

The GitHub Actions workflow at `.github/workflows/` already handles the build and deploy trigger on push to `main`. Do not modify the workflow unless the build command changes.

### Supabase Edge Function Deployment

```bash
supabase functions deploy generate-share-link
supabase secrets set APP_URL=https://<your-domain>
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
```

---

## Must-Haves vs Nice-to-Haves

### Must-Haves (implement in the phase specified — do not defer)
- Supabase auth (email/password + Google OAuth) — Phase 1
- Dashboard shell with Calendar, Task List, Project Board — Phase 1
- Full CRUD for entries and projects — Phase 1
- Tavern theme fully applied — Phase 1
- Cloudflare Pages deploy behind login — Phase 1
- Widget registry and configurable dashboard grid — Phase 2
- Habit Tracker, Daily Reminder widgets — Phase 2
- Layout persistence per user — Phase 2
- Shareable poll with public vote link — Phase 3
- User-to-user sharing with view/edit permissions — Phase 3
- Supabase Storage for file uploads — Phase 4
- Audition Tracker, Callback Log, Script Viewer, Contact Book widgets — Phase 4
- Progress Meter widget — Phase 4
- Group event planner with voting — Phase 5
- Counter, Progress Bar, Chart user-defined widgets — Phase 5

### Nice-to-Haves (implement only if phase is complete and time permits)
- Push/email reminders via Edge Functions
- Mobile-optimized breakpoints beyond basic Flutter web responsive layout
- Additional chart types (line, doughnut) in custom chart widget
- Drag-to-reorder within the dashboard grid
- Dark/light theme toggle (rustic dark is the default and only required theme)
- Export audition data to CSV

---

## Key Dependencies (pinned)

```yaml
# pubspec.yaml dependencies
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  flutter_layout_grid: ^2.0.3
  fl_chart: ^0.68.0
  table_calendar: ^3.1.2
  pdfx: ^2.7.0
  google_fonts: ^6.2.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.9
```

Do not upgrade any pinned package without verifying the changelog for breaking changes. `fl_chart` and `flutter_layout_grid` in particular have a history of breaking API changes in minor versions.
