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
  late Future<List<Player>> _playersFuture=DatabaseServices.instance.getPlayersByHomeRuns();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lideres"),
      ),
      body: Container(
        child: Center(
          child: _listPlayer()
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (_) => StatefulBuilder(
              builder:(context,setState)=>AlertDialog(
                title: Text("Ordenar por"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    //crear checkbox para cada opcion
                    CheckboxListTile(value: _selectedOption=="Home Runs", title: Text("Home Runs"), onChanged: (value){
                      setState(() {
                       _selectedOption= value! ? "Home Runs" : null;
                      });
                    }),
                    CheckboxListTile(value: _selectedOption=="Hits", title: Text("Hits"), onChanged: (value){
                      setState(() {
                        _selectedOption= value! ? "Hits" : null;
                        _playersFuture=DatabaseServices.instance.getPlayersByHomeRuns();
                      });
                    }),
                    CheckboxListTile(value: _selectedOption=="At Bats", title: Text("At Bats"), onChanged: (value){
                      setState(() {
                        _selectedOption= value! ? "At Bats" : null;
                        _playersFuture=DatabaseServices.instance.getPlayersByAtBats();
                      });
                    }),
                    ],
                  ),
                
                ),
               actions: [
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1866748274.
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Cancelar")),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Aceptar")),
               ],
              )
            )
            );
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

