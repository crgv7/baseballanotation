import 'package:baseballanotation/screen/calendario/calendar.dart';
import 'package:baseballanotation/screen/graficos.dart';
import 'package:baseballanotation/screen/home.dart';
import 'package:baseballanotation/screen/lideres.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:baseballanotation/models/player.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _playersFuture = DatabaseServices.instance.getPlayers();
  }

  Widget _buildLeaderCard(String category, String value, String playerName) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Líder en $category',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    playerName,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
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

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
      body: _buildLeadersGrid(),
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
