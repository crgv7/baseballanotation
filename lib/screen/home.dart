import 'package:baseballanotation/models/player.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:baseballanotation/screen/player_details_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseServices databaseServices = DatabaseServices.instance;
  late Future<List<Player>> _playersFuture;

  // Common fields
  final TextEditingController _nameController = TextEditingController();
  bool _isPitcher = false;

  // Batting stats controllers
  final TextEditingController _hitsController = TextEditingController();
  final TextEditingController _atBatsController = TextEditingController();
  final TextEditingController _homeRunsController = TextEditingController();
  final TextEditingController _rbiController = TextEditingController();
  final TextEditingController _runsController = TextEditingController();
  final TextEditingController _stolenBasesController = TextEditingController();
  final TextEditingController _hbpController = TextEditingController();
  final TextEditingController _sfController = TextEditingController();
  final TextEditingController _bbController = TextEditingController();

  // Pitching stats controllers
  final TextEditingController _winsController = TextEditingController();
  final TextEditingController _lossesController = TextEditingController();
  final TextEditingController _eraController = TextEditingController();
  final TextEditingController _strikeoutsController = TextEditingController();
  final TextEditingController _walksController = TextEditingController();
  final TextEditingController _inningsPitchedController =
      TextEditingController();
  final TextEditingController _savesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshPlayers();
  }

  void _refreshPlayers() {
    setState(() {
      _playersFuture = databaseServices.getPlayers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    // Batting controllers
    _hitsController.dispose();
    _atBatsController.dispose();
    _homeRunsController.dispose();
    _rbiController.dispose();
    _runsController.dispose();
    _stolenBasesController.dispose();
    _hbpController.dispose();
    _sfController.dispose();
    _bbController.dispose();
    // Pitching controllers
    _winsController.dispose();
    _lossesController.dispose();
    _eraController.dispose();
    _strikeoutsController.dispose();
    _walksController.dispose();
    _inningsPitchedController.dispose();
    _savesController.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _nameController.clear();
    // Clear batting stats
    _hitsController.clear();
    _atBatsController.clear();
    _homeRunsController.clear();
    _rbiController.clear();
    _runsController.clear();
    _stolenBasesController.clear();
    _hbpController.clear();
    _sfController.clear();
    _bbController.clear();
    // Clear pitching stats
    _winsController.clear();
    _lossesController.clear();
    _eraController.clear();
    _strikeoutsController.clear();
    _walksController.clear();
    _inningsPitchedController.clear();
    _savesController.clear();
    _isPitcher = false;
  }

  double? _calculateAverage() {
    final hits = int.tryParse(_hitsController.text);
    final atBats = int.tryParse(_atBatsController.text);
    if (hits != null && atBats != null && atBats > 0) {
      return hits / atBats;
    }
    return null;
  }

  double? _calculateWhip() {
    final walks = int.tryParse(_walksController.text);
    final hits = int.tryParse(_hitsController.text);
    final innings = int.tryParse(_inningsPitchedController.text);
    if (walks != null && hits != null && innings != null && innings > 0) {
      return (walks + (hits)) / innings;
    }
    return null;
  }

  Widget _buildBattingFields() {
    return Column(
      children: [
        TextField(
          controller: _hitsController,
          decoration: const InputDecoration(labelText: 'Hits'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _atBatsController,
          decoration: const InputDecoration(labelText: 'Turnos al bate'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _homeRunsController,
          decoration: const InputDecoration(labelText: 'Jonrones'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _rbiController,
          decoration: const InputDecoration(labelText: 'Carreras impulsadas'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _runsController,
          decoration: const InputDecoration(labelText: 'Carreras anotadas'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _stolenBasesController,
          decoration: const InputDecoration(labelText: 'Bases robadas'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _hbpController,
          decoration: const InputDecoration(
              labelText: 'Golpeado por lanzamiento (HBP)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _sfController,
          decoration:
              const InputDecoration(labelText: 'Elevado de sacrificio (SF)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bbController,
          decoration: const InputDecoration(labelText: 'Base por bolas (BB)'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPitchingFields() {
    return Column(
      children: [
        TextField(
          controller: _winsController,
          decoration: const InputDecoration(labelText: 'Victorias'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _lossesController,
          decoration: const InputDecoration(labelText: 'Derrotas'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _eraController,
          decoration: const InputDecoration(labelText: 'ERA'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _strikeoutsController,
          decoration: const InputDecoration(labelText: 'Ponches'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _walksController,
          decoration: const InputDecoration(labelText: 'Bases por bolas'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inningsPitchedController,
          decoration: const InputDecoration(labelText: 'Innings lanzados'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _savesController,
          decoration: const InputDecoration(labelText: 'Salvados'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jugadores'),
      ),
      body: _playerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Agregar jugador'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del jugador',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('¿Es lanzador?'),
                        value: _isPitcher,
                        onChanged: (bool value) {
                          setState(() {
                            _isPitcher = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_isPitcher)
                        _buildPitchingFields()
                      else
                        _buildBattingFields(),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearControllers();
                    },
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_nameController.text.isEmpty) return;

                      final player = Player(
                        name: _nameController.text,
                        isPitcher: _isPitcher,
                        // Batting stats
                        hits: int.tryParse(_hitsController.text),
                        atBats: int.tryParse(_atBatsController.text),
                        homeRuns: int.tryParse(_homeRunsController.text),
                        rbi: int.tryParse(_rbiController.text),
                        runs: int.tryParse(_runsController.text),
                        stolenBases: int.tryParse(_stolenBasesController.text),
                        hbp: int.tryParse(_hbpController.text),
                        sf: int.tryParse(_sfController.text),
                        bb: int.tryParse(_bbController.text),
                        average: _calculateAverage(),
                        // Pitching stats
                        wins: int.tryParse(_winsController.text),
                        losses: int.tryParse(_lossesController.text),
                        era: double.tryParse(_eraController.text),
                        strikeouts: int.tryParse(_strikeoutsController.text),
                        walks: int.tryParse(_walksController.text),
                        inningsPitched:
                            int.tryParse(_inningsPitchedController.text),
                        saves: int.tryParse(_savesController.text),
                        whip: _calculateWhip(),
                      );

                      try {
                        await databaseServices.addPlayer(player);
                        if (mounted) {
                          Navigator.pop(context);
                          _refreshPlayers();
                        }
                      } catch (e) {
                        print('Error agregando jugador: $e');
                      } finally {
                        _clearControllers();
                      }
                    },
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _playerList() {
    return FutureBuilder<List<Player>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final player = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(player.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlayerDetailsScreen(player: player),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editPlayer(player);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await databaseServices.deletePlayer(player.id!);
                          _refreshPlayers();
                        },
                      ),
                    ],
                  ),
                  subtitle: Text(
                    player.isPitcher
                        ? 'V-D: ${player.wins ?? 0}-${player.losses ?? 0}, ERA: ${player.era?.toStringAsFixed(2) ?? "0.00"}'
                        : 'AVG: ${(player.average ?? 0).toStringAsFixed(3)}, HR: ${player.homeRuns ?? 0}, RBI: ${player.rbi ?? 0}',
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _editPlayer(Player player) {
    // Pre-fill the controllers
    _nameController.text = player.name;
    _isPitcher = player.isPitcher;

    if (player.isPitcher) {
      _winsController.text = player.wins?.toString() ?? '';
      _lossesController.text = player.losses?.toString() ?? '';
      _eraController.text = player.era?.toString() ?? '';
      _strikeoutsController.text = player.strikeouts?.toString() ?? '';
      _walksController.text = player.walks?.toString() ?? '';
      _inningsPitchedController.text = player.inningsPitched?.toString() ?? '';
      _savesController.text = player.saves?.toString() ?? '';
    } else {
      _hitsController.text = player.hits?.toString() ?? '';
      _atBatsController.text = player.atBats?.toString() ?? '';
      _homeRunsController.text = player.homeRuns?.toString() ?? '';
      _rbiController.text = player.rbi?.toString() ?? '';
      _runsController.text = player.runs?.toString() ?? '';
      _stolenBasesController.text = player.stolenBases?.toString() ?? '';
      _hbpController.text = player.hbp?.toString() ?? '';
      _sfController.text = player.sf?.toString() ?? '';
      _bbController.text = player.bb?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Editar jugador'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del jugador',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('¿Es lanzador?'),
                  value: _isPitcher,
                  onChanged: (bool value) {
                    setDialogState(() {
                      _isPitcher = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_isPitcher)
                  _buildPitchingFields()
                else
                  _buildBattingFields(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _clearControllers();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) return;

                final updatedPlayer = Player(
                  id: player.id,
                  name: _nameController.text,
                  isPitcher: _isPitcher,
                  // Batting stats
                  hits: int.tryParse(_hitsController.text),
                  atBats: int.tryParse(_atBatsController.text),
                  homeRuns: int.tryParse(_homeRunsController.text),
                  rbi: int.tryParse(_rbiController.text),
                  runs: int.tryParse(_runsController.text),
                  stolenBases: int.tryParse(_stolenBasesController.text),
                  hbp: int.tryParse(_hbpController.text),
                  sf: int.tryParse(_sfController.text),
                  bb: int.tryParse(_bbController.text),
                  average: _calculateAverage(),
                  // Pitching stats
                  wins: int.tryParse(_winsController.text),
                  losses: int.tryParse(_lossesController.text),
                  era: double.tryParse(_eraController.text),
                  strikeouts: int.tryParse(_strikeoutsController.text),
                  walks: int.tryParse(_walksController.text),
                  inningsPitched: int.tryParse(_inningsPitchedController.text),
                  saves: int.tryParse(_savesController.text),
                  whip: _calculateWhip(),
                );

                try {
                  await databaseServices.updatePlayer(updatedPlayer);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    _refreshPlayers();
                  }
                } catch (e) {
                  print('Error actualizando jugador: $e');
                } finally {
                  _clearControllers();
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
