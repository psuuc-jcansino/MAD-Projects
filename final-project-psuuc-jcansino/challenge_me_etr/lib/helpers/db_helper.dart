import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

class DbHelper {
  static const String _dbName = 'challenge_me.db';
  static const int _dbVersion = 2;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName); 

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT
      )
    ''');

    await seedCategories(db: db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {}
  }

  static Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  static Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<TaskModel>> getTasksByCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  static Future<void> markTaskCompleted(int id) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isCompleted': 1, 'completedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> markTaskIncomplete(int id) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isCompleted': 0, 'completedAt': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>>
  getCompletedTasksWithCategory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        t.id,
        t.description,
        t.categoryId,
        t.isCompleted,
        t.completedAt,
        c.title AS categoryTitle,
        c.color AS categoryColor,
        c.icon AS categoryIcon
      FROM tasks t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.isCompleted = 1
      ORDER BY t.completedAt DESC
    ''');
  }

  static Future<void> resetTasks(int categoryId) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isCompleted': 0, 'completedAt': null},
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
  }

  static Future<void> seedCategories({Database? db}) async {
    final databaseRef = db ?? await database;

    final count = Sqflite.firstIntValue(
      await databaseRef.rawQuery('SELECT COUNT(*) FROM categories'),
    );

    if (count == 0) {
      final defaultCategories = CategoryModel.defaultCategories;

      for (var cat in defaultCategories) {
        await databaseRef.insert('categories', cat.toMap());
      }
    }
  }
}
