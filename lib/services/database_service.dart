import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/category.dart';
import '../models/project.dart';
import '../models/entry.dart';
import '../models/recurrence_exception.dart';

class DatabaseService {
  static const _dbName = 'tavernboard.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        deadline TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT,
        start_time TEXT,
        end_time TEXT,
        color_override INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        reminder_minutes INTEGER,
        recurrence_rule TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recurrence_exceptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        original_date TEXT NOT NULL,
        action TEXT NOT NULL,
        new_date TEXT,
        FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_entries_date ON entries(date)',
    );
    await db.execute(
      'CREATE INDEX idx_entries_project ON entries(project_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here, chained by version number.
  }

  // --- Categories ---

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map(Category.fromMap).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Projects ---

  Future<int> insertProject(Project project) async {
    final db = await database;
    return db.insert('projects', project.toMap());
  }

  Future<List<Project>> getProjects() async {
    final db = await database;
    final maps = await db.query('projects', orderBy: 'name ASC');
    return maps.map(Project.fromMap).toList();
  }

  Future<int> updateProject(Project project) async {
    final db = await database;
    return db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getProjectTaskCount(int projectId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM entries WHERE project_id = ?',
      [projectId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // --- Entries ---

  Future<int> insertEntry(Entry entry) async {
    final db = await database;
    return db.insert('entries', entry.toMap());
  }

  Future<List<Entry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('entries', orderBy: 'date ASC, start_time ASC');
    return maps.map(Entry.fromMap).toList();
  }

  Future<List<Entry>> getEntriesForDate(DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final maps = await db.query(
      'entries',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'start_time ASC',
    );
    return maps.map(Entry.fromMap).toList();
  }

  Future<List<Entry>> getEntriesInRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr =
        DateTime(start.year, start.month, start.day).toIso8601String();
    final endStr =
        DateTime(end.year, end.month, end.day).toIso8601String();
    final maps = await db.query(
      'entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC, start_time ASC',
    );
    return maps.map(Entry.fromMap).toList();
  }

  Future<List<Entry>> getEntriesForProject(int projectId) async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'date ASC, start_time ASC',
    );
    return maps.map(Entry.fromMap).toList();
  }

  Future<List<Entry>> getEntriesWithNoDate() async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'date IS NULL',
      orderBy: 'created_at ASC',
    );
    return maps.map(Entry.fromMap).toList();
  }

  Future<List<Entry>> getRecurringEntries() async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'recurrence_rule IS NOT NULL',
    );
    return maps.map(Entry.fromMap).toList();
  }

  Future<int> updateEntry(Entry entry) async {
    final db = await database;
    return db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  // --- Recurrence Exceptions ---

  Future<int> insertRecurrenceException(RecurrenceException exception) async {
    final db = await database;
    return db.insert('recurrence_exceptions', exception.toMap());
  }

  Future<List<RecurrenceException>> getExceptionsForEntry(int entryId) async {
    final db = await database;
    final maps = await db.query(
      'recurrence_exceptions',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
    return maps.map(RecurrenceException.fromMap).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
