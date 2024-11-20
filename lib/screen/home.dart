import 'package:baseballanotation/models/task.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';

class Home extends StatelessWidget {

  final DatabaseServices databaseServices = DatabaseServices.instance;

  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_)=>AlertDialog(
            title: const Text('Add Task'),
            content: TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(hintText: 'Task'),
            ),
            actions: [
              TextButton(onPressed: (){}, child: const Text('Cancel')),
              TextButton(onPressed: (){}, child: const Text('Add'))
            ],
          ));
        },
        child: const Icon(Icons.add),
      )
    );
  }

  Widget _taskList() {
    return FutureBuilder(
      future: databaseServices.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length ?? 0,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return ListTile(
                title: Text(task.title),
                trailing: IconButton(onPressed: (){}, icon: const Icon(Icons.delete))

                
              );
            },
          ); 
        } else {
          return const CircularProgressIndicator();
        }
      },
    );

  }
}