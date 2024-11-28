import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../models/team.dart';
import '../../models/my_team.dart';

class GameForm extends StatefulWidget {
  final Game? game;
  final MyTeam myTeam;
  final List<Team> teams;
  final Function(Game game) onSave;

  const GameForm({
    super.key,
    this.game,
    required this.myTeam,
    required this.teams,
    required this.onSave,
  });

  @override
  State<GameForm> createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> {
  late TextEditingController _myTeamRunsController;
  late TextEditingController _opponentRunsController;
  late TextEditingController _yearController;
  Team? _selectedOpponent;

  @override
  void initState() {
    super.initState();
    _myTeamRunsController = TextEditingController(
      text: widget.game?.myTeamRuns.toString() ?? '0',
    );
    _opponentRunsController = TextEditingController(
      text: widget.game?.opponentTeamRuns.toString() ?? '0',
    );
    _yearController = TextEditingController(
      text: widget.game?.year.toString() ?? DateTime.now().year.toString(),
    );

    if (widget.game != null) {
      _selectedOpponent = widget.teams.firstWhere(
        (team) => team.id == widget.game!.opponentTeamId,
      );
    }
  }

  @override
  void dispose() {
    _myTeamRunsController.dispose();
    _opponentRunsController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _saveGame() {
    if (_selectedOpponent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un equipo contrario')),
      );
      return;
    }

    final myTeamRuns = int.tryParse(_myTeamRunsController.text) ?? 0;
    final opponentRuns = int.tryParse(_opponentRunsController.text) ?? 0;
    final year = int.tryParse(_yearController.text) ?? DateTime.now().year;

    final game = Game(
      id: widget.game?.id,
      myTeamId: widget.myTeam.id!,
      opponentTeamId: _selectedOpponent!.id!,
      myTeamRuns: myTeamRuns,
      opponentTeamRuns: opponentRuns,
      year: year,
    );

    widget.onSave(game);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Equipo: ${widget.myTeam.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _myTeamRunsController,
                    decoration: const InputDecoration(
                      labelText: 'Carreras Anotadas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Equipo Contrario',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Team>(
                    value: _selectedOpponent,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Equipo',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.teams.map((Team team) {
                      return DropdownMenuItem(
                        value: team,
                        child: Text(team.name),
                      );
                    }).toList(),
                    onChanged: (Team? value) {
                      setState(() {
                        _selectedOpponent = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _opponentRunsController,
                    decoration: const InputDecoration(
                      labelText: 'Carreras del Contrario',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.game == null ? 'Crear Juego' : 'Actualizar Juego',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
