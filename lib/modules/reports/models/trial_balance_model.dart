num? _toNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final String normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

/// Lightweight reference to a parent account (id/code/name only).
class TrialBalanceParentRef {
  final int id;
  final String accountCode;
  final String accountName;

  TrialBalanceParentRef({
    required this.id,
    required this.accountCode,
    required this.accountName,
  });

  factory TrialBalanceParentRef.fromJson(Map<String, dynamic> json) {
    return TrialBalanceParentRef(
      id: _toInt(json['id']) ?? 0,
      accountCode: json['account_code']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
    );
  }
}

class TrialBalanceModel {
  TrialBalanceModel({
    required this.fromDate,
    required this.toDate,
    required this.accounts,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });

  final String fromDate;
  final String toDate;
  final List<TrialBalanceAccount> accounts;
  final num totalDebit;
  final num totalCredit;
  final bool isBalanced;

  factory TrialBalanceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final Map<String, dynamic> totals = payload['totals'] is Map
        ? Map<String, dynamic>.from(payload['totals'] as Map)
        : <String, dynamic>{};

    return TrialBalanceModel(
      fromDate: payload['from_date']?.toString() ?? '',
      toDate: payload['to_date']?.toString() ?? '',
      accounts: _parseAccounts(payload['accounts']),
      totalDebit: _toNum(totals['total_debit']) ?? 0,
      totalCredit: _toNum(totals['total_credit']) ?? 0,
      isBalanced: _toBool(totals['is_balanced']),
    );
  }

  static List<TrialBalanceAccount> _parseAccounts(dynamic value) {
    if (value is! List) return <TrialBalanceAccount>[];
    return value
        .whereType<Map>()
        .map((e) => TrialBalanceAccount.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// One account row — carries the full breakdown the backend sends, not
/// just name/debit/credit.
class TrialBalanceAccount {
  TrialBalanceAccount({
    required this.id,
    required this.accountCode,
    required this.accountName,
    required this.nature,
    this.normalBalance,
    this.statementType,
    this.level,
    required this.isContra,
    this.relatedAccountId,
    required this.signedBalance,
    required this.debit,
    required this.credit,
    this.balanceSide,
    this.parent,
  });

  final int id;
  final String accountCode;
  final String accountName;
  final String nature;
  final String? normalBalance;
  final String? statementType;
  final int? level;
  final bool isContra;
  final int? relatedAccountId;
  final num signedBalance;
  final num debit;
  final num credit;
  final String? balanceSide;
  final TrialBalanceParentRef? parent;

  factory TrialBalanceAccount.fromJson(Map<String, dynamic> json) {
    return TrialBalanceAccount(
      id: _toInt(json['id']) ?? 0,
      accountCode: json['account_code']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      nature: json['nature']?.toString() ?? '',
      normalBalance: json['normal_balance']?.toString(),
      statementType: json['statement_type']?.toString(),
      level: _toInt(json['level']),
      isContra: json['is_contra'] == true,
      relatedAccountId: _toInt(json['related_account_id']),
      signedBalance: _toNum(json['signed_balance']) ?? 0,
      debit: _toNum(json['debit']) ?? 0,
      credit: _toNum(json['credit']) ?? 0,
      balanceSide: json['balance_side']?.toString(),
      parent: json['parent'] is Map
          ? TrialBalanceParentRef.fromJson(Map<String, dynamic>.from(json['parent'] as Map))
          : null,
    );
  }
}
