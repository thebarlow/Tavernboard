import 'package:intl/intl.dart';

abstract final class TavernDateUtils {
  static final DateFormat _shortDate = DateFormat('MMM d, y');
  static final DateFormat _longDate = DateFormat('EEEE, MMMM d, y');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYear = DateFormat('MMMM y');
  static final DateFormat _time = DateFormat('h:mm a');

  static String formatShort(DateTime dt) => _shortDate.format(dt);
  static String formatLong(DateTime dt) => _longDate.format(dt);
  static String formatIso(DateTime dt) => _isoDate.format(dt);
  static String formatMonthYear(DateTime dt) => _monthYear.format(dt);
  static String formatTime(DateTime dt) => _time.format(dt);

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  static DateTime startOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);
  static DateTime endOfMonth(DateTime dt) => DateTime(dt.year, dt.month + 1, 0);
}
