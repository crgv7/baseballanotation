import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/my_team.dart';
import '../../services/database_services.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  late Future<MyTeam?> _teamFuture;

  @override
  void initState() {
    super.initState();
    _teamFuture = _databaseServices.getMyTeam();
  }

  Future<void> _refreshTeam() async {
    setState(() {
      _teamFuture = _databaseServices.getMyTeam();
    });
  }

  Future<void> _showTeamDialog([MyTeam? team]) async {
    final nameController = TextEditingController(text: team?.name ?? '');
    final winsController = TextEditingController(text: team?.wins.toString() ?? '0');
    final lossesController = TextEditingController(text: team?.losses.toString() ?? '0');
    final runsScoredController = TextEditingController(text: team?.runsScored.toString() ?? '0');
    final runsAllowedController = TextEditingController(text: team?.runsAllowed.toString() ?? '0');
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
        title: Text(team == null ? 'Crear Mi Equipo' : 'Editar Mi Equipo'),
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
                controller: runsScoredController,
                decoration: const InputDecoration(labelText: 'Carreras Anotadas'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: runsAllowedController,
                decoration: const InputDecoration(labelText: 'Carreras Permitidas'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final newImageUrl = await _pickAndSaveImage();
                  if (newImageUrl != null) {
                    imageUrl = newImageUrl;
                    setState(() {});
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
              final runsScored = int.tryParse(runsScoredController.text) ?? 0;
              final runsAllowed = int.tryParse(runsAllowedController.text) ?? 0;

              final newTeam = MyTeam(
                id: team?.id,
                name: name,
                imageUrl: imageUrl,
                wins: wins,
                losses: losses,
                runsScored: runsScored,
                runsAllowed: runsAllowed,
              );

              if (team == null) {
                await _databaseServices.saveMyTeam(newTeam);
              } else {
                await _databaseServices.updateMyTeam(newTeam);
              }

              if (!mounted) return;
              Navigator.pop(context);
              _refreshTeam();
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
        title: const Text('Mi Equipo'),
      ),
      body: FutureBuilder<MyTeam?>(
        future: _teamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final team = snapshot.data;
          if (team == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No has creado tu equipo aún'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showTeamDialog(),
                    child: const Text('Crear Mi Equipo'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      if (team.imageUrl != null)
                        ClipOval(
                          child: Image.file(
                            File(team.imageUrl!),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.sports_baseball, size: 60),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('Victorias', team.wins.toString()),
                        _buildStatRow('Derrotas', team.losses.toString()),
                        _buildStatRow('Carreras Anotadas', team.runsScored.toString()),
                        _buildStatRow('Carreras Permitidas', team.runsAllowed.toString()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showTeamDialog(team),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('¿Desea eliminar su equipo?'),
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
                          await _databaseServices.deleteMyTeam();
                          _refreshTeam();
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
