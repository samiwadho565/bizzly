import 'dart:io';

class TaskAttachmentModel {
  TaskAttachmentModel({
    this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.sortOrder,
  });

  final int? id;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final int? sortOrder;

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentModel(
      id: _toInt(json['id']),
      fileName: json['file_name']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      fileType: json['file_type']?.toString(),
      fileSize: _toInt(json['file_size']),
      sortOrder: _toInt(json['sort_order']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class TaskModel {
  final int? id;
  final int? userId;
  final int? businessId;
  final String? businessName;
  final int? assignTo;
  final String? assignedEmployeeName;
  final String taskTitle;
  final String priority; // high, medium, low
  final String dueDate;
  final String description;
  final String status; // to do, in progress, done
  final List<TaskAttachmentModel> attachments;
  final List<File> attachmentFiles;
  final String? createdAt;
  final String? updatedAt;

  TaskModel({
    this.id,
    this.userId,
    this.businessId,
    this.businessName,
    this.assignTo,
    this.assignedEmployeeName,
    required this.taskTitle,
    required this.priority,
    required this.dueDate,
    required this.description,
    required this.status,
    this.attachments = const [],
    this.attachmentFiles = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final dynamic businessRaw = payload['business'] ??
        payload['businesses'] ??
        payload['business_detail'] ??
        payload['company'];
    final Map<String, dynamic>? assignedEmployee = payload['assigned_employee'] is Map
        ? Map<String, dynamic>.from(payload['assigned_employee'] as Map)
        : null;
    final Map<String, dynamic>? business = businessRaw is Map
        ? Map<String, dynamic>.from(businessRaw as Map)
        : null;
    final List<TaskAttachmentModel> parsedAttachments = (payload['attachments'] is List)
        ? (payload['attachments'] as List)
            .where((e) => e is Map)
            .map((e) => TaskAttachmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <TaskAttachmentModel>[];

    return TaskModel(
      id: _toInt(payload['id']),
      userId: _toInt(payload['user_id']),
      businessId: _toInt(
            payload['business_id'] ??
                payload['businessId'] ??
                payload['businesses_id'] ??
                payload['businessIdFk'] ??
                payload['company_id'] ??
                (businessRaw is Map ? businessRaw['id'] : businessRaw),
          ) ??
          _toInt(business?['id']),
      businessName: _firstNonEmpty(<dynamic>[
        business?['business_name'],
        business?['name'],
        business?['title'],
        payload['business_name'],
        payload['businessName'],
        payload['business_title'],
        payload['businessTitle'],
        payload['company_name'],
        businessRaw is String ? businessRaw : null,
      ]),
      assignTo: _toInt(payload['assign_to']) ?? _toInt(assignedEmployee?['id']),
      assignedEmployeeName: assignedEmployee?['full_name']?.toString(),
      taskTitle: payload['task_title']?.toString() ?? '',
      priority: payload['priority']?.toString().toLowerCase() ?? 'medium',
      dueDate: payload['due_date']?.toString().trim() ?? '',
      description: payload['description']?.toString() ?? '',
      status: payload['status']?.toString().toLowerCase() ?? 'to do',
      attachments: parsedAttachments,
      createdAt: payload['created_at']?.toString(),
      updatedAt: payload['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_title': taskTitle,
      'assign_to': assignTo?.toString(),
      if (businessId != null) 'business_id': businessId?.toString(),
      'priority': priority,
      'due_date': dueDate,
      'description': description,
      'status': status,
      'attachments': attachmentFiles,
    };
  }

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'to do':
        return 'To-Do';
      case 'in progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      default:
        return status;
    }
  }

  String get displayPriority {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }

  int get priorityLevel {
    switch (priority.toLowerCase()) {
      case 'high':
        return 1;
      case 'medium':
        return 2;
      case 'low':
        return 3;
      default:
        return 2;
    }
  }

  DateTime? get dueDateParsed {
    final String raw = dueDate.trim();
    if (raw.isEmpty) return null;

    final DateTime? direct = DateTime.tryParse(raw);
    if (direct != null) return direct;

    final RegExp dateOnly = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$');
    final Match? match = dateOnly.firstMatch(raw);
    if (match == null) return null;

    final int? year = int.tryParse(match.group(1) ?? '');
    final int? month = int.tryParse(match.group(2) ?? '');
    final int? day = int.tryParse(match.group(3) ?? '');
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final dynamic value in values) {
      final String normalized = value?.toString().trim() ?? '';
      if (normalized.isNotEmpty) return normalized;
    }
    return null;
  }
}
