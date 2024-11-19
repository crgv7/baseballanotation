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

  Future<Database>getDatabase() async {
  final databaseDirPath = await getDatabasesPath();
  final databasePath= join(databaseDirPath, 'database.db');
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

}
