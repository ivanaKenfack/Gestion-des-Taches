import 'package:flutter/material.dart';
import 'package:gestion_de_taches/views/shared_prefs_service.dart';
import 'ConnectionPage.dart';
import 'HomePage.dart';
import 'TasksPage.dart';
import 'AgendaPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPrefsService _prefsService = SharedPrefsService();
  final bool isLoggedIn = await _prefsService.isLoggedIn();
  runApp(NavigationBarApp(isLoggedIn: isLoggedIn));
}

class NavigationBarApp extends StatelessWidget {
  final bool isLoggedIn;
  const NavigationBarApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: isLoggedIn ? const NavigationExample() :  LoginPage(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(), // Page d'accueil distincte
    TasksPage(), // Page Mes Tâches
    AgendaPage(), // Page Agenda
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.task),
            icon: Icon(Icons.task_outlined),
            label: 'Mes Tâches',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_today),
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Agenda',
          ),
        ],
      ),
      body: _pages[currentPageIndex],
    );
  }
}
