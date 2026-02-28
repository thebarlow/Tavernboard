# Tavernboard

Personal Android productivity app combining calendar, to-do list, project management, and deadline tracking into a single platform.

## Status
**Pre-development** — Architecture spec complete, Flutter SDK installation pending.

## Stack
- **Language**: Dart
- **Framework**: Flutter
- **Database**: SQLite (sqflite)
- **State Management**: Riverpod
- **Target**: Android 14+ (API 34), Samsung Galaxy S24
- **Deployment**: Sideloaded APK

## Features (MVP)
- Monthly calendar grid with color-coded project dots
- Day detail expansion with tasks, events, and deadlines
- To-do list grouped by Today / Upcoming / No Date
- Project management with categories and deadlines
- Local notifications with configurable reminders
- Basic recurrence (daily, weekly, monthly)
- All data stored locally on-device

## Setup
```bash
# Prerequisites: Flutter SDK installed
flutter doctor

# Create project (first time only)
flutter create --org com.tavernboard --project-name tavernboard .

# Run
flutter run
```

## Architecture
See [ARCHITECTURE.md](ARCHITECTURE.md) for the full spec.
