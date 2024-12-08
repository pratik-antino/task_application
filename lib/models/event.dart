class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> participants;
  final String ownerId;
  final List<String> sharedWith;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.participants,
    required this.ownerId,
    required this.sharedWith,
  });

  // Convert JSON to Event object
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      participants: List<String>.from(json['participants'] ?? []),
      ownerId: json['ownerId'],
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
    );
  }

  // Convert Event object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'participants': participants,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
    };
  }
}
