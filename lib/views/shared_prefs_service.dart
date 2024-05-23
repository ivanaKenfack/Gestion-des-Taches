import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_de_taches/models/Project.dart';
import 'package:gestion_de_taches/models/user.dart';

class SharedPrefsService {
  static const String _projectsKey = 'projects';
  static const String _loginKey = 'isLoggedIn';
  static const String _usernameKey = 'username';
  static const String _usersKey = 'users';

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = projects.map((project) => jsonEncode(project.toJson())).toList();
    prefs.setStringList(_projectsKey, projectsJson);
  }

  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getStringList(_projectsKey);
    if (projectsJson != null) {
      return projectsJson.map((json) => Project.fromJson(jsonDecode(json))).toList();
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


}
