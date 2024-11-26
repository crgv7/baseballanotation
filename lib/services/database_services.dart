import 'package:baseballanotation/models/player.dart';
import 'package:baseballanotation/models/event.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices._constructor();

  static Database? _database;

  final String tableName = 'players';
  final String eventsTableName = 'events';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnIsPitcher = 'is_pitcher';
  final String columnHits = 'hits';
  final String columnAtBats = 'at_bats';
  final String columnAverage = 'average';
  final String columnHomeRuns = 'home_runs';
  final String columnRbi = 'rbi';
  final String columnRuns = 'runs';
  final String columnStolenBases = 'stolen_bases';
  final String columnObp = 'obp';
  final String columnSlg = 'slg';
  final String columnWins = 'wins';
  final String columnLosses = 'losses';
  final String columnEra = 'era';
  final String columnStrikeouts = 'strikeouts';
  final String columnWalks = 'walks';
  final String columnWhip = 'whip';
  final String columnInningsPitched = 'innings_pitched';
  final String columnSaves = 'saves';

  DatabaseServices._constructor();

  Future<Database> get database async {
    _database ??= await getDatabase();
    return _database!;
  }

  Future<void> deleteDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'baseball_stats.db');
    await databaseFactory.deleteDatabase(databasePath);
    _database = null;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'baseball_stats.db');
    final database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        // Crear tabla de jugadores
        await db.execute('''
        CREATE TABLE $tableName(
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT NOT NULL,
          $columnIsPitcher INTEGER NOT NULL,
          $columnHits INTEGER,
          $columnAtBats INTEGER,
          $columnAverage REAL,
          $columnHomeRuns INTEGER,
          $columnRbi INTEGER,
          $columnRuns INTEGER,
          $columnStolenBases INTEGER,
          $columnObp REAL,
          $columnSlg REAL,
          $columnWins INTEGER,
          $columnLosses INTEGER,
          $columnEra REAL,
          $columnStrikeouts INTEGER,
          $columnWalks INTEGER,
          $columnWhip REAL,
          $columnInningsPitched INTEGER,
          $columnSaves INTEGER
        )
        ''');

        // Crear tabla de eventos
        await db.execute('''
        CREATE TABLE $eventsTableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          eventName TEXT NOT NULL,
          'from' TEXT NOT NULL,
          'to' TEXT NOT NULL,
          notes TEXT,
          isAllDay INTEGER NOT NULL,
          colorIndex INTEGER NOT NULL
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1) {
          // Si la versión es 1, solo necesitamos agregar la tabla de eventos
          print('Upgrading database from version $oldVersion to $newVersion');
          await db.execute('''
          CREATE TABLE IF NOT EXISTS $eventsTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            eventName TEXT NOT NULL,
            'from' TEXT NOT NULL,
            'to' TEXT NOT NULL,
            notes TEXT,
            isAllDay INTEGER NOT NULL,
            colorIndex INTEGER NOT NULL
          )
          ''');
        }
      },
    );
    return database;
  }

  Future<void> addPlayer(Player player) async {
    final db = await database;
    await db.insert(
      tableName,
      player.toMap(),
    );
  }

  Future<List<Player>> getPlayers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByHomeRuns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: '$columnHomeRuns DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByAtBats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: '$columnAtBats DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByHits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: '$columnHits DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByRbi() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: '$columnRbi DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<void> updatePlayer(Player player) async {
    final db = await database;
    await db.update(
      tableName,
      player.toMap(),
      where: '$columnId = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> deletePlayer(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> addEvent(Event event) async {
    final db = await database;
    await db.insert(
      eventsTableName,
      event.toMap(),
    );
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(eventsTableName);
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<void> updateEvent(Event event) async {
    final db = await database;
    await db.update(
      eventsTableName,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete(
      eventsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
