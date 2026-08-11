class TeamMemberModel {
  TeamMemberModel({
    this.id,
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.accountingRole,
    this.accountingRoleName,
    required this.status,
    this.isActive = true,
    this.businessId,
    this.businessName,
    this.permissions = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String name;
  final String email;
  final String phone;
  final String accountingRole;     // accountant | approver | accounting_admin | viewer_auditor
  final String? accountingRoleName; // human readable from API e.g. "Approver"
  final String status;              // active | inactive
  final bool isActive;
  final int? businessId;
  final String? businessName;
  final List<String> permissions;
  final String? createdAt;
  final String? updatedAt;

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    // Unwrap { data: {...} } envelope if present
    final Map<String, dynamic> p =
        json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json;

    // Nested member object (new API structure)
    final Map<String, dynamic>? memberMap =
        p['member'] is Map ? Map<String, dynamic>.from(p['member'] as Map) : null;

    // Permissions list
    final List<String> perms = p['permissions'] is List
        ? (p['permissions'] as List).map((e) => e.toString()).toList()
        : [];

    return TeamMemberModel(
      id: _toInt(p['id']),
      userId: _toInt(memberMap?['id']) ?? _toInt(p['user_id']),
      name: memberMap?['name']?.toString() ?? p['name']?.toString() ?? '',
      email: memberMap?['email']?.toString() ?? p['email']?.toString() ?? '',
      phone: memberMap?['phone']?.toString() ?? p['phone']?.toString() ?? '',
      isActive: memberMap?['is_active'] == true || memberMap?['is_active'] == 1,
      accountingRole: p['accounting_role']?.toString() ?? 'accountant',
      accountingRoleName: p['accounting_role_name']?.toString(),
      status: p['status']?.toString() ?? 'active',
      businessId: _toInt(p['business_id']),
      businessName: p['business_name']?.toString(),
      permissions: perms,
      createdAt: p['created_at']?.toString(),
      updatedAt: p['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toCreateJson({
    required String password,
    required bool createEmployeeRecord,
  }) =>
      <String, dynamic>{
        if (businessId != null) 'business_id': businessId.toString(),
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'accounting_role': accountingRole,
        'create_employee_record': createEmployeeRecord,
      };

  Map<String, dynamic> toUpdateJson() =>
      <String, dynamic>{'status': status};

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}
