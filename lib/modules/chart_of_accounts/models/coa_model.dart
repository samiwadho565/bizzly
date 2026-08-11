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
    this.normalBalance,
    this.statementType,
    this.children = const [],
  });

  final int id;
  final String accountName;
  final String accountCode;
  final String nature; // asset | liability | equity | income | expense
  final int level;     // 1 | 2 | 3
  final bool isActive;
  final bool isGlobal;
  final bool isOwnedByUser;
  final int? parentId;
  final String? parentName;
  final String? normalBalance;  // debit | credit
  final String? statementType;  // balance_sheet | income_statement
  final List<CoaModel> children;

  /// User can edit only their own private (non-global) accounts
  bool get isEditable => isOwnedByUser && !isGlobal;

  factory CoaModel.fromJson(Map<String, dynamic> json) {
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
      parentName: json['parent'] is Map ? json['parent']['account_name']?.toString() : null,
      normalBalance: json['normal_balance']?.toString(),
      statementType: json['statement_type']?.toString(),
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
        normalBalance: normalBalance,
        statementType: statementType,
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
        normalBalance: normalBalance,
        statementType: statementType,
        children: kids,
      );

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
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
  });

  final int id;
  final String accountCode;
  final String accountName;
  final String label; // "A1001 - Cash"
  final String nature;
  final bool isGlobal;
  final String? normalBalance; // debit | credit
  final int level;             // 1 | 2 | 3

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
    );
  }
}
