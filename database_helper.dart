import 'task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper.init();
  static Database? _database;

  // pivate constructor
  DatabaseHelper.init();

  Future _createTable(Database db, int version) async {
    await db.execute(''''
    CREATE TABLE tasks (
    idINTEGER PRIMARY KET AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    isDone INTEGER NOT NULL
    )
    ''');
  }

  Futer<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks'
      ,task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
      )
  }
}
