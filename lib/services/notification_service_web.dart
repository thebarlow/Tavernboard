import 'package:web/web.dart' as web;
import 'dart:js_interop';
import '../models/entry.dart';

class NotificationService {
  static final _fired = <int>{};

  static Future<void> init() async {
    if (web.Notification.permission == 'default') {
      await web.Notification.requestPermission().toDart;
    }
  }

  static void checkAndFire(List<Entry> entries) {
    if (web.Notification.permission != 'granted') return;
    final now = DateTime.now();
    for (final entry in entries) {
      _maybeFireFor(entry, now);
    }
  }

  static void _maybeFireFor(Entry entry, DateTime now) {
    if (entry.reminderMinutes == null || entry.date == null || entry.id == null) return;
    if (_fired.contains(entry.id)) return;

    DateTime entryTime = entry.date!;
    if (entry.startTime != null) {
      final parts = entry.startTime!.split(':');
      entryTime = DateTime(
        entry.date!.year,
        entry.date!.month,
        entry.date!.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    final reminderAt = entryTime.subtract(Duration(minutes: entry.reminderMinutes!));

    // Fire if past reminder time but entry hasn't passed by more than 1 hour
    if (now.isAfter(reminderAt) && now.isBefore(entryTime.add(const Duration(hours: 1)))) {
      _fired.add(entry.id!);
      web.Notification(
        entry.title,
        web.NotificationOptions(
          body: entry.description ?? _subtitleFor(entry),
          icon: '/icons/Icon-192.png',
        ),
      );
    }
  }

  static String _subtitleFor(Entry entry) => switch (entry.type) {
        EntryType.task => 'Task reminder',
        EntryType.event => 'Event starting soon',
        EntryType.deadline => 'Deadline approaching',
      };
}
