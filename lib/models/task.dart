class Task {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String status;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
    );
  }
}
