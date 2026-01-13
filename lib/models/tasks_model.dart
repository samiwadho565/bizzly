class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed
  final DateTime? dueDate;
  final DateTime? createdAt;
  final String assignedTo; // user id / employee id
  final int priority; // 1 = High, 2 = Medium, 3 = Low

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
   this.createdAt,
    required this.assignedTo,
    required this.priority,
  });

  /// 🔹 From JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      assignedTo: json['assigned_to'] ?? '',
      priority: json['priority'] ?? 2,
    );
  }

  /// 🔹 To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'priority': priority,
    };
  }
}
