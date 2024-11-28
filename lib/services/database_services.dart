import 'package:baseballanotation/models/player.dart';
import 'package:baseballanotation/models/event.dart';
import 'package:baseballanotation/models/team.dart';
import 'package:baseballanotation/models/my_team.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices._constructor();

  static Database? _database;

  final String tableName = 'players';
  final String eventsTableName = 'events';
  final String teamsTableName = 'teams';
  final String myTeamTableName = 'my_team';
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

  Future<void> resetDatabase() async {
    await deleteDatabase();
    _database = null;
    await getDatabase();
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'baseball_stats.db');
    final database = await openDatabase(
      databasePath,
      version: 4,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from version $oldVersion to $newVersion');
        
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $eventsTableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              eventName TEXT NOT NULL,
              [from] TEXT NOT NULL,
              [to] TEXT NOT NULL,
              notes TEXT,
              isAllDay INTEGER NOT NULL,
              colorIndex INTEGER NOT NULL
            )
          ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $teamsTableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              imageUrl TEXT,
              wins INTEGER NOT NULL,
              losses INTEGER NOT NULL,
              runs INTEGER NOT NULL
            )
          ''');
        }

        if (oldVersion < 4) {
          // Crear la tabla my_team si no existe
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $myTeamTableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              imageUrl TEXT,
              wins INTEGER DEFAULT 0,
              losses INTEGER DEFAULT 0,
              runsScored INTEGER DEFAULT 0,
              runsAllowed INTEGER DEFAULT 0
            )
          ''');
        }
      },
    );
    return database;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $eventsTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventName TEXT NOT NULL,
        [from] TEXT NOT NULL,
        [to] TEXT NOT NULL,
        notes TEXT,
        isAllDay INTEGER NOT NULL,
        colorIndex INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $teamsTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        imageUrl TEXT,
        wins INTEGER NOT NULL,
        losses INTEGER NOT NULL,
        runs INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $myTeamTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        imageUrl TEXT,
        wins INTEGER DEFAULT 0,
        losses INTEGER DEFAULT 0,
        runsScored INTEGER DEFAULT 0,
        runsAllowed INTEGER DEFAULT 0
      )
    ''');
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

  Future<List<Player>> getPlayersByWins() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnIsPitcher = ?',
      whereArgs: [1],
      orderBy: '$columnWins DESC'
    );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByLosses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnIsPitcher = ?',
      whereArgs: [1],
      orderBy: '$columnLosses DESC'
    );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByEra() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnIsPitcher = ?',
      whereArgs: [1],
      orderBy: '$columnEra ASC'  // ERA menor es mejor
    );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByStrikeouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnIsPitcher = ?',
      whereArgs: [1],
      orderBy: '$columnStrikeouts DESC'
    );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByWalks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnIsPitcher = ?',
      whereArgs: [1],
      orderBy: '$columnWalks DESC'
    );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByInningsPitched() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnIsPitcher = ?',
      whereArgs: [1],
      orderBy: '$columnInningsPitched DESC'
    );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersBySaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnIsPitcher = ?',
      whereArgs: [1],
      orderBy: '$columnSaves DESC'
    );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Event>> getUpcomingEvents() async {
    try {
      final db = await database;
      
      // Obtener la fecha actual sin la hora
      final now = DateTime.now().subtract(Duration(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
        seconds: DateTime.now().second,
        milliseconds: DateTime.now().millisecond,
        microseconds: DateTime.now().microsecond,
      ));
      
      final sevenDaysLater = now.add(const Duration(days: 7));

      // Convertir fechas a strings en formato ISO
      final nowStr = now.toIso8601String();
      final laterStr = sevenDaysLater.toIso8601String();

      print('Consultando eventos...'); // Debug
      print('Desde: $nowStr'); // Debug
      print('Hasta: $laterStr'); // Debug

      // Primero, obtener todos los eventos para debug
      final allEvents = await db.query(eventsTableName);
      print('Total de eventos en la base de datos: ${allEvents.length}'); // Debug
      
      // Ahora obtener los eventos filtrados
      final List<Map<String, dynamic>> maps = await db.query(
        eventsTableName,
        where: "[to] >= ? AND [from] <= ?",
        whereArgs: [nowStr, laterStr],
        orderBy: "[from] ASC",
      );

      print('Eventos encontrados para el período: ${maps.length}'); // Debug
      
      // Imprimir cada evento encontrado para debug
      for (var map in maps) {
        print('Evento: ${map['eventName']}');
        print('Desde: ${map['from']}');
        print('Hasta: ${map['to']}');
      }

      return List.generate(maps.length, (i) {
        return Event.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error al obtener eventos: $e'); // Debug
      return [];
    }
  }

  // Operaciones CRUD para equipos
  Future<int> addTeam(Team team) async {
    final db = await database;
    return await db.insert(teamsTableName, team.toMap());
  }

  Future<List<Team>> getTeams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(teamsTableName);
    return List.generate(maps.length, (i) => Team.fromMap(maps[i]));
  }

  Future<int> updateTeam(Team team) async {
    final db = await database;
    return await db.update(
      teamsTableName,
      team.toMap(),
      where: 'id = ?',
      whereArgs: [team.id],
    );
  }

  Future<int> deleteTeam(int id) async {
    final db = await database;
    return await db.delete(
      teamsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Operaciones CRUD para Mi Equipo
  Future<MyTeam?> getMyTeam() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(myTeamTableName);
    
    if (maps.isEmpty) {
      return null;
    }
    
    return MyTeam.fromMap(maps.first);
  }

  Future<void> saveMyTeam(MyTeam team) async {
    final db = await database;
    
    // Primero eliminamos cualquier equipo existente
    await db.delete(myTeamTableName);
    
    // Luego insertamos el nuevo equipo
    await db.insert(
      myTeamTableName,
      team.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMyTeam(MyTeam team) async {
    final db = await database;
    
    await db.update(
      myTeamTableName,
      team.toMap(),
      where: 'id = ?',
      whereArgs: [team.id],
    );
  }

  Future<void> deleteMyTeam() async {
    final db = await database;
    await db.delete(myTeamTableName);
  }
}
