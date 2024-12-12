import 'comment_model.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String createdBy;
  final String priority;
  final String status;
  final DateTime dueDate;
  final bool isCompleted;
  final List<Comment> comments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.createdBy,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.isCompleted,
    this.comments = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      assignedTo: json['assignedTo']['_id'], // Fetch nested _id field
      createdBy: json['createdBy']['_id'], // Fetch nested _id field
      priority: json['priority'],
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((comment) => Comment.fromJson(comment))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'priority': priority,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? createdBy,
    String? priority,
    String? status,
    DateTime? dueDate,
    bool? isCompleted,
    List<Comment>? comments,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      comments: comments ?? this.comments,
    );
  }
}
