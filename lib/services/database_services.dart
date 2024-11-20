import 'package:baseballanotation/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices._constructor();

  static Database? _database;

  final String tableName = 'notes';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnContent = 'content';

  DatabaseServices._constructor();

  Future<Database> get database async {
    _database ??= await getDatabase();
    return _database!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'database.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $tableName(
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnTitle TEXT NOT NULL,
          $columnContent TEXT NOT NULL
        )
      ''');
      },
    );
    return database;
  }

  void addTask(String title, String content) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        columnTitle: title,
        columnContent: content,
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i][columnId],
        title: maps[i][columnTitle],
        content: maps[i][columnContent],
      );
    });
  }

  void deleteTask(int i) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [i],
    );
  }

  Future<void> updateTask(int id, String title, String content) async {
    final db = await database;
    await db.update(
      tableName,
      {
        columnTitle: title,
        columnContent: content,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
