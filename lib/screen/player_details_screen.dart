import 'package:flutter/material.dart';
import 'package:baseballScore/models/player.dart';

class PlayerDetailsScreen extends StatelessWidget {
  final Player player;

  const PlayerDetailsScreen({Key? key, required this.player}) : super(key: key);

  Widget _buildStatRow(String label, dynamic value) {
    String displayValue = '';
    if (value is double) {
      displayValue = value.toStringAsFixed(3);
    } else {
      displayValue = value?.toString() ?? '-';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ficha de ${player.name}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información General',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildStatRow('Nombre', player.name),
                      _buildStatRow('Posición',
                          player.isPitcher ? 'Lanzador' : 'Bateador'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!player.isPitcher)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estadísticas de Bateo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildStatRow('Average', player.average),
                        _buildStatRow('Hits', player.hits),
                        _buildStatRow('Turnos al Bate', player.atBats),
                        _buildStatRow('Dobles (2B)', player.doubles),
                        _buildStatRow('Triples (3B)', player.triples),
                        _buildStatRow('Jonrones', player.homeRuns),
                        _buildStatRow('Slugging', player.slg),
                        _buildStatRow('BABIP', player.babip),
                        _buildStatRow('Carreras Impulsadas', player.rbi),
                        _buildStatRow('Carreras Anotadas', player.runs),
                        _buildStatRow('Bases Robadas', player.stolenBases),
                        _buildStatRow('Golpeado por Lanzamiento', player.hbp),
                        _buildStatRow('Elevado de Sacrificio', player.sf),
                        _buildStatRow('Base por Bolas', player.bb),
                        _buildStatRow('OBP', player.obp),
                        _buildStatRow(
                            'BB%',
                            player.bbPercentage != null
                                ? '${player.bbPercentage!.toStringAsFixed(1)}%'
                                : '-'),
                        _buildStatRow(
                            'K%',
                            player.kPercentage != null
                                ? '${player.kPercentage!.toStringAsFixed(1)}%'
                                : '-')
                      ],
                    ),
                  ),
                ),
              if (player.isPitcher)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estadísticas de Pitcheo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildStatRow('Victorias', player.wins),
                        _buildStatRow('Derrotas', player.losses),
                        _buildStatRow('ERA', player.era),
                        _buildStatRow('Ponches', player.strikeouts),
                        _buildStatRow('Bases por Bolas', player.walks),
                        _buildStatRow('WHIP', player.whip),
                        _buildStatRow(
                            'Innings Lanzados', player.inningsPitched),
                        _buildStatRow('Salvados', player.saves),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
