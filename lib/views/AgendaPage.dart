import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'shared_prefs_service.dart';
import 'package:gestion_de_taches/models/meeting.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final Map<DateTime, List<Meeting>> _meetings = {};
  final SharedPrefsService _prefsService = SharedPrefsService();
  List<Meeting> weekMeetings = [];
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    final username = await _prefsService.getUsername();
    if (username != null) {
      setState(() {
        _username = username;
      });
      _loadMeetings(username);
    }
  }

  void _loadMeetings(String username) async {
    final loadedMeetings = await _prefsService.loadMeetings(username);
    setState(() {
      _meetings.addAll(loadedMeetings);
      _updateWeekMeetings(_focusedDay);
    });
  }

  void _saveMeetings() async {
    if (_username.isNotEmpty) {
      await _prefsService.saveMeetings(_username, _meetings);
    }
  }

  void _updateWeekMeetings(DateTime focusedDay) {
    DateTime startOfWeek = focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
    List<Meeting> meetings = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      meetings.addAll(_getMeetingsForDay(day));
    }
    setState(() {
      weekMeetings = meetings;
    });
  }

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
      _saveMeetings();
      _updateWeekMeetings(_focusedDay);
    }
  }

  void _editMeeting(Meeting meeting) {
    _objectiveController.text = meeting.objective;
    _participantsController.text = meeting.participants.join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la réunion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _objectiveController,
              decoration: const InputDecoration(labelText: 'Objectif'),
            ),
            TextField(
              controller: _participantsController,
              decoration: const InputDecoration(labelText: 'Participants (séparés par des virgules)'),
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
              setState(() {
                meeting.objective = _objectiveController.text;
                meeting.participants = _participantsController.text.split(',').map((e) => e.trim()).toList();
              });
              _saveMeetings();
              _updateWeekMeetings(_focusedDay);
              Navigator.of(context).pop();
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _deleteMeeting(Meeting meeting) {
    setState(() {
      _meetings[meeting.date]!.remove(meeting);
      if (_meetings[meeting.date]!.isEmpty) {
        _meetings.remove(meeting.date);
      }
    });
    _saveMeetings();
    _updateWeekMeetings(_focusedDay);
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
                _focusedDay = focusedDay;
                _updateWeekMeetings(focusedDay);
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _updateWeekMeetings(focusedDay);
              });
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: weekMeetings.length,
              itemBuilder: (context, index) {
                final meeting = weekMeetings[index];
                return Card(
                  child: ListTile(
                    title: Text(meeting.objective),
                    subtitle: Text('Participants: ${meeting.participants.join(', ')}\nDate: ${meeting.date}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editMeeting(meeting),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteMeeting(meeting),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                    decoration: const InputDecoration(labelText: 'Participants (séparés par des virgules)'),
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
