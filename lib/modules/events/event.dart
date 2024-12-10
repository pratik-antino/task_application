import 'package:task_application/modules/task/model/comment_model.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> participants;
  final String ownerId;
  final List<String> sharedWith;
  final List<Comment> comments;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.participants,
    required this.ownerId,
    required this.sharedWith,
    this.comments=const [],
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
      comments: (json['comments'] as List?)
              ?.map((commentJson) => Comment.fromJson(commentJson))
              .toList() ??
          [], // Parse comments from JSON (if any).
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
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}
