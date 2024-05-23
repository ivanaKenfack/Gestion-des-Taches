import 'dart:math';

class Task {
  String title;
  String description;
  bool isCompleted;
  DateTime dueDate;
  String assignedTo;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.dueDate,
    required this.assignedTo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      dueDate: DateTime.parse(json['dueDate']),
      assignedTo: json['assignedTo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
      'assignedTo': assignedTo,
    };
  }


}
