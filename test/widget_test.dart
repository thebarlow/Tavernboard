import 'package:flutter_test/flutter_test.dart';
import 'package:tavernboard/models/entry.dart';
import 'package:tavernboard/models/recurrence_exception.dart';
import 'package:tavernboard/services/recurrence_engine.dart';

void main() {
  group('RecurrenceEngine', () {
    final engine = RecurrenceEngine();

    Entry makeEntry({
      required RecurrenceFrequency frequency,
      required DateTime date,
    }) =>
        Entry(
          id: 'test-id',
          userId: 'user-id',
          type: 'task',
          title: 'Test',
          isCompleted: false,
          date: date,
          recurrenceRule: RecurrenceRule(frequency: frequency),
          createdAt: DateTime(2026, 1, 1),
        );

    test('daily recurrence generates correct dates', () {
      final entry = makeEntry(
        frequency: RecurrenceFrequency.daily,
        date: DateTime(2026, 3, 1),
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
      final entry = makeEntry(
        frequency: RecurrenceFrequency.weekly,
        date: DateTime(2026, 3, 2),
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
      final entry = makeEntry(
        frequency: RecurrenceFrequency.monthly,
        date: DateTime(2026, 1, 15),
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
        id: 'test-id',
        userId: 'user-id',
        type: 'task',
        title: 'One-off',
        isCompleted: false,
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

    test('skip exception removes date', () {
      final entry = makeEntry(
        frequency: RecurrenceFrequency.daily,
        date: DateTime(2026, 3, 1),
      );
      final exceptions = [
        RecurrenceException(
          id: 'ex-1',
          entryId: 'test-id',
          originalDate: DateTime(2026, 3, 3),
          action: ExceptionAction.skip,
        ),
      ];
      final dates = engine.generateOccurrences(
        entry: entry,
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 5),
        exceptions: exceptions,
      );
      expect(dates, [
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 4),
        DateTime(2026, 3, 5),
      ]);
    });
  });
}
