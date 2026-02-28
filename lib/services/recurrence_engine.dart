import '../models/entry.dart';
import '../models/recurrence_exception.dart';

/// Generates materialized occurrences for recurring entries within a date range.
class RecurrenceEngine {
  /// Returns a list of dates on which [entry] occurs within [start]..[end],
  /// accounting for [exceptions] (skips and reschedules).
  List<DateTime> generateOccurrences({
    required Entry entry,
    required DateTime start,
    required DateTime end,
    List<RecurrenceException> exceptions = const [],
  }) {
    if (entry.recurrenceRule == null || entry.date == null) return [];

    final rule = entry.recurrenceRule!;
    final origin = _dateOnly(entry.date!);
    final rangeStart = _dateOnly(start);
    final rangeEnd = _dateOnly(end);

    // Build lookup of exceptions by original date
    final skipDates = <DateTime>{};
    final reschedules = <DateTime, DateTime>{};
    for (final ex in exceptions) {
      final origDate = _dateOnly(ex.originalDate);
      if (ex.action == ExceptionAction.skip) {
        skipDates.add(origDate);
      } else if (ex.action == ExceptionAction.reschedule &&
          ex.newDate != null) {
        reschedules[origDate] = _dateOnly(ex.newDate!);
      }
    }

    final results = <DateTime>[];
    DateTime current = origin;

    // Advance to first occurrence at or after rangeStart
    while (current.isBefore(rangeStart)) {
      current = _nextOccurrence(current, rule.frequency);
    }

    while (!current.isAfter(rangeEnd)) {
      if (skipDates.contains(current)) {
        // Skipped — don't add
      } else if (reschedules.containsKey(current)) {
        final newDate = reschedules[current]!;
        if (!newDate.isBefore(rangeStart) && !newDate.isAfter(rangeEnd)) {
          results.add(newDate);
        }
      } else {
        results.add(current);
      }
      current = _nextOccurrence(current, rule.frequency);
    }

    results.sort();
    return results;
  }

  DateTime _nextOccurrence(DateTime from, RecurrenceFrequency freq) {
    switch (freq) {
      case RecurrenceFrequency.daily:
        return DateTime(from.year, from.month, from.day + 1);
      case RecurrenceFrequency.weekly:
        return DateTime(from.year, from.month, from.day + 7);
      case RecurrenceFrequency.monthly:
        final next = DateTime(from.year, from.month + 1, from.day);
        // Handle months with fewer days (e.g., Jan 31 → Feb 28)
        if (next.month != (from.month % 12) + 1) {
          return DateTime(from.year, from.month + 2, 0);
        }
        return next;
    }
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
