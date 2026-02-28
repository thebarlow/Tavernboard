import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../providers/providers.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/entry_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final monthEntries =
        ref.watch(monthEntriesProvider(_displayedMonth));
    final projectsAsync = ref.watch(projectsProvider);

    return SafeArea(
      child: Column(
        children: [
          // Month header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_displayedMonth),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Day-of-week headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // Calendar grid
          monthEntries.when(
            data: (entryMap) {
              return projectsAsync.when(
                data: (projects) {
                  final projectColors = <int, Color>{};
                  for (final p in projects) {
                    projectColors[p.id!] = Color(p.color);
                  }
                  return _buildCalendarGrid(
                    context,
                    ref,
                    selectedDate,
                    entryMap,
                    projectColors,
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),

          const Divider(height: 1),

          // Day detail
          Expanded(child: _DayDetail(date: selectedDate)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    Map<DateTime, List<Entry>> entryMap,
    Map<int, Color> projectColors,
  ) {
    final firstOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday % 7; // Sunday = 0

    final cells = <Widget>[];

    // Leading blanks
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selectedOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    for (int day = 1; day <= daysInMonth; day++) {
      final date =
          DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isToday = date == todayOnly;
      final isSelected = date == selectedOnly;
      final dayEntries = entryMap[date] ?? [];

      // Collect unique project colors for dots
      final dotColors = <Color>{};
      for (final e in dayEntries) {
        final c = e.colorOverride != null
            ? Color(e.colorOverride!)
            : projectColors[e.projectId];
        if (c != null) dotColors.add(c);
      }

      cells.add(
        GestureDetector(
          onTap: () {
            ref.read(selectedDateProvider.notifier).state = date;
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              border: isToday
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                  ),
                ),
                if (dotColors.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dotColors
                        .take(3)
                        .map((c) => Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: cells,
    );
  }
}

class _DayDetail extends ConsumerWidget {
  final DateTime date;
  const _DayDetail({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesForDateProvider(date));

    return entriesAsync.when(
      data: (entries) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                DateFormat('EEEE, MMM d').format(date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'No entries',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(128),
                            ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: entries.length,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, i) =>
                          EntryTile(entry: entries[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => _openAddSheet(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add event / task'),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEntrySheet(initialDate: date),
    );
  }
}
