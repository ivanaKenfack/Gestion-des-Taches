// lib/views/shared_prefs_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_de_taches/models/meeting.dart';
import 'package:gestion_de_taches/models/Project.dart';
import 'package:gestion_de_taches/models/user.dart';
import 'package:gestion_de_taches/models/Task.dart';

class SharedPrefsService {
  static const String _projectsPrefixKey = 'projects_';
  static const String _tasksPrefixKey = 'tasks_';
  static const String _loginKey = 'isLoggedIn';
  static const String _usernameKey = 'username';
  static const String _usersKey = 'users';
  static const String _meetingsPrefixKey = 'meetings_';

  Future<void> saveProjects(String username, List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = projects.map((project) => jsonEncode(project.toJson())).toList();
    prefs.setStringList('$_projectsPrefixKey$username', projectsJson);
  }

  Future<List<Project>> loadProjects(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getStringList('$_projectsPrefixKey$username');
    if (projectsJson != null) {
      return projectsJson.map((json) => Project.fromJson(jsonDecode(json))).toList();
    } else {
      return [];
    }
  }

  Future<void> saveTasks(String username, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    prefs.setStringList('$_tasksPrefixKey$username', tasksJson);
  }

  Future<List<Task>> loadTasks(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('$_tasksPrefixKey$username');
    if (tasksJson != null) {
      return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
    } else {
      return [];
    }
  }

  Future<void> saveLoginState(bool isLoggedIn, String username) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_loginKey, isLoggedIn);
    prefs.setString(_usernameKey, username);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_loginKey);
    prefs.remove(_usernameKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await loadUsers();
    users.add(user);
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    prefs.setStringList(_usersKey, usersJson);
  }

  Future<List<User>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey);
    if (usersJson != null) {
      return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
    } else {
      return [];
    }
  }

  Future<bool> userExists(String username) async {
    final users = await loadUsers();
    return users.any((user) => user.username == username);
  }

  Future<User?> getUser(String username) async {
    final users = await loadUsers();
    for (var user in users) {
      if (user.username == username) {
        return user;
      }
    }
    return null;
  }

  // Méthodes pour sauvegarder et charger les réunions par utilisateur
  Future<void> saveMeetings(String username, Map<DateTime, List<Meeting>> meetings) async {
    final prefs = await SharedPreferences.getInstance();
    final meetingsMap = meetings.map((key, value) =>
        MapEntry(key.toIso8601String(), value.map((meeting) => jsonEncode(meeting.toJson())).toList()));
    prefs.setString('$_meetingsPrefixKey$username', jsonEncode(meetingsMap));
  }

  Future<Map<DateTime, List<Meeting>>> loadMeetings(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final meetingsString = prefs.getString('$_meetingsPrefixKey$username');
    if (meetingsString != null) {
      final Map<String, dynamic> meetingsMap = jsonDecode(meetingsString);
      return meetingsMap.map((key, value) =>
          MapEntry(DateTime.parse(key), (value as List).map((item) => Meeting.fromJson(jsonDecode(item))).toList()));
    }
    return {};
  }
}
