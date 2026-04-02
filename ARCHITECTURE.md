# Tavernboard — Architecture Spec

## Summary
A personal productivity app integrating calendar, quest log (to-do), and campaign (project) management into a single platform. Built for a single user managing creative endeavors, professional obligations, and daily life. v1 is live on Android + Web with local Hive storage. v2 adds Supabase cloud sync. v3 adds iOS.

## Classification
- **Type**: Personal productivity app (mobile + web first)
- **Interface**: Flutter (cross-platform: Android + Web → iOS later)
- **Persistence**: Hive/IndexedDB (v1, local) → Supabase cloud (v2+)

## Roadmap
| Version | Platforms | Data | Status |
|---|---|---|---|
| v1 | Android + Web | Hive (local) | ✅ Live at tavernboard.matthewbarlow.me |
| v2 | Android + Web | Supabase (cloud sync) | Planned — data loss risk with local storage |
| v3 | + iOS | Supabase | Requires Mac or Codemagic CI for iOS build |
| v4 | + Windows desktop | Supabase | Deferred |

## Go/No-Go Score
| Axis | Score (1–5) |
|---|---|
| Effort | 4 |
| Income potential | 1 |
| Portfolio value | 3 |
| Strategic fit | 2 |
| **Payoff / Threshold** | 6 vs 8 — below threshold, proceeding by user decision |

## Stack
| Layer | Choice | Reason |
|---|---|---|
| Language | Dart | Flutter's language, readable for Python developers |
| Framework | Flutter | Cross-platform: one codebase for Android, Web, iOS, desktop |
| Storage (v1) | hive_flutter | Works on Android, Web, iOS, desktop; no server needed |
| Storage (v2+) | supabase_flutter | Cloud sync, replaces Hive |
| State mgmt | Riverpod | Type-safe, testable, scales well |
| Notifications (web) | Browser Notification API (package:web) | Works in Chrome/Firefox/Safari; fires while tab is open |
| Notifications (Android) | flutter_local_notifications | Deferred to v2 |
| Recurrence | Custom RecurrenceEngine | Daily/weekly/monthly; complex rrules deferred |
| Testing | flutter_test | Unit tests for core logic (pending) |
| Deployment (v1) | Cloudflare Pages (web) + sideloaded APK (Android) | GitHub Actions builds Flutter, Cloudflare serves web |
| Deployment (v2+) | + TestFlight via Codemagic CI | For iOS |

## Components
- **CalendarScreen**: Monthly grid view (home — "Chronicle" tab). Tap a day to expand detail showing all entries. Primary entry point for adding items.
- **TodoScreen**: Filtered/grouped task list ("Quest Log" tab). Sections: Today's Adventures, Upcoming Quests, Standing Orders. Filter by campaign and category.
- **ProjectsScreen**: List of campaigns with task counts and deadlines ("Campaigns" tab). Tap to expand into campaign detail.
- **AddEntrySheet**: Bottom sheet modal for creating Task/Event/Deadline. Opened from calendar or contextually from other screens.
- **NotificationService**: Web — uses Browser Notification API, checks due reminders every minute via timer. Android — stub (flutter_local_notifications deferred to v2).
- **RecurrenceEngine**: Generates occurrences from recurrence rules. Handles daily/weekly/monthly with skip/reschedule exceptions.
- **DatabaseService**: Hive CRUD operations. Same public interface will be preserved when migrating to Supabase.
- **StateLayer (Riverpod)**: Providers for projects, entries, categories, and UI state.
- **TavernTheme**: Medieval tavern visual design — parchment/wood palette, serif fonts, gem project colors, gold accents.

## Data Model (key entities)

- **Project (Campaign)**: id, name, color (gem palette), category_id (FK), deadline (optional), created_at
- **Entry**: id, project_id (FK), type (task|event|deadline), title, description, date (optional for tasks), start_time, end_time, color_override (nullable), is_completed, reminder_minutes (nullable, null = do not remind), recurrence_rule (nullable), created_at
- **Category**: id, name (user-defined: "Acting", "YouTube", "Chores", etc.)
- **RecurrenceException**: id, entry_id (FK), original_date, action (skip|reschedule), new_date (nullable)

### Relationships
- Project belongs to Category (many-to-one)
- Entry belongs to Project (many-to-one, required)
- Every entry MUST belong to a project
- RecurrenceException belongs to Entry (many-to-one)

## Data Storage Notes
- **v1 web**: Hive uses IndexedDB in the browser. Data is per-browser, local only. Clearing browser site data will destroy all entries. This is the primary motivation for v2 Supabase migration.
- **v1 Android**: Hive uses the app's local file system. Data persists until app is uninstalled.
- **v2+**: Supabase replaces Hive. DatabaseService public interface is preserved to minimize refactor scope.

