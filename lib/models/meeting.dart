
class Meeting {
  late final String objective;
  late final List<String> participants;
  final DateTime date;

  Meeting({
    required this.objective,
    required this.participants,
    required this.date,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      objective: json['objective'],
      participants: List<String>.from(json['participants']),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objective': objective,
      'participants': participants,
      'date': date.toIso8601String(),
    };
  }
}
