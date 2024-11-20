import 'package:baseballanotation/models/task.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseServices databaseServices = DatabaseServices.instance;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _task;
  String? _content;

  @override
  void dispose() {
    _taskController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _taskList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: const Text('Add Task'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _taskController,
                            onChanged: (value) {
                              setState(() {
                                _task = value;
                              });
                            },
                            decoration: const InputDecoration(hintText: 'Task'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _contentController,
                            onChanged: (value) {
                              setState(() {
                                _content = value;
                              });
                            },
                            decoration:
                                const InputDecoration(hintText: 'Content'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _taskController.clear();
                              _contentController.clear();
                              setState(() {
                                _task = null;
                                _content = null;
                              });
                            },
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              if (_task == null || _task!.isEmpty) return;
                              databaseServices.addTask(_task!, _content ?? '');
                              Navigator.pop(context);
                              _taskController.clear();
                              _contentController.clear();
                              setState(() {
                                _task = null;
                                _content = null;
                              });
                            },
                            child: const Text('Add'))
                      ],
                    ));
          },
          child: const Icon(Icons.add),
        ));
  }

  Widget _taskList() {
    return FutureBuilder(
      future: databaseServices.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.content),
                  onTap: () {
                    _taskController.text = task.title;
                    _contentController.text = task.content;
                    setState(() {
                      _task = task.title;
                      _content = task.content;
                    });
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: const Text('Edit Task'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _taskController,
                                    onChanged: (value) {
                                      setState(() {
                                        _task = value;
                                      });
                                    },
                                    decoration:
                                        const InputDecoration(hintText: 'Task'),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _contentController,
                                    onChanged: (value) {
                                      setState(() {
                                        _content = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        hintText: 'Content'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _taskController.clear();
                                      _contentController.clear();
                                      setState(() {
                                        _task = null;
                                        _content = null;
                                      });
                                    },
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () async {
                                      if (_taskController.text.isEmpty) return;
                                      await databaseServices.updateTask(
                                          task.id!,
                                          _taskController.text,
                                          _contentController.text);
                                      if (mounted) {
                                        Navigator.pop(context);
                                        setState(() {});
                                      }
                                      _taskController.clear();
                                      _contentController.clear();
                                      _task = null;
                                      _content = null;
                                    },
                                    child: const Text('Update'))
                              ],
                            ));
                  },
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          databaseServices.deleteTask(task.id!);
                        });
                      },
                      icon: const Icon(Icons.delete)));
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
