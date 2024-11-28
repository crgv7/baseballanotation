import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/team.dart';
import '../../services/database_services.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  late Future<List<Team>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _databaseServices.getTeams();
  }

  Future<void> _refreshTeams() async {
    setState(() {
      _teamsFuture = _databaseServices.getTeams();
    });
  }

  Future<void> _showTeamDialog([Team? team]) async {
    final nameController = TextEditingController(text: team?.name ?? '');
    final winsController = TextEditingController(text: team?.wins.toString() ?? '0');
    final lossesController = TextEditingController(text: team?.losses.toString() ?? '0');
    final runsController = TextEditingController(text: team?.runs.toString() ?? '0');
    String? imageUrl = team?.imageUrl;

    Future<String?> _pickAndSaveImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(image.path);
        final String savedPath = path.join(appDir.path, fileName);
        
        await File(image.path).copy(savedPath);
        return savedPath;
      }
      return null;
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(team == null ? 'Nuevo Equipo' : 'Editar Equipo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Equipo'),
              ),
              TextField(
                controller: winsController,
                decoration: const InputDecoration(labelText: 'Victorias'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lossesController,
                decoration: const InputDecoration(labelText: 'Derrotas'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: runsController,
                decoration: const InputDecoration(labelText: 'Carreras'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final newImageUrl = await _pickAndSaveImage();
                  if (newImageUrl != null) {
                    imageUrl = newImageUrl;
                  }
                },
                child: const Text('Seleccionar Imagen'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                return;
              }

              final wins = int.tryParse(winsController.text) ?? 0;
              final losses = int.tryParse(lossesController.text) ?? 0;
              final runs = int.tryParse(runsController.text) ?? 0;

              final newTeam = Team(
                id: team?.id,
                name: name,
                imageUrl: imageUrl,
                wins: wins,
                losses: losses,
                runs: runs,
              );

              if (team == null) {
                await _databaseServices.addTeam(newTeam);
              } else {
                await _databaseServices.updateTeam(newTeam);
              }

              if (!mounted) return;
              Navigator.pop(context);
              _refreshTeams();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
      ),
      body: FutureBuilder<List<Team>>(
        future: _teamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay equipos registrados'));
          }

          final teams = snapshot.data!;
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: team.imageUrl != null
                      ? ClipOval(
                          child: Image.file(
                            File(team.imageUrl!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.sports_baseball),
                        ),
                  title: Text(team.name),
                  subtitle: Text(
                    'V: ${team.wins} - D: ${team.losses} - C: ${team.runs}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTeamDialog(team),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar'),
                              content: const Text('¿Desea eliminar este equipo?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _databaseServices.deleteTeam(team.id!);
                            _refreshTeams();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTeamDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
