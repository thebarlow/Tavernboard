import 'package:flutter_test/flutter_test.dart';
import 'package:tavernboard/models/entry.dart';
import 'package:tavernboard/models/category.dart';
import 'package:tavernboard/models/project.dart';
import 'package:tavernboard/services/recurrence_engine.dart';

void main() {
  group('Entry model', () {
    test('toMap and fromMap round-trip', () {
      final entry = Entry(
        id: 1,
        projectId: 2,
        type: EntryType.task,
        title: 'Test task',
        description: 'A description',
        date: DateTime(2026, 3, 1),
        startTime: '09:00',
        endTime: '10:00',
        isCompleted: false,
        reminderMinutes: 15,
        recurrenceRule: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
        ),
        createdAt: DateTime(2026, 2, 28),
      );

      final map = entry.toMap();
      final restored = Entry.fromMap(map);

      expect(restored.id, entry.id);
      expect(restored.projectId, entry.projectId);
      expect(restored.type, entry.type);
      expect(restored.title, entry.title);
      expect(restored.description, entry.description);
      expect(restored.startTime, entry.startTime);
      expect(restored.endTime, entry.endTime);
      expect(restored.isCompleted, entry.isCompleted);
      expect(restored.reminderMinutes, entry.reminderMinutes);
      expect(restored.recurrenceRule?.frequency,
          entry.recurrenceRule?.frequency);
    });

    test('null fields serialize correctly', () {
      final entry = Entry(
        projectId: 1,
        type: EntryType.event,
        title: 'Minimal',
        createdAt: DateTime(2026, 2, 28),
      );

      final map = entry.toMap();
      expect(map['description'], isNull);
      expect(map['date'], isNull);
      expect(map['recurrence_rule'], isNull);
      expect(map['reminder_minutes'], isNull);
    });
  });

  group('Category model', () {
    test('round-trip', () {
      const cat = Category(id: 1, name: 'Work');
      final restored = Category.fromMap(cat.toMap());
      expect(restored.name, 'Work');
      expect(restored.id, 1);
    });
  });

  group('Project model', () {
    test('round-trip with deadline', () {
      final project = Project(
        id: 1,
        name: 'Test Project',
        color: 0xFF0000FF,
        categoryId: 1,
        deadline: DateTime(2026, 5, 15),
        createdAt: DateTime(2026, 2, 28),
      );
      final restored = Project.fromMap(project.toMap());
      expect(restored.name, 'Test Project');
      expect(restored.color, 0xFF0000FF);
      expect(restored.deadline, DateTime(2026, 5, 15));
    });

    test('round-trip without deadline', () {
      final project = Project(
        name: 'No Deadline',
        color: 0xFFFF0000,
        categoryId: 2,
        createdAt: DateTime(2026, 2, 28),
      );
      final map = project.toMap();
      final restored = Project.fromMap(map);
      expect(restored.deadline, isNull);
    });
  });

  group('RecurrenceEngine', () {
    final engine = RecurrenceEngine();

    test('daily recurrence generates correct dates', () {
      final entry = Entry(
        id: 1,
        projectId: 1,
        type: EntryType.task,
        title: 'Daily task',
        date: DateTime(2026, 3, 1),
        recurrenceRule: const RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
        ),
        createdAt: DateTime(2026, 2, 28),
      );

      final dates = engine.generateOccurrences(
        entry: entry,
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 5),
      );

      expect(dates, [
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 3),
        DateTime(2026, 3, 4),
        DateTime(2026, 3, 5),
      ]);
    });

    test('weekly recurrence generates correct dates', () {
      final entry = Entry(
        id: 1,
        projectId: 1,
        type: EntryType.event,
        title: 'Weekly event',
        date: DateTime(2026, 3, 2), // Monday
        recurrenceRule: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
        ),
        createdAt: DateTime(2026, 2, 28),
      );

      final dates = engine.generateOccurrences(
        entry: entry,
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );

      expect(dates, [
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 9),
        DateTime(2026, 3, 16),
        DateTime(2026, 3, 23),
        DateTime(2026, 3, 30),
      ]);
    });

    test('monthly recurrence generates correct dates', () {
      final entry = Entry(
        id: 1,
        projectId: 1,
        type: EntryType.deadline,
        title: 'Monthly deadline',
        date: DateTime(2026, 1, 15),
        recurrenceRule: const RecurrenceRule(
          frequency: RecurrenceFrequency.monthly,
        ),
        createdAt: DateTime(2026, 1, 1),
      );

      final dates = engine.generateOccurrences(
        entry: entry,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 6, 30),
      );

      expect(dates, [
        DateTime(2026, 1, 15),
        DateTime(2026, 2, 15),
        DateTime(2026, 3, 15),
        DateTime(2026, 4, 15),
        DateTime(2026, 5, 15),
        DateTime(2026, 6, 15),
      ]);
    });

    test('returns empty for non-recurring entry', () {
      final entry = Entry(
        id: 1,
        projectId: 1,
        type: EntryType.task,
        title: 'One-off',
        date: DateTime(2026, 3, 1),
        createdAt: DateTime(2026, 2, 28),
      );

      final dates = engine.generateOccurrences(
        entry: entry,
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31),
      );

      expect(dates, isEmpty);
    });
  });
}
