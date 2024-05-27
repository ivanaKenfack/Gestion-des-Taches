import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AgendaPage(),
    );
  }
}

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final Map<DateTime, List<Meeting>> _meetings = {};

  void _addMeeting() {
    final objective = _objectiveController.text;
    final participants = _participantsController.text.split(',');

    if (objective.isNotEmpty && participants.isNotEmpty && _selectedDay != null) {
      setState(() {
        if (_meetings[_selectedDay!] == null) {
          _meetings[_selectedDay!] = [];
        }
        _meetings[_selectedDay!]!.add(Meeting(
          objective: objective,
          participants: participants.map((e) => e.trim()).toList(),
          date: _selectedDay!,
        ));
        _objectiveController.clear();
        _participantsController.clear();
      });
    }
  }

  List<Meeting> _getMeetingsForDay(DateTime day) {
    return _meetings[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
              });
            },
            calendarFormat: CalendarFormat.week,
          ),
          Expanded(
            child: ListView(
              children: _getMeetingsForDay(_selectedDay ?? _focusedDay)
                  .map((meeting) => Card(
                child: ListTile(
                  title: Text(meeting.objective),
                  subtitle: Text(
                      'Participants: ${meeting.participants.join(', ')}'),
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Ajouter une réunion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _objectiveController,
                    decoration: const InputDecoration(labelText: 'Objectif'),
                  ),
                  TextField(
                    controller: _participantsController,
                    decoration: const InputDecoration(
                        labelText: 'Participants (séparés par des virgules)'),
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
                  onPressed: () {
                    _addMeeting();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Meeting {
  final String objective;
  final List<String> participants;
  final DateTime date;

  Meeting({
    required this.objective,
    required this.participants,
    required this.date,
  });
}

