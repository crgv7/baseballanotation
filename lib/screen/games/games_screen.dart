import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../models/my_team.dart';
import '../../models/team.dart';
import '../../services/database_services.dart';
import 'game_form.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  List<Game> _games = [];
  MyTeam? _myTeam;
  List<Team> _teams = [];
  bool _isLoading = true;
  bool _showForm = false;
  Game? _selectedGame;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final myTeam = await _databaseServices.getMyTeam();
      if (myTeam == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Primero debes crear tu equipo en la sección "Mi Equipo"'),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final teams = await _databaseServices.getTeams();
      final games = await _databaseServices.getGames();

      if (mounted) {
        setState(() {
          _myTeam = myTeam;
          _teams = teams;
          _games = games;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveGame(Game game) async {
    try {
      if (game.id == null) {
        await _databaseServices.saveGame(game);
      } else {
        await _databaseServices.updateGame(game);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Juego guardado exitosamente'),
          ),
        );
        setState(() {
          _showForm = false;
          _selectedGame = null;
        });
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el juego: $e')),
        );
      }
    }
  }

  Future<void> _deleteGame(Game game) async {
    try {
      await _databaseServices.deleteGame(game.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Juego eliminado exitosamente')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el juego: $e')),
        );
      }
    }
  }

  String _getOpponentName(int opponentId) {
    try {
      return _teams.firstWhere((team) => team.id == opponentId).name;
    } catch (e) {
      return 'Equipo Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_myTeam == null) {
      return const Scaffold(
        body: Center(
          child:
              Text('Primero debes crear tu equipo en la sección "Mi Equipo"'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Juegos'),
        actions: [
          if (!_showForm)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _showForm = true;
                  _selectedGame = null;
                });
              },
            ),
        ],
      ),
      body: _showForm
          ? SingleChildScrollView(
              child: GameForm(
                game: _selectedGame,
                myTeam: _myTeam!,
                teams: _teams,
                onSave: _saveGame,
              ),
            )
          : ListView.builder(
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                final bool isWin = game.myTeamRuns > game.opponentTeamRuns;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      '${_myTeam!.name} vs ${_getOpponentName(game.opponentTeamId)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Año: ${game.year}\n'
                      'Marcador: ${game.myTeamRuns} - ${game.opponentTeamRuns}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isWin ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isWin ? 'Victoria' : 'Derrota',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _selectedGame = game;
                              _showForm = true;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar Eliminación'),
                                  content: const Text('¿Estás seguro de que deseas eliminar este juego?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteGame(game);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
