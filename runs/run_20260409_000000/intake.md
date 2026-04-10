# Project Intake

## Project Name
Tavernboard

## Goal
A personal productivity web app with a rustic tavern aesthetic supporting calendar integration, task lists, projects, modular widgets, user accounts, sharing, polling, and social planning features. Primary purpose is portfolio demonstration.

## Target Audience
Fewer than 5 total users (2 guaranteed), one of whom is an active actor needing career-specific widgets.

## Tech Constraints
- Flutter/Dart (already scaffolded, web-first, mobile retained)
- Supabase (auth, database, storage, edge functions) — free tier required
- Riverpod for state management
- Cloudflare Pages for deployment (CI already wired)
- Operating cost must be $0 at this scale

## Must-Haves
- Supabase auth (email/password + Google OAuth)
- Dashboard shell with Calendar, Task List, Project List widgets
- CRUD for Tasks, Events, Deadlines, Projects
- Rustic tavern theme applied to web layout
- Deploy to Cloudflare Pages behind login
- Widget registry system (self-contained widgets with config schema)
- Configurable dashboard grid per user
- Habit Tracker, Daily Reminder, Project Board widgets
- Shareable artifacts via temporary links (no account needed to view/interact)
- Poll widget with shareable vote link
- User-to-user sharing with view/edit permissions
- Supabase Storage integration for file uploads
- Acting widget pack: Audition Tracker, Callback Log, Script/Sides Viewer, Agent/Contact Book
- Custom progress meter widget
- Group planning/event voting tool
- User-defined widget builder (progress bars, charts, counters)
- Plugin API for custom widgets

## Nice-to-Haves
- Mobile-optimized responsive breakpoints beyond basic Flutter web
- Push/email reminders via edge functions
- Additional chart types in user-defined widgets

## Core Stated Purpose (Anchor)
A web-first personal productivity dashboard with a rustic tavern aesthetic, built in Flutter with Supabase as the backend, supporting modular configurable widgets, sharing/polling, and acting-career-specific tooling — operating at zero cost for fewer than 5 users.
