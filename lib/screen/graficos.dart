import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/player.dart';
import '../services/database_services.dart';

class Graficos extends StatefulWidget {
  const Graficos({super.key});

  @override
  State<Graficos> createState() => _GraficosState();
}

class _GraficosState extends State<Graficos> {
  late Future<List<Player>> _playersFuture;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _playersFuture = DatabaseServices.instance.getPlayers();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bateadores'),
              Tab(text: 'Pitchers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBattersCharts(),
            _buildPitchersCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildBattersCharts() {
    return FutureBuilder<List<Player>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        final batters = snapshot.data!.where((player) => !player.isPitcher).toList();
        
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildChart(
                'Promedio de Bateo',
                batters,
                (Player player) => player.average ?? 0.0,
                (value) => value.toStringAsFixed(3),
              ),
              _buildChart(
                'Home Runs',
                batters,
                (Player player) => (player.homeRuns ?? 0).toDouble(),
                (value) => value.toInt().toString(),
              ),
              _buildChart(
                'RBIs',
                batters,
                (Player player) => (player.rbi ?? 0).toDouble(),
                (value) => value.toInt().toString(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPitchersCharts() {
    return FutureBuilder<List<Player>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        final pitchers = snapshot.data!.where((player) => player.isPitcher).toList();
        
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildChart(
                'ERA',
                pitchers,
                (Player player) => player.era ?? 0.0,
                (value) => value.toStringAsFixed(2),
              ),
              _buildChart(
                'Strikeouts',
                pitchers,
                (Player player) => (player.strikeouts ?? 0).toDouble(),
                (value) => value.toInt().toString(),
              ),
              _buildChart(
                'WHIP',
                pitchers,
                (Player player) => player.whip ?? 0.0,
                (value) => value.toStringAsFixed(2),
              ),
              _buildChart(
                'Victorias',
                pitchers,
                (Player player) => (player.wins ?? 0).toDouble(),
                (value) => value.toInt().toString(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(
    String title,
    List<Player> players,
    double Function(Player) getValue,
    String Function(double) formatValue,
  ) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(8),
      child: SfCartesianChart(
        title: ChartTitle(text: title),
        tooltipBehavior: _tooltipBehavior,
        primaryXAxis: CategoryAxis(
          labelRotation: 45,
          labelStyle: const TextStyle(fontSize: 10),
        ),
        series: [
          BarSeries<Player, String>(
            dataSource: players,
            xValueMapper: (Player player, _) => player.name,
            yValueMapper: (Player player, _) => getValue(player),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
          )
        ],
      ),
    );
  }
}