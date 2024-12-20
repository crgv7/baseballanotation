import 'package:baseballScore/screen/calendario/calendar.dart';
import 'package:baseballScore/screen/graficos.dart';
import 'package:baseballScore/screen/home.dart';
import 'package:baseballScore/screen/lideres.dart';
import 'package:baseballScore/screen/teams/teams_screen.dart';
import 'package:baseballScore/screen/my_team/my_team_screen.dart';
import 'package:baseballScore/screen/games/games_screen.dart';
import 'package:baseballScore/services/database_services.dart';
import 'package:baseballScore/models/player.dart';
import 'package:baseballScore/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:baseballScore/screen/configuration/configuration_screen.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'package:baseballScore/screen/about/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar la base de datos y esperar a que esté lista
    final db = await DatabaseServices.instance.database;
    print('Database initialized successfully at: ${db.path}');
  } catch (e) {
    print('Error initializing database: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Baseball Stats',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0), // Azul principal
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF1565C0),
              secondary: const Color(0xFF2196F3),
              tertiary: const Color(0xFF64B5F6),
              background: Colors.white,
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1565C0),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Colors.white,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0), // Azul principal
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFF1565C0),
              secondary: const Color(0xFF2196F3),
              tertiary: const Color(0xFF64B5F6),
              background: const Color(0xFF121212),
              surface: const Color(0xFF1E1E1E),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1565C0),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF1E1E1E),
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const MyHomePage(title: 'Baseball Stats'),
            'home': (context) => const Home(),
            'calendario': (context) => const EventCalendar(),
            'lideres': (context) => Lideres(),
            'graficos': (context) => const Graficos(),
            '/teams': (context) => const TeamsScreen(),
            '/my-team': (context) => const MyTeamScreen(),
            '/games': (context) => const GamesScreen(),
            '/configuration': (context) => const ConfigurationScreen(),
            '/about': (context) => const AboutScreen(),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  List<Player> players = [];
  List<Event> events = [];
  StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast();
  Stream<List<Event>> get eventsStream => _eventsController.stream;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _loadEvents();

    // Configurar actualización periódica
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadEvents();
    });
  }

  Future<void> _loadPlayers() async {
    final loadedPlayers = await _databaseServices.getPlayers();
    setState(() {
      players = loadedPlayers;
    });
  }

  Future<void> _loadEvents() async {
    final loadedEvents = await _databaseServices.getEvents();
    setState(() {
      events = loadedEvents;
      _eventsController.add(loadedEvents);
    });
  }

  @override
  void dispose() {
    _eventsController.close();
    super.dispose();
  }

  Widget _buildLeaderCard(String category, String value, String playerName) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              playerName,
              style: const TextStyle(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadersGrid() {
    // Encontrar líderes
    Player? battingLeader;
    Player? homeRunLeader;
    Player? rbiLeader;
    Player? hitsLeader;

    for (var player in players) {
      if (battingLeader == null ||
          (player.average ?? 0) > (battingLeader.average ?? 0)) {
        battingLeader = player;
      }
      if (homeRunLeader == null ||
          (player.homeRuns ?? 0) > (homeRunLeader.homeRuns ?? 0)) {
        homeRunLeader = player;
      }
      if (rbiLeader == null || (player.rbi ?? 0) > (rbiLeader.rbi ?? 0)) {
        rbiLeader = player;
      }
      if (hitsLeader == null || (player.hits ?? 0) > (hitsLeader.hits ?? 0)) {
        hitsLeader = player;
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildLeaderCard(
          'Promedio de Bateo',
          ((battingLeader?.average ?? 0.0) * 1000).toStringAsFixed(0),
          battingLeader?.name ?? 'N/A',
        ),
        _buildLeaderCard(
          'Home Runs',
          (homeRunLeader?.homeRuns ?? 0).toString(),
          homeRunLeader?.name ?? 'N/A',
        ),
        _buildLeaderCard(
          'RBIs',
          (rbiLeader?.rbi ?? 0).toString(),
          rbiLeader?.name ?? 'N/A',
        ),
        _buildLeaderCard(
          'Hits',
          (hitsLeader?.hits ?? 0).toString(),
          hitsLeader?.name ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    return StreamBuilder<List<Event>>(
      stream: _eventsController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay eventos próximos'),
            ),
          );
        }

        final events = snapshot.data!;
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

        return Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Próximos Eventos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadEvents,
                      tooltip: 'Actualizar eventos',
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    leading: Icon(
                      Icons.event,
                      color: Colors
                          .accents[event.colorIndex % Colors.accents.length],
                    ),
                    title: Text(event.eventName),
                    subtitle: Text(
                      event.isAllDay
                          ? DateFormat('dd/MM/yyyy').format(event.from)
                          : '${dateFormat.format(event.from)} - ${dateFormat.format(event.to)}',
                    ),
                    trailing: event.notes != null && event.notes!.isNotEmpty
                        ? const Icon(Icons.note, size: 16)
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          _buildLeadersGrid(),
          _buildUpcomingEvents(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Baseball Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Jugadores'),
              onTap: () {
                Navigator.pushNamed(context, 'home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendario'),
              onTap: () {
                Navigator.pushNamed(context, 'calendario');
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Líderes'),
              onTap: () {
                Navigator.pushNamed(context, 'lideres');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Gráficos'),
              onTap: () {
                Navigator.pushNamed(context, 'graficos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Equipos'),
              onTap: () {
                Navigator.pushNamed(context, '/teams');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_baseball),
              title: const Text('Mi Equipo'),
              onTap: () {
                Navigator.pushNamed(context, '/my-team');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports),
              title: const Text('Partidos'),
              onTap: () {
                Navigator.pushNamed(context, '/games');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pushNamed(context, '/configuration');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }
}
