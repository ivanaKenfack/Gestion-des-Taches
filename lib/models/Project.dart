// models/project.dart
import 'task.dart';

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