## Data Flow

**Adding a task from the calendar:**
1. User taps a day on CalendarScreen
2. Day detail expands showing existing entries
3. User taps "+ Add quest / event"
4. AddEntrySheet opens with date pre-filled
5. User selects type (Task), fills title, assigns Campaign, sets reminder
6. On save → DatabaseService inserts Entry → Riverpod state refreshes → CalendarScreen and TodoScreen update → NotificationService will fire at reminder time

**Recurring event generation:**
1. RecurrenceEngine reads Entry.recurrence_rule
2. Generates next N occurrences within the visible date range
3. Checks RecurrenceException table for skips/reschedules
4. Returns materialized list for display

**Web notification flow:**
1. On app start, browser prompts user to allow notifications
2. Timer fires every 60 seconds
3. All entries with reminder_minutes set are checked against current time
4. If now >= entry_time - reminder_minutes → browser notification fires
5. Each entry only notifies once per session (resets on page refresh)

## External Dependencies
- **hive_flutter**: Local storage (v1) — Android, Web, iOS, desktop compatible
- **package:web**: Browser Notification API interop for web notifications
- **supabase_flutter**: Cloud sync (v2+) — will replace hive_flutter
- **flutter_local_notifications**: Android/iOS notifications (v2+) — deferred
- **riverpod**: State management — low risk, actively maintained
- **intl**: Date formatting

## UI Design
Medieval tavern theme applied throughout:
- **Background**: Oak wood brown `#8B6F47`
- **Cards/screens**: Parchment `#EFE8D8`
- **Accent**: Gold `#C9A961`
- **Text**: Ink dark `#3D2E1F`
- **Project colors**: Gem palette (amber, sapphire, ruby, emerald, amethyst, opal, topaz, onyx)
- **Font**: System serif for headings, default sans-serif for body
- **Nav labels**: Chronicle (calendar), Quest Log (to-do), Campaigns (projects)

## MVP Scope
### v1 — ✅ Done
- Calendar monthly grid with day expansion
- Create/edit/delete Tasks, Events, and Deadlines
- Campaigns (projects) with gem color palette
- User-defined categories
- Quest Log with Today/Upcoming/No Date grouping
- Filter by campaign and category
- Completed tasks greyed out
- Reminder field with browser notifications (web, while tab open)
- Basic recurrence (daily, weekly, monthly)
- Hive local persistence
- Medieval tavern theme
- Deployed: tavernboard.matthewbarlow.me + Android APK

### v1 — ❌ Not yet done
- Unit tests for data model and recurrence logic
- Android notifications (flutter_local_notifications)

### Future (v2+) — Don't build yet
- Supabase cloud sync (high priority — data loss risk with local storage)
- iOS build via Codemagic CI
- Background push notifications (requires server + Service Worker)
- Complex recurrence ("every 2nd Tuesday", custom rrules)
- Search across all entries
- Data export/backup
- Weekly/daily calendar views
- Drag-and-drop rescheduling
- Google Calendar sync
- Web sidebar navigation (replace bottom nav for desktop breakpoint)

## Risk Register
| Risk | Likelihood | Mitigation |
|---|---|---|
| Data loss from browser cache clear (v1) | High | Migrate to Supabase in v2 — do not encourage heavy use until then |
| Flutter/Dart learning curve | High | Lean on hot reload; codebase is well-structured |
| Notification permission denied by user | Medium | Graceful — app works without it, reminders just don't fire |
| Hive → Supabase migration complexity | Medium | DatabaseService interface is stable; only implementation changes |
| iOS build requires Mac or CI | Medium | Use Codemagic free tier for iOS builds in v3 |
| Complex recurrence bugs | Medium | Defer complex rrules, add unit tests before v2 |

## Assumptions
| Assumption | Impact |
|---|---|
| Single user — no multi-user or auth needed in v1 | Structural |
| User accepts data loss risk of local storage in v1 | Accepted risk |
| v2 Supabase replaces Hive entirely — no hybrid | Structural |
| iOS added in v3 via Codemagic CI | Structural |
| Web notifications only fire while tab is open (v1) | Known limitation |

## Open Questions
- [x] ~~Platform targets~~ → Android + Web (v1), Supabase sync (v2), iOS (v3)
- [x] ~~App name~~ → Tavernboard
- [x] ~~Storage solution~~ → Hive (v1), Supabase (v2)
- [x] ~~Web deployment~~ → Cloudflare Pages via GitHub Actions
- [x] ~~Web notifications~~ → Browser Notification API implemented
- [ ] Unit tests — pending
- [ ] Supabase project setup — deferred to v2
- [ ] Codemagic CI setup for iOS — deferred to v3
- [ ] Web sidebar nav for desktop breakpoint — deferred to v1 polish
