class AssetModel {
  AssetModel({
    this.id,
    this.userId,
    this.assignedTo,
    this.assignedEmployeeName,
    this.assignedEmployeeEmail,
    required this.assetName,
    required this.assetType,
    required this.value,
    required this.purchaseDate,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final int? assignedTo;
  final String? assignedEmployeeName;
  final String? assignedEmployeeEmail;
  final String assetName;
  final String assetType;
  final num value;
  final String purchaseDate;
  final String? createdAt;
  final String? updatedAt;

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final Map<String, dynamic>? assignedEmployee =
        payload['assigned_employee'] is Map
            ? Map<String, dynamic>.from(payload['assigned_employee'] as Map)
            : null;

    return AssetModel(
      id: _toInt(payload['id']),
      userId: _toInt(payload['user_id']),
      assignedTo: _toInt(payload['assigned_to']) ?? _toInt(assignedEmployee?['id']),
      assignedEmployeeName: assignedEmployee?['full_name']?.toString(),
      assignedEmployeeEmail: assignedEmployee?['email']?.toString(),
      assetName: payload['asset_name']?.toString() ?? '',
      assetType: payload['asset_type']?.toString() ?? '',
      value: _toNum(payload['value']) ?? 0,
      purchaseDate: payload['purchase_date']?.toString() ?? '',
      createdAt: payload['created_at']?.toString(),
      updatedAt: payload['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_name': assetName,
      'asset_type': assetType,
      'value': value.toString(),
      'purchase_date': purchaseDate,
      'assigned_to': assignedTo?.toString(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
