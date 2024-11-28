import 'package:baseballanotation/screen/calendario/calendar.dart';
import 'package:baseballanotation/screen/graficos.dart';
import 'package:baseballanotation/screen/home.dart';
import 'package:baseballanotation/screen/lideres.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:baseballanotation/models/player.dart';
import 'package:baseballanotation/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        'home': (context) => Home(),
        'lideres': (context) => Lideres(),
        'calendario': (context) => EventCalendar(),
        'graficos': (context) => Graficos()
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BallAnotations'),
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
  late Future<List<Player>> _playersFuture;
  final StreamController<List<Event>> _eventsController = StreamController<List<Event>>.broadcast();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _playersFuture = DatabaseServices.instance.getPlayers();
    _loadEvents();

    // Configurar actualización periódica
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isDisposed) {
        _loadEvents();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventsController.close();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!_isDisposed) {
      try {
        print('Cargando eventos...'); // Debug
        final events = await DatabaseServices.instance.getUpcomingEvents();
        print('Eventos cargados: ${events.length}'); // Debug
        if (!_isDisposed) {
          _eventsController.add(events);
        }
      } catch (e) {
        print('Error al cargar eventos: $e'); // Debug
        if (!_isDisposed) {
          _eventsController.addError(e);
        }
      }
    }
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
    return FutureBuilder<List<Player>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        final players = snapshot.data!;

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
          if (hitsLeader == null ||
              (player.hits ?? 0) > (hitsLeader.hits ?? 0)) {
            hitsLeader = player;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Líderes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
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
              ),
            ],
          ),
        );
      },
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
                      color: Colors.accents[event.colorIndex % Colors.accents.length],
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
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Baseball Annotation',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildItem(
                    icon: Icons.home,
                    title: "Home",
                    ontap: () => Navigator.pushNamed(context, "home"),
                  ),
                  _buildItem(
                    icon: Icons.calendar_today,
                    title: "Calendario",
                    ontap: () => Navigator.pushNamed(context, "calendario"),
                  ),
                  _buildItem(
                    icon: Icons.leaderboard,
                    title: "Lideres",
                    ontap: () => Navigator.pushNamed(context, "lideres"),
                  ),
                  _buildItem(
                    icon: Icons.bar_chart,
                    title: "Graficos",
                    ontap: () => Navigator.pushNamed(context, "graficos"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required GestureTapCallback ontap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: ontap,
    );
  }
}
