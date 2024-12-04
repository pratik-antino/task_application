class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> participants;
  final String ownerId;
  final List<String> sharedWith;
  final String? meetingLink;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.participants,
    required this.ownerId,
    required this.sharedWith,
    this.meetingLink, required createdBy,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      createdBy: '',
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      participants: List<String>.from(json['participants']),
      ownerId: json['ownerId'],
      sharedWith: List<String>.from(json['sharedWith']),
      meetingLink: json['meetingLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'participants': participants,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
      'meetingLink': meetingLink,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? participants,
    String? ownerId,
    List<String>? sharedWith,
    String? meetingLink,
  }) {
    return Event(
      createdBy: '',
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      participants: participants ?? this.participants,
      ownerId: ownerId ?? this.ownerId,
      sharedWith: sharedWith ?? this.sharedWith,
      meetingLink: meetingLink ?? this.meetingLink,
    );
  }
}

