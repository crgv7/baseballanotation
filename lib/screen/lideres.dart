import 'package:baseballanotation/models/player.dart';
import 'package:baseballanotation/services/database_services.dart';
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
                                      _selectedOption =
                                          value! ? "RBI" : null;
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
                                }
                              ),
                              CheckboxListTile(
                                value: _selectedOption == "Losses",
                                title: Text("Losses"),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value! ? "Losses" : null;
                                  });
                                  if (value!) {
                                    this.setState(() {
                                      _playersFuture = DatabaseServices
                                          .instance
                                          .getPlayersByLosses();
                                    });
                                  }
                                }
                              ),
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
                                }
                              ),
                              CheckboxListTile(
                                value: _selectedOption == "Strikeouts",
                                title: Text("Strikeouts"),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value! ? "Strikeouts" : null;
                                  });
                                  if (value!) {
                                    this.setState(() {
                                      _playersFuture = DatabaseServices
                                          .instance
                                          .getPlayersByStrikeouts();
                                    });
                                  }
                                }
                              ),
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
                                }
                              ),
                              CheckboxListTile(
                                value: _selectedOption == "InningsPitched",
                                title: Text("Innings Pitched"),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value! ? "InningsPitched" : null;
                                  });
                                  if (value!) {
                                    this.setState(() {
                                      _playersFuture = DatabaseServices
                                          .instance
                                          .getPlayersByInningsPitched();
                                    });
                                  }
                                }
                              ),
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
                                }
                              ),
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
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final player = snapshot.data![index];
              return ListTile(
                title: Text(player.name),
                subtitle: Text(
                  _selectedOption == "Home Runs" ? "HR: ${player.homeRuns}" :
                  _selectedOption == "Hits" ? "H: ${player.hits}" :
                  _selectedOption == "At Bats" ? "AB: ${player.atBats}" :
                  _selectedOption == "RBI" ? "RBI: ${player.rbi}" :
                  _selectedOption == "Wins" ? "W: ${player.wins}" :
                  _selectedOption == "Losses" ? "L: ${player.losses}" :
                  _selectedOption == "ERA" ? "ERA: ${player.era}" :
                  _selectedOption == "Strikeouts" ? "K: ${player.strikeouts}" :
                  _selectedOption == "Walks" ? "BB: ${player.walks}" :
                  _selectedOption == "InningsPitched" ? "IP: ${player.inningsPitched}" :
                  _selectedOption == "Saves" ? "SV: ${player.saves}" : ""
                ),
              );
            },
          );
        } else {
          return Text('No data available');
        }
      },
    );
  }
}
