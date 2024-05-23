// models/project.dart
import 'dart:convert';

import 'Task.dart';

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

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'],
      members: List<String>.from(json['members']),
      description: json['description'],
      tasks: (json['tasks'] as List<dynamic>)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'members': members,
      'description': description,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  static String encode(List<Project> projects) => json.encode(
    projects.map<Map<String, dynamic>>((project) => project.toJson()).toList(),
  );

  static List<Project> decode(String projects) =>
      (json.decode(projects) as List<dynamic>)
          .map<Project>((item) => Project.fromJson(item))
          .toList();

}
