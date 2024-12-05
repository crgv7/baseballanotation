import 'dart:io';
import 'package:baseballanotation/models/player.dart';
import 'package:baseballanotation/models/event.dart';
import 'package:baseballanotation/models/team.dart';
import 'package:baseballanotation/models/my_team.dart';
import 'package:baseballanotation/models/game.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices._constructor();

  static Database? _database;

  final String tableName = 'players';
  final String eventsTableName = 'events';
  final String teamsTableName = 'teams';
  final String myTeamTableName = 'my_team';
  final String gamesTableName = 'games';
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
  final String columnHbp = 'hbp';
  final String columnSf = 'sf';
  final String columnBb = 'bb';
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
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'baseball_stats.db');

    // Ensure the directory exists
    try {
      Directory(dirname(databasePath)).createSync(recursive: true);
    } catch (e) {
      print('Error creating database directory: $e');
    }

    print('Initializing database at: $databasePath');

    return await openDatabase(
      databasePath,
      version: 6,
      onCreate: (db, version) async {
        print('Creating new database...');
        await _createTables(db);
      },
      onOpen: (db) async {
        print('Database opened successfully');
        // Check if tables exist
        final tables = await db
            .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
        print('Existing tables: ${tables.map((t) => t['name']).join(', ')}');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from version $oldVersion to $newVersion');
        
        // Migración para agregar las nuevas columnas
        if (oldVersion < 6) {
          await db.execute('''
            ALTER TABLE $tableName ADD COLUMN $columnHbp INTEGER;
          ''');
          await db.execute('''
            ALTER TABLE $tableName ADD COLUMN $columnSf INTEGER;
          ''');
          await db.execute('''
            ALTER TABLE $tableName ADD COLUMN $columnBb INTEGER;
          ''');
        }
        
        await _createTables(db); // Aseguramos que todas las tablas existan
      },
    );
  }

  Future<void> _createTables(Database db) async {
    try {
      await db.transaction((txn) async {
        // Create players table
        await txn.execute('''
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
            $columnHbp INTEGER,
            $columnSf INTEGER,
            $columnBb INTEGER,
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

        // Create events table
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS $eventsTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            eventName TEXT NOT NULL,
            fromDate TEXT NOT NULL,
            toDate TEXT NOT NULL,
            notes TEXT,
            isAllDay INTEGER NOT NULL,
            colorIndex INTEGER NOT NULL
          )
        ''');

        // Create teams table
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS $teamsTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            imageUrl TEXT,
            wins INTEGER NOT NULL,
            losses INTEGER NOT NULL,
            runs INTEGER NOT NULL
          )
        ''');

        // Create my team table
        await txn.execute('''
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

        // Create games table
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS $gamesTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            myTeamId INTEGER NOT NULL,
            opponentTeamId INTEGER NOT NULL,
            myTeamRuns INTEGER NOT NULL,
            opponentTeamRuns INTEGER NOT NULL,
            year INTEGER NOT NULL,
            FOREIGN KEY (myTeamId) REFERENCES my_team(id),
            FOREIGN KEY (opponentTeamId) REFERENCES teams(id)
          )
        ''');

        print('All tables created successfully');
      });
    } catch (e) {
      print('Error creating tables: $e');
      rethrow;
    }
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
    await _initDatabase();
  }

  Future<void> addPlayer(Player player) async {
    try {
      final db = await database;
      await db.insert(
        tableName,
        player.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Player added successfully: ${player.name}');
    } catch (e) {
      print('Error adding player: $e');
      rethrow;
    }
  }

  Future<List<Player>> getPlayers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      print('Retrieved ${maps.length} players from database');
      return List.generate(maps.length, (i) {
        return Player.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting players: $e');
      return [];
    }
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

  Future<int> addEvent(Event event) async {
    try {
      final db = await database;

      final eventMap = {
        'eventName': event.eventName,
        'fromDate': event.from.toIso8601String(),
        'toDate': event.to.toIso8601String(),
        'notes': event.notes,
        'isAllDay': event.isAllDay ? 1 : 0,
        'colorIndex': event.colorIndex,
      };

      final id = await db.insert(
        eventsTableName,
        eventMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Event saved successfully with ID: $id');

      // Verify that the event was saved correctly
      final savedEvent = await db.query(
        eventsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (savedEvent.isNotEmpty) {
        print('Event verification successful: ${savedEvent.first}');
      } else {
        print('Warning: Event was not found after saving');
      }

      return id;
    } catch (e) {
      print('Error saving event: $e');
      rethrow;
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      final db = await database;

      // Check if the table exists
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', eventsTableName]);

      if (tables.isEmpty) {
        print('Events table does not exist!');
        return [];
      }

      final List<Map<String, dynamic>> maps = await db.query(eventsTableName);
      print('Retrieved ${maps.length} events from database');

      return List.generate(maps.length, (i) {
        try {
          return Event(
            id: maps[i]['id'],
            eventName: maps[i]['eventName'],
            from: DateTime.parse(maps[i]['fromDate']),
            to: DateTime.parse(maps[i]['toDate']),
            notes: maps[i]['notes'],
            isAllDay: maps[i]['isAllDay'] == 1,
            colorIndex: maps[i]['colorIndex'],
          );
        } catch (e) {
          print('Error parsing event ${maps[i]}: $e');
          rethrow;
        }
      });
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  Future<bool> deleteEvent(int id) async {
    try {
      final db = await database;
      
      print('🔍 INICIO Proceso de eliminación de evento en base de datos');
      print('🔑 ID del evento a borrar: $id');

      // Verificar si el evento existe
      final List<Map<String, dynamic>> existingEvents = await db.query(
        eventsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (existingEvents.isEmpty) {
        print('❌ ERROR: No existe un evento con ID $id');
        return false;
      }

      // Imprimir detalles del evento antes de borrar
      print('📋 Detalles del evento a borrar:');
      print('   Nombre: ${existingEvents.first['eventName']}');
      print('   Fecha inicio: ${existingEvents.first['fromDate']}');
      print('   Fecha fin: ${existingEvents.first['toDate']}');

      // Realizar el borrado
      final int rowsAffected = await db.delete(
        eventsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      print('✅ Filas afectadas por el borrado: $rowsAffected');

      // Verificar si el borrado fue exitoso
      final List<Map<String, dynamic>> remainingEvents = await db.query(
        eventsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (remainingEvents.isEmpty) {
        print('✅ Evento borrado exitosamente');
        print('🔚 FIN Proceso de eliminación de evento');
        return true;
      } else {
        print('❌ ERROR: El evento no se borró completamente');
        print('🔚 FIN Proceso de eliminación de evento');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ ERROR CRÍTICO al eliminar evento en base de datos:');
      print('Excepción: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
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

  Future<List<Player>> getPlayersByWins() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '$columnIsPitcher = ?',
        whereArgs: [1],
        orderBy: '$columnWins DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByLosses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '$columnIsPitcher = ?',
        whereArgs: [1],
        orderBy: '$columnLosses DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByEra() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '$columnIsPitcher = ?',
        whereArgs: [1],
        orderBy: '$columnEra ASC' // ERA lower is better
        );
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByStrikeouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '$columnIsPitcher = ?',
        whereArgs: [1],
        orderBy: '$columnStrikeouts DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByWalks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '$columnIsPitcher = ?',
        whereArgs: [1],
        orderBy: '$columnWalks DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersByInningsPitched() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '$columnIsPitcher = ?',
        whereArgs: [1],
        orderBy: '$columnInningsPitched DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Player>> getPlayersBySaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: '$columnIsPitcher = ?',
        whereArgs: [1],
        orderBy: '$columnSaves DESC');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<List<Event>> getUpcomingEvents() async {
    try {
      final db = await database;

      // Get the current date without time
      final now = DateTime.now().subtract(Duration(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
        seconds: DateTime.now().second,
        milliseconds: DateTime.now().millisecond,
        microseconds: DateTime.now().microsecond,
      ));

      final sevenDaysLater = now.add(const Duration(days: 7));

      // Convert dates to ISO strings
      final nowStr = now.toIso8601String();
      final laterStr = sevenDaysLater.toIso8601String();

      print('Querying events...'); // Debug
      print('From: $nowStr'); // Debug
      print('To: $laterStr'); // Debug

      // First, get all events for debug
      final allEvents = await db.query(eventsTableName);
      print('Total events in database: ${allEvents.length}'); // Debug

      // Now get the filtered events
      final List<Map<String, dynamic>> maps = await db.query(
        eventsTableName,
        where: "toDate >= ? AND fromDate <= ?",
        whereArgs: [nowStr, laterStr],
        orderBy: "fromDate ASC",
      );

      print('Events found for the period: ${maps.length}'); // Debug

      // Print each found event for debug
      for (var map in maps) {
        print('Event: ${map['eventName']}');
        print('From: ${map['fromDate']}');
        print('To: ${map['toDate']}');
      }

      return List.generate(maps.length, (i) {
        return Event(
          id: maps[i]['id'],
          eventName: maps[i]['eventName'],
          from: DateTime.parse(maps[i]['fromDate']),
          to: DateTime.parse(maps[i]['toDate']),
          notes: maps[i]['notes'],
          isAllDay: maps[i]['isAllDay'] == 1,
          colorIndex: maps[i]['colorIndex'],
        );
      });
    } catch (e) {
      print('Error getting events: $e'); // Debug
      return [];
    }
  }

  // CRUD operations for teams
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

  // CRUD operations for My Team
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

    // First, delete any existing team
    await db.delete(myTeamTableName);

    // Then insert the new team
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

  // Methods for Games
  Future<List<Game>> getGames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(gamesTableName);
    return List.generate(maps.length, (i) => Game.fromMap(maps[i]));
  }

  Future<Game> getGame(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      gamesTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Game.fromMap(maps.first);
  }

  Future<int> saveGame(Game game) async {
    final db = await database;
    return await db.insert(
      gamesTableName,
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateGame(Game game) async {
    final db = await database;
    return await db.update(
      gamesTableName,
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> deleteGame(int id) async {
    final db = await database;
    return await db.delete(
      gamesTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
