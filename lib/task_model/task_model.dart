class TaskModel {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String priority;
  final String userId; // New field for user ID
  late final bool isCompleted;

  TaskModel(
    this.id,
    this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.userId, { // Include userId
    this.isCompleted = false,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    String? userId,
    bool? isCompleted,
  }) {
    return TaskModel(
      id ?? this.id,
      title ?? this.title,
      description ?? this.description,
      dueDate ?? this.dueDate,
      priority ?? this.priority,
      userId ?? this.userId, // Copy userId
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'userId': userId, // Store userId
      'isCompleted': isCompleted,
    };
  }

  static TaskModel fromMap(String id, Map<dynamic, dynamic> map) {
    return TaskModel(
      id,
      map['title'] ?? '',
      map['description'] ?? '',
      map['dueDate'] ?? DateTime.now().toIso8601String().split('T').first,
      map['priority'] ?? 'Low',
      map['userId'] ?? '', // Fetch userId
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
