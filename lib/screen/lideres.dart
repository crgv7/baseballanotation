import 'package:baseballScore/models/player.dart';
import 'package:baseballScore/services/database_services.dart';
import 'package:flutter/material.dart';

class Lideres extends StatefulWidget {
  Lideres({Key? key}) : super(key: key);

  @override
  State<Lideres> createState() => _LideresState();
}

class _LideresState extends State<Lideres> {
  final DatabaseServices databaseServices = DatabaseServices.instance;

  String? _selectedOption;
  late Future<List<Player>> _playersFuture =
      DatabaseServices.instance.getPlayersByHomeRuns();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lideres"),
      ),
      body: Container(
        child: Center(child: _listPlayer()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                        title: Text("Ordenar por"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //crear checkbox para cada opcion
                              CheckboxListTile(
                                  value: _selectedOption == "Home Runs",
                                  title: Text("Home Runs"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption =
                                          value! ? "Home Runs" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByHomeRuns();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "Hits",
                                  title: Text("Hits"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value! ? "Hits" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByHits();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "At Bats",
                                  title: Text("At Bats"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption =
                                          value! ? "At Bats" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByAtBats();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "RBI",
                                  title: Text("RBI"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value! ? "RBI" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByRbi();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "Wins",
                                  title: Text("Wins"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value! ? "Wins" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByWins();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "Losses",
                                  title: Text("Losses"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption =
                                          value! ? "Losses" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByLosses();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "ERA",
                                  title: Text("ERA"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value! ? "ERA" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByEra();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "Strikeouts",
                                  title: Text("Strikeouts"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption =
                                          value! ? "Strikeouts" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByStrikeouts();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "Walks",
                                  title: Text("Walks"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value! ? "Walks" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByWalks();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "InningsPitched",
                                  title: Text("Innings Pitched"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption =
                                          value! ? "InningsPitched" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersByInningsPitched();
                                      });
                                    }
                                  }),
                              CheckboxListTile(
                                  value: _selectedOption == "Saves",
                                  title: Text("Saves"),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value! ? "Saves" : null;
                                    });
                                    if (value!) {
                                      this.setState(() {
                                        _playersFuture = DatabaseServices
                                            .instance
                                            .getPlayersBySaves();
                                      });
                                    }
                                  }),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancelar")),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Aceptar")),
                        ],
                      )));
        },
        child: Icon(Icons.more_vert),
      ),
    );
  }

  Widget _listPlayer() {
    return FutureBuilder<List<Player>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final player = snapshot.data![index];
              String statValue = ''; // El valor de la estadística a mostrar
              String statLabel = ''; // La etiqueta para mostrar la estadística

              // Determinar qué estadística mostrar basado en la selección
              // _selectedOption es la opción seleccionada por el usuario en el
              // diálogo de selección de estadísticas
              switch (_selectedOption) {
                case "Home Runs":
                  statValue =
                      "${player.homeRuns ?? 0}"; // Mostrar el número de Home Runs
                  statLabel = "HR"; // La etiqueta es "HR"
                  break;
                case "Hits":
                  statValue =
                      "${player.hits ?? 0}"; // Mostrar el número de Hits
                  statLabel = "H"; // La etiqueta es "H"
                  break;
                case "At Bats":
                  statValue =
                      "${player.atBats ?? 0}"; // Mostrar el número de At Bats
                  statLabel = "AB"; // La etiqueta es "AB"
                  break;
                case "RBI":
                  statValue = "${player.rbi ?? 0}"; // Mostrar el número de RBI
                  statLabel = "RBI"; // La etiqueta es "RBI"
                  break;
                case "Wins":
                  statValue =
                      "${player.wins ?? 0}"; // Mostrar el número de Wins
                  statLabel = "W"; // La etiqueta es "W"
                  break;
                case "Losses":
                  statValue =
                      "${player.losses ?? 0}"; // Mostrar el número de Losses
                  statLabel = "L"; // La etiqueta es "L"
                  break;
                case "ERA":
                  statValue =
                      "${player.era?.toStringAsFixed(2) ?? "0.00"}"; // Mostrar el ERA con 2 decimales
                  statLabel = "ERA"; // La etiqueta es "ERA"
                  break;
                case "Strikeouts":
                  statValue =
                      "${player.strikeouts ?? 0}"; // Mostrar el número de Strikeouts
                  statLabel = "K"; // La etiqueta es "K"
                  break;
                case "Walks":
                  statValue =
                      "${player.walks ?? 0}"; // Mostrar el número de Walks
                  statLabel = "BB"; // La etiqueta es "BB"
                  break;
                case "InningsPitched":
                  statValue =
                      "${player.inningsPitched ?? 0}"; // Mostrar el número de Innings Pitched
                  statLabel = "IP"; // La etiqueta es "IP"
                  break;
                case "Saves":
                  statValue =
                      "${player.saves ?? 0}"; // Mostrar el número de Saves
                  statLabel = "SV"; // La etiqueta es "SV"
                  break;
                default:
                  statValue =
                      "${player.homeRuns ?? 0}"; // Por defecto, mostrar el número de Home Runs
                  statLabel = "HR"; // La etiqueta es "HR"
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        Theme.of(context).colorScheme.primary,
                      ],
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            statValue,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statLabel,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No hay datos disponibles'));
        }
      },
    );
  }
}
