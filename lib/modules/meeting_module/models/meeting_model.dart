import 'package:googleapis/calendar/v3.dart' as api;

class Meeting {
  final String id;
  final String summary;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String meetLink;

  Meeting({
    required this.id,
    required this.summary,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.meetLink,
  });

  factory Meeting.fromEvent(api.Event event) {
    return Meeting(
      id: event.id ?? '',
      summary: event.summary ?? 'No Title',
      description: event.description ?? 'No Description',
      startTime: event.start?.dateTime ?? DateTime.now(),
      endTime: event.end?.dateTime ?? DateTime.now(),
      meetLink: event.hangoutLink ?? '',
    );
  }
}
