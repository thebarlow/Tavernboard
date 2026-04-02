# Tavernboard — Architecture Spec

## Summary
A comprehensive personal productivity app that integrates calendar, to-do list, project management, and deadline tracking into a single platform. Built for a single user managing multiple creative endeavors, professional obligations, and daily life. v1 targets Android + Web with local SQLite; v2 adds Supabase cloud sync; v3 adds iOS.

## Classification
- **Type**: Personal productivity app (mobile + web first)
- **Interface**: Flutter (cross-platform: Android + Web → iOS later)
- **Persistence**: Local SQLite (v1) → Supabase cloud (v2+)

## Roadmap
| Version | Platforms | Data | Notes |
|---|---|---|---|
| v1 | Android + Web | Local SQLite | Buildable on Windows |
| v2 | Android + Web | Supabase (cloud sync) | Requires Supabase setup; SQLite replaced |
| v3 | + iOS | Supabase | Requires Mac or Codemagic CI for iOS build |
| v4 | + Windows desktop | Supabase | Flutter desktop, deferred |

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
| Framework | Flutter | Best cross-platform mobile UI toolkit, hot reload |
| Database | SQLite via sqflite | Local-first, no server needed, reliable |
| State mgmt | Riverpod | Type-safe, testable, scales well |
| Notifications | flutter_local_notifications | Mature, well-documented |
| Recurrence | rrule (custom impl) | Complex recurrence patterns |
| Testing | flutter_test | Unit tests for core logic |
| Target (v1) | Android + Web | Primary build targets |
| Target (v2) | Android + Web + iOS | iOS requires Mac or Codemagic CI |
| Deployment (v1) | Sideloaded APK + hosted web app | Personal use, no stores needed |
| Deployment (v2) | + TestFlight (iOS) | Codemagic handles iOS build in CI |

## Components
- **CalendarScreen**: Monthly grid view (home screen). Tap a day to expand day detail showing all entries. Primary entry point for adding new items.
- **TodoScreen**: Filtered/grouped list of tasks. Sections: Today, Upcoming, No Date. Filter by project and category.
- **ProjectsScreen**: List of all projects with task counts and deadlines. Tap to expand into project detail with all child entries.
- **AddEntryDialog**: Modal dialog for creating Task/Event/Deadline. Opened from calendar day click or contextually from other screens. (Bottom sheet on mobile in v2.)
- **NotificationService**: Schedules and manages local notifications based on user-set reminders.
- **RecurrenceEngine**: Generates occurrences from rrule-style recurrence patterns.
- **DatabaseService**: SQLite CRUD operations, migrations, query helpers.
- **StateLayer (Riverpod)**: Providers for projects, entries, categories, and UI state.

## Data Model (key entities)

- **Project**: id, name, color, category_id (FK), deadline (optional), created_at
- **Entry**: id, project_id (FK), type (task|event|deadline), title, description, date (optional for tasks), start_time, end_time, color_override (nullable), is_completed, reminder_time (nullable, null = do not remind), recurrence_rule (nullable), created_at
- **Category**: id, name (user-defined: "Acting", "YouTube", "Chores", etc.)
- **RecurrenceException**: id, entry_id (FK), original_date, action (skip|reschedule), new_date (nullable)

### Relationships
- Project belongs to Category (many-to-one)
- Entry belongs to Project (many-to-one, required)
- Every entry MUST belong to a project
- RecurrenceException belongs to Entry (many-to-one)

## Data Flow

**Adding a task from the calendar:**
1. User taps a day on CalendarScreen
2. Day detail expands showing existing entries
3. User clicks "+ Add event / task"
4. AddEntryDialog opens with date pre-filled
5. User selects type (Task), fills title, assigns Project, sets reminder
6. On save → DatabaseService inserts Entry → Riverpod state refreshes → CalendarScreen and TodoScreen update → NotificationService schedules reminder

**Recurring event generation:**
1. RecurrenceEngine reads Entry.recurrence_rule
2. Generates next N occurrences within the visible date range
3. Checks RecurrenceException table for skips/reschedules
4. Returns materialized list for display

## External Dependencies
- **hive_flutter**: Local storage (v1) — works on Android, Web, iOS, and desktop; replaced sqflite
- **supabase_flutter**: Cloud sync (v2+) — replaces sqflite as persistence layer
- **flutter_local_notifications**: Notifications — medium risk, platform permission handling differs across iOS/Android
- **riverpod**: State management — low risk, actively maintained
- v1: No network dependencies. Fully offline.
- v2+: Requires internet for data sync. No offline support planned.

## UI Mockup

### Calendar Screen (Home)
```
┌─────────────────────────────────┐
│  ◀  February 2026          ▶   │
├────┬────┬────┬────┬────┬────┬───┤
│ Su │ Mo │ Tu │ We │ Th │ Fr │ Sa│
├────┼────┼────┼────┼────┼────┼───┤
│    │    │    │    │    │ 1  │ 2 │
│    │ 3  │ 4  │ 5● │ 6  │ 7  │ 8 │
│ 9  │ 10 │ 11 │ 12 │13● │ 14 │15 │
│ 16 │ 17 │18●●│ 19 │ 20 │ 21 │22 │
│ 23 │ 24 │ 25 │ 26 │ 27 │ 28 │   │
└────┴────┴────┴────┴────┴────┴───┘
  ● = project color dot (multiple dots for multiple entries)

  [Day detail on tap ▼]
┌─────────────────────────────────┐
│ Wed Feb 18                      │
│ ● Physics project deadline  [D] │
│ ● Film audition 2:00pm     [E] │
│ ◌ Buy groceries            [T] │  ← greyed if done
│  + Add event / task             │
└─────────────────────────────────┘
│  [Calendar]  [To-Do]  [Projects]│
└─────────────────────────────────┘
```

