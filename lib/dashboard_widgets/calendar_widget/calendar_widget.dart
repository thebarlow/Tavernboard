import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../dashboard/widget_registry.dart';
import '../../models/entry.dart';
import '../../models/widget_config.dart';
import '../../providers/entry_provider.dart';
import '../../theme/tavern_theme.dart';
import '../../utils/date_utils.dart';
import '../base_widget.dart';
import 'calendar_widget_config.dart';

class CalendarWidget extends BaseWidget {
  const CalendarWidget({super.key, required super.config});

  static void register() {
    WidgetRegistry.register(
      'calendar',
      (config) => CalendarWidget(config: config),
    );
  }

  @override
  String get widgetTitle => 'Calendar';

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    return _CalendarContent(config: config);
  }
}

class _CalendarContent extends ConsumerStatefulWidget {
  final WidgetConfig config;

  const _CalendarContent({required this.config});

  @override
  ConsumerState<_CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends ConsumerState<_CalendarContent> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final calConfig = CalendarWidgetConfig.fromWidgetConfig(widget.config);
    final start = TavernDateUtils.startOfMonth(
      DateTime(_focusedDay.year, _focusedDay.month - 1));
    final end = TavernDateUtils.endOfMonth(
      DateTime(_focusedDay.year, _focusedDay.month + 1));

    final entriesAsync = ref.watch(
      dateRangeEntriesProvider((start: start, end: end)),
    );

    Map<DateTime, List<Entry>> eventMap = {};
    entriesAsync.whenData((entries) {
      for (final e in entries) {
        if (e.date != null) {
          final day = TavernDateUtils.dateOnly(e.date!);
          eventMap.putIfAbsent(day, () => []).add(e);
        }
      }
    });

    return TableCalendar<Entry>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      sixWeekMonthsEnforced: true,
      rowHeight: 36,
      daysOfWeekHeight: 20,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) =>
          _selectedDay != null && TavernDateUtils.isSameDay(day, _selectedDay!),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) => setState(() => _focusedDay = focused),
      eventLoader: (day) {
        final key = TavernDateUtils.dateOnly(day);
        return eventMap[key] ?? [];
      },
      weekendDays: calConfig.showWeekends
          ? const [DateTime.saturday, DateTime.sunday]
          : const [],
      calendarStyle: const CalendarStyle(
        defaultTextStyle: TextStyle(color: TavernColors.textPrimary),
        weekendTextStyle: TextStyle(color: TavernColors.textSecondary),
        selectedDecoration: BoxDecoration(
          color: TavernColors.accent,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: TavernColors.accentSecondary,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: TavernColors.accent,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
        cellPadding: EdgeInsets.all(4),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(color: TavernColors.textPrimary, fontSize: 16),
        leftChevronIcon: Icon(Icons.chevron_left, color: TavernColors.accent),
        rightChevronIcon: Icon(Icons.chevron_right, color: TavernColors.accent),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: TavernColors.textSecondary),
        weekendStyle: TextStyle(color: TavernColors.textSecondary),
      ),
    );
  }
}
