class CoaModel {
  CoaModel({
    required this.id,
    required this.accountName,
    required this.accountCode,
    required this.nature,
    required this.level,
    required this.isActive,
    required this.isGlobal,
    required this.isOwnedByUser,
    this.parentId,
    this.parentName,
    this.parentAccountCode,
    this.parentLevel,
    this.normalBalance,
    this.statementType,
    this.isContra = false,
    this.relatedAccountId,
    this.createdAt,
    this.updatedAt,
    this.children = const [],
  });

  final int id;
  final String accountName;
  final String accountCode;
  final String nature; // asset | liability | equity/capital | income/revenue | expense | contra
  final int level;     // 1 | 2 | 3
  final bool isActive;
  final bool isGlobal;
  final bool isOwnedByUser;
  final int? parentId;
  final String? parentName;
  final String? parentAccountCode;
  final int? parentLevel;
  final String? normalBalance;  // debit | credit
  final String? statementType;  // balance_sheet | income_statement
  final bool isContra;
  final int? relatedAccountId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CoaModel> children;

  /// User can edit only their own private (non-global) accounts
  bool get isEditable => isOwnedByUser && !isGlobal;

  factory CoaModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? parent =
        json['parent'] is Map ? Map<String, dynamic>.from(json['parent'] as Map) : null;

    return CoaModel(
      id: _toInt(json['id']) ?? 0,
      accountName: json['account_name']?.toString() ?? '',
      accountCode: json['account_code']?.toString() ?? '',
      nature: json['nature']?.toString() ?? '',
      level: _toInt(json['level']) ?? 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isGlobal: json['is_global'] == true || json['is_global'] == 1,
      isOwnedByUser: json['is_owned_by_user'] == true || json['is_owned_by_user'] == 1,
      parentId: _toInt(json['parent_id']),
      parentName: parent?['account_name']?.toString(),
      parentAccountCode: parent?['account_code']?.toString(),
      parentLevel: _toInt(parent?['level']),
      normalBalance: json['normal_balance']?.toString(),
      statementType: json['statement_type']?.toString(),
      isContra: json['is_contra'] == true || json['is_contra'] == 1,
      relatedAccountId: _toInt(json['related_account_id']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      // children are built in the controller from the flat list
    );
  }

  /// Returns a copy with optional field overrides
  CoaModel copyWith({bool? isActive, List<CoaModel>? children}) => CoaModel(
        id: id,
        accountName: accountName,
        accountCode: accountCode,
        nature: nature,
        level: level,
        isActive: isActive ?? this.isActive,
        isGlobal: isGlobal,
        isOwnedByUser: isOwnedByUser,
        parentId: parentId,
        parentName: parentName,
        parentAccountCode: parentAccountCode,
        parentLevel: parentLevel,
        normalBalance: normalBalance,
        statementType: statementType,
        isContra: isContra,
        relatedAccountId: relatedAccountId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        children: children ?? this.children,
      );

  /// Returns a copy with children attached (used when building tree)
  CoaModel withChildren(List<CoaModel> kids) => CoaModel(
        id: id,
        accountName: accountName,
        accountCode: accountCode,
        nature: nature,
        level: level,
        isActive: isActive,
        isGlobal: isGlobal,
        isOwnedByUser: isOwnedByUser,
        parentId: parentId,
        parentName: parentName,
        parentAccountCode: parentAccountCode,
        parentLevel: parentLevel,
        normalBalance: normalBalance,
        statementType: statementType,
        isContra: isContra,
        relatedAccountId: relatedAccountId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        children: kids,
      );

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

// ── Dropdown model (used in voucher line picker) ─────────────────
class CoaDropdownItem {
  CoaDropdownItem({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.label,
    required this.nature,
    required this.isGlobal,
    this.normalBalance,
    this.level = 3,
    this.parentId,
    this.parentAccountCode,
    this.parentAccountName,
  });

  final int id;
  final String accountCode;
  final String accountName;
  final String label; // "A1001 - Cash"
  final String nature;
  final bool isGlobal;
  final String? normalBalance; // debit | credit
  final int level;             // 1 | 2 | 3
  final int? parentId;
  final String? parentAccountCode;
  final String? parentAccountName;

  factory CoaDropdownItem.fromJson(Map<String, dynamic> json) {
    return CoaDropdownItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      accountCode: json['account_code']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      nature: json['nature']?.toString() ?? '',
      isGlobal: json['is_global'] == true || json['is_global'] == 1,
      normalBalance: json['normal_balance']?.toString(),
      level: json['level'] is int
          ? json['level'] as int
          : int.tryParse(json['level']?.toString() ?? '') ?? 3,
      parentId: json['parent_id'] is int
          ? json['parent_id'] as int
          : int.tryParse(json['parent_id']?.toString() ?? ''),
      parentAccountCode: json['parent_account_code']?.toString(),
      parentAccountName: json['parent_account_name']?.toString(),
    );
  }
}
