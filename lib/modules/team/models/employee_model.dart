class EmployeeModel {
  EmployeeModel({
    this.id,
    this.userId,
    this.businessId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.salary,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final int? businessId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;
  final dynamic salary;
  final String status;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return EmployeeModel(
      id: _toInt(payload['id']),
      userId: _toInt(payload['user_id']),
      businessId: _toInt(payload['business_id']),
      fullName: payload['full_name']?.toString() ?? '',
      email: payload['email']?.toString() ?? '',
      phoneNumber: payload['phone_number']?.toString() ?? '',
      address: payload['address']?.toString() ?? '',
      role: payload['role']?.toString() ?? '',
      salary: payload['salary'],
      status: payload['status']?.toString() ?? 'active',
      notes: payload['notes']?.toString(),
      createdAt: payload['created_at']?.toString(),
      updatedAt: payload['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'role': role,
      'salary': salary?.toString(),
      'status': status,
      'notes': notes?.trim().isNotEmpty == true ? notes : null,
      if (businessId != null) 'business_id': businessId.toString(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
