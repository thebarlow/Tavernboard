import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';
import '../models/project.dart';
import '../models/entry.dart';
import '../models/recurrence_exception.dart';

/// Hive-backed persistence — works on Android, Web, iOS, and desktop.
/// Public interface is identical to the previous sqflite implementation.
class DatabaseService {
  static const _categoriesBoxName = 'categories';
  static const _projectsBoxName = 'projects';
  static const _entriesBoxName = 'entries';
  static const _exceptionsBoxName = 'recurrence_exceptions';
  static const _countersBoxName = 'counters';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_categoriesBoxName);
    await Hive.openBox(_projectsBoxName);
    await Hive.openBox(_entriesBoxName);
    await Hive.openBox(_exceptionsBoxName);
    await Hive.openBox<int>(_countersBoxName);
  }

  Box get _cats => Hive.box(_categoriesBoxName);
  Box get _projects => Hive.box(_projectsBoxName);
  Box get _entries => Hive.box(_entriesBoxName);
  Box get _exceptions => Hive.box(_exceptionsBoxName);
  Box<int> get _counters => Hive.box<int>(_countersBoxName);

  int _nextId(String entity) {
    final next = (_counters.get(entity) ?? 0) + 1;
    _counters.put(entity, next);
    return next;
  }

  Map<String, dynamic> _cast(dynamic raw) =>
      Map<String, dynamic>.from(raw as Map);

  // --- Categories ---

  Future<int> insertCategory(Category category) async {
    final id = _nextId(_categoriesBoxName);
    await _cats.put(id, {...category.toMap(), 'id': id});
    return id;
  }

  Future<List<Category>> getCategories() {
    final items = _cats.values
        .map((v) => Category.fromMap(_cast(v)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return Future.value(items);
  }

  Future<int> updateCategory(Category category) async {
    await _cats.put(category.id, category.toMap());
    return 1;
  }

  Future<int> deleteCategory(int id) async {
    await _cats.delete(id);
    return 1;
  }

  // --- Projects ---

  Future<int> insertProject(Project project) async {
    final id = _nextId(_projectsBoxName);
    await _projects.put(id, {...project.toMap(), 'id': id});
    return id;
  }

  Future<List<Project>> getProjects() {
    final items = _projects.values
        .map((v) => Project.fromMap(_cast(v)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return Future.value(items);
  }

  Future<int> updateProject(Project project) async {
    await _projects.put(project.id, project.toMap());
    return 1;
  }

  Future<int> deleteProject(int id) async {
    await _projects.delete(id);
    final entryKeys = _entries.keys
        .where((k) => _cast(_entries.get(k))['project_id'] == id)
        .toList();
    await _entries.deleteAll(entryKeys);
    return 1;
  }

  Future<int> getProjectTaskCount(int projectId) {
    final count = _entries.values
        .where((v) => _cast(v)['project_id'] == projectId)
        .length;
    return Future.value(count);
  }

  // --- Entries ---

  Future<int> insertEntry(Entry entry) async {
    final id = _nextId(_entriesBoxName);
    await _entries.put(id, {...entry.toMap(), 'id': id});
    return id;
  }

  Future<List<Entry>> getAllEntries() {
    final items = _entries.values
        .map((v) => Entry.fromMap(_cast(v)))
        .toList()
      ..sort((a, b) {
        final dc =
            (a.date ?? DateTime(9999)).compareTo(b.date ?? DateTime(9999));
        if (dc != 0) return dc;
        return (a.startTime ?? '').compareTo(b.startTime ?? '');
      });
    return Future.value(items);
  }

  Future<List<Entry>> getEntriesForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final items = _entries.values
        .map((v) => Entry.fromMap(_cast(v)))
        .where((e) {
          if (e.date == null) return false;
          return DateTime(e.date!.year, e.date!.month, e.date!.day) == dateOnly;
        })
        .toList()
      ..sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
    return Future.value(items);
  }

  Future<List<Entry>> getEntriesInRange(DateTime start, DateTime end) {
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    final items = _entries.values
        .map((v) => Entry.fromMap(_cast(v)))
        .where((e) {
          if (e.date == null) return false;
          final d = DateTime(e.date!.year, e.date!.month, e.date!.day);
          return !d.isBefore(startOnly) && !d.isAfter(endOnly);
        })
        .toList()
      ..sort((a, b) {
        final dc = a.date!.compareTo(b.date!);
        if (dc != 0) return dc;
        return (a.startTime ?? '').compareTo(b.startTime ?? '');
      });
    return Future.value(items);
  }

  Future<List<Entry>> getEntriesForProject(int projectId) {
    final items = _entries.values
        .map((v) => Entry.fromMap(_cast(v)))
        .where((e) => e.projectId == projectId)
        .toList()
      ..sort((a, b) {
        final dc =
            (a.date ?? DateTime(9999)).compareTo(b.date ?? DateTime(9999));
        if (dc != 0) return dc;
        return (a.startTime ?? '').compareTo(b.startTime ?? '');
      });
    return Future.value(items);
  }

  Future<List<Entry>> getEntriesWithNoDate() {
    final items = _entries.values
        .map((v) => Entry.fromMap(_cast(v)))
        .where((e) => e.date == null)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return Future.value(items);
  }

  Future<List<Entry>> getRecurringEntries() {
    final items = _entries.values
        .map((v) => Entry.fromMap(_cast(v)))
        .where((e) => e.recurrenceRule != null)
        .toList();
    return Future.value(items);
  }

  Future<int> updateEntry(Entry entry) async {
    await _entries.put(entry.id, entry.toMap());
    return 1;
  }

  Future<int> deleteEntry(int id) async {
    await _entries.delete(id);
    final exKeys = _exceptions.keys
        .where((k) => _cast(_exceptions.get(k))['entry_id'] == id)
        .toList();
    await _exceptions.deleteAll(exKeys);
    return 1;
  }

  // --- Recurrence Exceptions ---

  Future<int> insertRecurrenceException(RecurrenceException exception) async {
    final id = _nextId(_exceptionsBoxName);
    await _exceptions.put(id, {...exception.toMap(), 'id': id});
    return id;
  }

  Future<List<RecurrenceException>> getExceptionsForEntry(int entryId) {
    final items = _exceptions.values
        .map((v) => RecurrenceException.fromMap(_cast(v)))
        .where((e) => e.entryId == entryId)
        .toList();
    return Future.value(items);
  }
}
