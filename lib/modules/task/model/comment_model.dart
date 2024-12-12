class Comment {
  final String id;
  final String content;
  final String createdByName;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.createdByName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      content: json['content'],
      createdByName: json['createdBy']['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
