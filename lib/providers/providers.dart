import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/project.dart';
import '../models/entry.dart';
import '../services/database_service.dart';
import '../services/recurrence_engine.dart';

// --- Singletons ---

final databaseProvider = Provider<DatabaseService>((ref) => DatabaseService());
final recurrenceEngineProvider =
    Provider<RecurrenceEngine>((ref) => RecurrenceEngine());

// --- UI State ---

final selectedDateProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

final selectedTabProvider = StateProvider<int>((ref) => 0);

// --- Categories ---

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final db = ref.read(databaseProvider);
    return db.getCategories();
  }

  Future<int> add(Category category) async {
    final db = ref.read(databaseProvider);
    final id = await db.insertCategory(category);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateItem(Category category) async {
    final db = ref.read(databaseProvider);
    await db.updateCategory(category);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final db = ref.read(databaseProvider);
    await db.deleteCategory(id);
    ref.invalidateSelf();
  }
}

// --- Projects ---

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<Project>>(
  ProjectsNotifier.new,
);

class ProjectsNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final db = ref.read(databaseProvider);
    return db.getProjects();
  }

  Future<int> add(Project project) async {
    final db = ref.read(databaseProvider);
    final id = await db.insertProject(project);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateItem(Project project) async {
    final db = ref.read(databaseProvider);
    await db.updateProject(project);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final db = ref.read(databaseProvider);
    await db.deleteProject(id);
    ref.invalidateSelf();
    ref.invalidate(entriesProvider);
  }
}

// --- Entries ---

final entriesProvider =
    AsyncNotifierProvider<EntriesNotifier, List<Entry>>(
  EntriesNotifier.new,
);

class EntriesNotifier extends AsyncNotifier<List<Entry>> {
  @override
  Future<List<Entry>> build() async {
    final db = ref.read(databaseProvider);
    return db.getAllEntries();
  }

  Future<int> add(Entry entry) async {
    final db = ref.read(databaseProvider);
    final id = await db.insertEntry(entry);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateItem(Entry entry) async {
    final db = ref.read(databaseProvider);
    await db.updateEntry(entry);
    ref.invalidateSelf();
  }

  Future<void> toggleComplete(Entry entry) async {
    final updated = entry.copyWith(isCompleted: !entry.isCompleted);
    await updateItem(updated);
  }

  Future<void> delete(int id) async {
    final db = ref.read(databaseProvider);
    await db.deleteEntry(id);
    ref.invalidateSelf();
  }
}

// --- Derived: entries for a specific date ---

final entriesForDateProvider =
    Provider.family<AsyncValue<List<Entry>>, DateTime>((ref, date) {
  final entriesAsync = ref.watch(entriesProvider);
  final dateOnly = DateTime(date.year, date.month, date.day);

  return entriesAsync.whenData((entries) {
    return entries.where((e) {
      if (e.date == null) return false;
      final entryDate = DateTime(e.date!.year, e.date!.month, e.date!.day);
      return entryDate == dateOnly;
    }).toList();
  });
});

// --- Derived: entries grouped for To-Do screen ---

final todoEntriesProvider =
    Provider<AsyncValue<TodoGroups>>((ref) {
  final entriesAsync = ref.watch(entriesProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return entriesAsync.whenData((entries) {
    final tasks = entries.where((e) => e.type == EntryType.task).toList();

    final todayTasks = <Entry>[];
    final upcomingTasks = <Entry>[];
    final noDateTasks = <Entry>[];

    for (final task in tasks) {
      if (task.date == null) {
        noDateTasks.add(task);
      } else {
        final taskDate =
            DateTime(task.date!.year, task.date!.month, task.date!.day);
        if (taskDate == today || taskDate.isBefore(today)) {
          todayTasks.add(task);
        } else {
          upcomingTasks.add(task);
        }
      }
    }

    return TodoGroups(
      today: todayTasks,
      upcoming: upcomingTasks,
      noDate: noDateTasks,
    );
  });
});

class TodoGroups {
  final List<Entry> today;
  final List<Entry> upcoming;
  final List<Entry> noDate;

  const TodoGroups({
    required this.today,
    required this.upcoming,
    required this.noDate,
  });
}

// --- Derived: entries for calendar month (which days have dots) ---

final monthEntriesProvider =
    Provider.family<AsyncValue<Map<DateTime, List<Entry>>>, DateTime>(
  (ref, month) {
    final entriesAsync = ref.watch(entriesProvider);

    return entriesAsync.whenData((entries) {
      final map = <DateTime, List<Entry>>{};
      for (final entry in entries) {
        if (entry.date == null) continue;
        final dateKey =
            DateTime(entry.date!.year, entry.date!.month, entry.date!.day);
        if (dateKey.month == month.month && dateKey.year == month.year) {
          map.putIfAbsent(dateKey, () => []).add(entry);
        }
      }
      return map;
    });
  },
);