### To-Do Screen
```
┌─────────────────────────────────┐
│  To-Do                          │
│  [All ▼]  [Project ▼]  [Cat ▼] │
├─────────────────────────────────┤
│ TODAY                           │
│  ● ☐ Buy groceries    Chores   │
│  ● ☐ Read ch. 4       Feb 18   │
│                                 │
│ UPCOMING                        │
│  ● ☐ Submit report    Feb 22   │
│  ● ☐ Call agent       Mar 1    │
│                                 │
│ NO DATE                         │
│  ● ☐ Clean desk       Chores   │
│  ● ☐ Update reel      YouTube  │
├─────────────────────────────────┤
│  [Calendar]  [To-Do]  [Projects]│
└─────────────────────────────────┘
  ● = project color
```

### Projects Screen
```
┌─────────────────────────────────┐
│  Projects                  [+]  │
├─────────────────────────────────┤
│ ● Physics Thesis     3 tasks   │
│   Deadline: May 15              │
│                                 │
│ ● Short Film         5 tasks   │
│   Deadline: Apr 1               │
│                                 │
│ ● Chores             8 tasks   │
│   No deadline                   │
│                                 │
│ ● YouTube Channel    4 tasks   │
│   No deadline                   │
├─────────────────────────────────┤
│  [Calendar]  [To-Do]  [Projects]│
└─────────────────────────────────┘
```

### Add Entry (Dialog)
```
┌─────────────────────────────────┐
│  New Entry             [Cancel] │
│                                 │
│  Type:  ○ Task  ○ Event  ○ Deadline│
│                                 │
│  Title: [........................]│
│  Project: [Select project ▼]   │
│  Category: [Auto from project] │
│  Date: [Feb 18]  Time: [--:--] │
│  Repeat: [None ▼]              │
│  Reminder: [Select ▼]          │
│    Options: Do not remind /     │
│    5m / 15m / 30m / 1h / 1d /  │
│    Custom                       │
│  Color: [Use project color ▼]  │
│                                 │
│          [Save]                 │
└─────────────────────────────────┘
```

## MVP Scope
### v1 — Ship this
- Calendar monthly grid with day expansion
- Create/edit/delete Tasks, Events, and Deadlines
- Projects with user-assigned colors
- User-defined categories
- To-do list with Today/Upcoming/No Date grouping
- Filter by project and category
- Completed tasks greyed out on calendar and to-do
- Mandatory reminder field with "Do not remind" option
- Local notifications
- Basic recurrence (daily, weekly, monthly)
- Local SQLite persistence
- Unit tests for data model and recurrence logic

**Done when:** The user can manage all their projects, tasks, events, and deadlines from a single app, see everything on a color-coded calendar, get reminders, and have recurring items auto-generate.

### Future — Don't build yet
- Complex recurrence ("every 2nd Tuesday", custom rrules)
- Search across all entries
- Data export/backup
- Widgets (home screen)
- Dark mode / theming
- Weekly/daily calendar views
- Drag-and-drop rescheduling
- Google Calendar sync

## Risk Register
| Risk | Likelihood | Mitigation |
|---|---|---|
| Flutter/Dart learning curve | High | Start with UI scaffolding, lean on hot reload |
| Notification permissions (iOS/Android) | Medium | Request permissions explicitly at first launch |
| Flutter web layout differences | Low | Bottom nav bar needs minor tweak for browser; defer to v1 polish |
| Complex recurrence bugs | Medium | Defer complex rrules to later, thorough unit tests for basic patterns |
| SQLite → Supabase migration (v1 → v2) | Medium | Data layer refactor; plan schema in v1 to match Supabase structure |
| iOS build requires Mac or CI | Medium | Use Codemagic free tier for iOS builds in v3 |
| Scope creep from "comprehensive" requirement | High | Stick to MVP list, re-score before adding features |

## Assumptions
| Assumption | Impact |
|---|---|
| Single user — no multi-user or auth needed in v1 | Structural |
| Android + Web are primary targets for v1 | Structural |
| v2 adds Supabase sync; SQLite is replaced, not extended | Structural |
| iOS added in v3 via Codemagic CI (no Mac required locally) | Structural |
| All data fits comfortably in local SQLite (v1) | Performance |
| Flutter SDK will be installed before development begins | Minimal |

## Open Questions
- [x] ~~Platform targets~~ → Android + Web (v1), Supabase sync (v2), iOS (v3)
- [x] ~~App name~~ → Tavernboard
- [ ] Flutter SDK not yet installed — developer will set up before building
- [ ] Web layout polish — bottom nav bar tweak for browser (v1 post-MVP)
- [ ] Supabase project setup — deferred to v2
- [ ] Codemagic CI setup for iOS — deferred to v3
