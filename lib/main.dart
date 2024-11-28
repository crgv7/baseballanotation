import 'package:baseballanotation/screen/calendario/calendar.dart';
import 'package:baseballanotation/screen/graficos.dart';
import 'package:baseballanotation/screen/home.dart';
import 'package:baseballanotation/screen/lideres.dart';
import 'package:baseballanotation/screen/teams/teams_screen.dart';
import 'package:baseballanotation/screen/my_team/my_team_screen.dart';
import 'package:baseballanotation/screen/games/games_screen.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:baseballanotation/models/player.dart';
import 'package:baseballanotation/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Eliminar la base de datos existente para forzar la actualización
  final databasePath = join(await getDatabasesPath(), 'baseball_stats.db');
  await deleteDatabase(databasePath);
  
  // Inicializar la base de datos
  await DatabaseServices.instance.getDatabase();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baseball Stats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  StreamController<List<Event>> _eventsController = StreamController<List<Event>>.broadcast();
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
      if (rbiLeader == null || 
          (player.rbi ?? 0) > (rbiLeader.rbi ?? 0)) {
        rbiLeader = player;
      }
      if (hitsLeader == null || 
          (player.hits ?? 0) > (hitsLeader.hits ?? 0)) {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
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
                Navigator.pop(context);
                Navigator.pushNamed(context, 'home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'calendario');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_baseball),
              title: const Text('Equipos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/teams');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Mi Equipo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-team');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_baseball),
              title: const Text('Juegos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/games');
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Líderes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'lideres');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Gráficos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'graficos');
              },
            ),
          ],
        ),
      ),
    );
  }
}
