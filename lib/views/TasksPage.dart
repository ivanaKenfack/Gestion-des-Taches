import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_de_taches/models/Task.dart'; // Assurez-vous d'importer le fichier Task correctement

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks');
    print('Loaded tasks JSON: $tasksJson'); // Debug print
    if (tasksJson != null) {
      setState(() {
        _tasks = tasksJson.map((json) {
          print('Decoding task JSON: $json'); // Debug print
          return Task.fromJson(Map<String, dynamic>.from(jsonDecode(json)));
        }).toList();
        print('Tasks loaded: $_tasks'); // Debug print
      });
    } else {
      _tasks = [];
      print('No tasks found, initialized with empty list.'); // Debug print
    }
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) {
      final json = jsonEncode(task.toJson());
      print('Encoding task to JSON: $json'); // Debug print
      return json;
    }).toList();
    await prefs.setStringList('tasks', tasksJson.cast<String>());
    print('Tasks saved: $tasksJson'); // Debug print
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _filter = 'Tout';

  void _addTask() {
    setState(() {
      _tasks.add(Task(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        assignedTo: '',
      ));
      _titleController.clear();
      _descriptionController.clear();
    });
    _saveTasks(); // Save tasks immediately after adding
    Navigator.of(context).pop();
  }

  void _updateTask(Task task, int index) {
    setState(() {
      _tasks[index] = task;
    });
    _saveTasks(); // Save tasks immediately after updating
    Navigator.of(context).pop();
  }

  void _showAddTaskDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une tâche'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            Text('Date d\'échéance: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: const Text('Choisir une date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Task task, int index) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la tâche'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            Text('Date d\'échéance: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: const Text('Choisir une date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateTask(
                Task(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  dueDate: _selectedDate,
                  isCompleted: task.isCompleted,
                  assignedTo: '',
                ),
                index,
              );
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks;
    if (_filter == 'En cours') {
      filteredTasks = _tasks.where((task) => !task.isCompleted).toList();
    } else if (_filter == 'Terminé') {
      filteredTasks = _tasks.where((task) => task.isCompleted).toList();
    } else {
      filteredTasks = _tasks;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FilterChip(
                    label: const Text('Tout'),
                    onSelected: (bool value) {
                      setState(() {
                        _filter = 'Tout';
                      });
                    },
                    selected: _filter == 'Tout',
                  ),
                  FilterChip(
                    label: const Text('En cours'),
                    onSelected: (bool value) {
                      setState(() {
                        _filter = 'En cours';
                      });
                    },
                    selected: _filter == 'En cours',
                  ),
                  FilterChip(
                    label: const Text('Terminé'),
                    onSelected: (bool value) {
                      setState(() {
                        _filter = 'Terminé';
                      });
                    },
                    selected: _filter == 'Terminé',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          setState(() {
                            task.isCompleted = value!;
                            _saveTasks(); // Save tasks immediately after changing completion status
                          });
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.description),
                          Text('Échéance: ${DateFormat('dd/MM/yyyy').format(task.dueDate)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditTaskDialog(task, _tasks.indexOf(task));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
