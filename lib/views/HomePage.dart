import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userName = 'Ivana'; // Nom de l'utilisateur connecté
  final List<Project> projects = [
    Project(
      name: 'Project Alpha',
      members: ['Alice', 'Bob', 'Charlie'],
      description: 'Description of Project Alpha',
    ),
    Project(
      name: 'Project Beta',
      members: ['Dave', 'Eve', 'Frank'],
      description: 'Description of Project Beta',
    ),
    // Ajoutez d'autres projets ici
  ];

  void _addProject(Project project) {
    setState(() {
      projects.add(project);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bonjour, $userName!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(project: projects[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddProjectDialog(onAddProject: _addProject),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              project.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Membres:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              project.members.join(', '),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailPage(project: project),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Voir la description',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddProjectDialog extends StatefulWidget {
  final Function(Project) onAddProject;

  const AddProjectDialog({required this.onAddProject});

  @override
  _AddProjectDialogState createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();

  void _submit() {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final members = _membersController.text.split(',');

    if (name.isNotEmpty && description.isNotEmpty && members.isNotEmpty) {
      final newProject = Project(
        name: name,
        members: members.map((e) => e.trim()).toList(),
        description: description,
      );
      widget.onAddProject(newProject);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un projet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du projet'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description du projet'),
          ),
          TextField(
            controller: _membersController,
            decoration: const InputDecoration(
              labelText: 'Membres (séparés par des virgules)',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({required this.project});

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedMember = '';

  void _addTask() {
    final taskName = _taskController.text;
    if (taskName.isNotEmpty && _selectedMember.isNotEmpty) {
      setState(() {
        widget.project.tasks.add(Task(name: taskName, assignedTo: _selectedMember));
        _taskController.clear();
        _selectedMember = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.project.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Membres du projet:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.project.members.join(', '),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ajouter une tâche:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Nom de la tâche',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedMember.isEmpty ? null : _selectedMember,
              hint: const Text('Assigner à un membre'),
              items: widget.project.members.map((String member) {
                return DropdownMenuItem<String>(
                  value: member,
                  child: Text(member),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMember = newValue!;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Ajouter la tâche'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tâches:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.project.tasks.length,
                itemBuilder: (context, index) {
                  final task = widget.project.tasks[index];
                  return ListTile(
                    title: Text(task.name),
                    subtitle: Text('Assignée à: ${task.assignedTo}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Project {
  final String name;
  final List<String> members;
  final String description;
  final List<Task> tasks;

  Project({
    required this.name,
    required this.members,
    required this.description,
    this.tasks = const [],
  });
}

class Task {
  final String name;
  final String assignedTo;

  Task({
    required this.name,
    required this.assignedTo,
  });
}
