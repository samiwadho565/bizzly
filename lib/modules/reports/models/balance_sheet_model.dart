double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int? _i(dynamic v) => v == null ? null : ((v as num?)?.toInt() ?? int.tryParse(v.toString()));
bool _b(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase().trim() == 'true' || v.trim() == '1';
  return false;
}

/// Lightweight reference to a parent account (id/code/name only).
class BalanceSheetParentRef {
  final int id;
  final String accountCode;
  final String accountName;

  BalanceSheetParentRef({
    required this.id,
    required this.accountCode,
    required this.accountName,
  });

  factory BalanceSheetParentRef.fromJson(Map<String, dynamic> j) {
    return BalanceSheetParentRef(
      id: _i(j['id']) ?? 0,
      accountCode: j['account_code']?.toString() ?? '',
      accountName: j['account_name']?.toString() ?? '',
    );
  }
}

/// One account line inside a section — carries the full breakdown the
/// backend sends, including contra accounts netted against it (e.g.
/// Accumulated Depreciation netted against Building).
class BalanceSheetAccount {
  final int id;
  final String accountCode;
  final String accountName;
  final String nature;
  final String? normalBalance;
  final String? statementType;
  final int? level;
  final bool isContra;
  final int? relatedAccountId;
  final double signedBalance;
  final double debit;
  final double credit;
  final String? balanceSide;
  final BalanceSheetParentRef? parent;
  final List<BalanceSheetAccount> contraAccounts;
  final double grossBalance;
  final double contraTotal;
  final double netBalance;

  BalanceSheetAccount({
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
    required this.contraAccounts,
    required this.grossBalance,
    required this.contraTotal,
    required this.netBalance,
  });

  factory BalanceSheetAccount.fromJson(Map<String, dynamic> j) {
    final List<dynamic> rawContra =
        j['contra_accounts'] is List ? j['contra_accounts'] as List : [];

    return BalanceSheetAccount(
      id: _i(j['id']) ?? 0,
      accountCode: j['account_code']?.toString() ?? '',
      accountName: j['account_name']?.toString() ?? '',
      nature: j['nature']?.toString() ?? '',
      normalBalance: j['normal_balance']?.toString(),
      statementType: j['statement_type']?.toString(),
      level: _i(j['level']),
      isContra: j['is_contra'] == true,
      relatedAccountId: _i(j['related_account_id']),
      signedBalance: _d(j['signed_balance']),
      debit: _d(j['debit']),
      credit: _d(j['credit']),
      balanceSide: j['balance_side']?.toString(),
      parent: j['parent'] is Map
          ? BalanceSheetParentRef.fromJson(Map<String, dynamic>.from(j['parent'] as Map))
          : null,
      contraAccounts: rawContra
          .whereType<Map>()
          .map((e) => BalanceSheetAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      grossBalance: _d(j['gross_balance']),
      contraTotal: _d(j['contra_total']),
      netBalance: _d(j['net_balance'] ?? j['signed_balance']),
    );
  }
}

/// A section of the report (e.g. "Current Assets"), with its own
/// subtotal — sections can be empty (accounts: []).
class BalanceSheetSection {
  final String sectionCode;
  final String sectionName;
  final List<BalanceSheetAccount> accounts;
  final double grossTotal;
  final double netTotal;

  BalanceSheetSection({
    required this.sectionCode,
    required this.sectionName,
    required this.accounts,
    required this.grossTotal,
    required this.netTotal,
  });

  factory BalanceSheetSection.fromJson(Map<String, dynamic> j) {
    final List<dynamic> rawAccounts = j['accounts'] is List ? j['accounts'] as List : [];
    return BalanceSheetSection(
      sectionCode: j['section_code']?.toString() ?? '',
      sectionName: j['section_name']?.toString() ?? '',
      accounts: rawAccounts
          .whereType<Map>()
          .map((e) => BalanceSheetAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      grossTotal: _d(j['gross_total']),
      netTotal: _d(j['net_total'] ?? j['gross_total']),
    );
  }
}

class BalanceSheetModel {
  final String asOfDate;
  final List<BalanceSheetSection> assetSections;
  final List<BalanceSheetSection> liabilitySections;
  final List<BalanceSheetSection> capitalSections;
  final double totalAssets;
  final double totalLiabilities;
  final double totalCapital;
  final double totalLiabilitiesAndEquity;
  final bool isBalanced;
  final String? currentYearEarningsLabel;
  final double currentYearEarningsAmount;

  BalanceSheetModel({
    required this.asOfDate,
    required this.assetSections,
    required this.liabilitySections,
    required this.capitalSections,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalCapital,
    required this.totalLiabilitiesAndEquity,
    required this.isBalanced,
    this.currentYearEarningsLabel,
    required this.currentYearEarningsAmount,
  });

  /// Back-compat aliases for older call-sites.
  double get totalEquity => totalCapital;

  static List<BalanceSheetSection> _parseSections(dynamic block) {
    if (block is! Map) return [];
    final List<dynamic> raw = block['sections'] is List ? block['sections'] as List : [];
    return raw
        .whereType<Map>()
        .map((e) => BalanceSheetSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  factory BalanceSheetModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json;

    final Map<String, dynamic> assets =
        data['assets'] is Map ? Map<String, dynamic>.from(data['assets'] as Map) : {};
    final Map<String, dynamic> liabilities =
        data['liabilities'] is Map ? Map<String, dynamic>.from(data['liabilities'] as Map) : {};
    final Map<String, dynamic> capital =
        data['capital'] is Map ? Map<String, dynamic>.from(data['capital'] as Map) : {};
    final Map<String, dynamic> totals =
        data['totals'] is Map ? Map<String, dynamic>.from(data['totals'] as Map) : {};

    final Map<String, dynamic> currentYearEarnings = capital['current_year_earnings'] is Map
        ? Map<String, dynamic>.from(capital['current_year_earnings'] as Map)
        : {};

    return BalanceSheetModel(
      asOfDate: data['as_of_date']?.toString() ?? '',
      assetSections: _parseSections(assets),
      liabilitySections: _parseSections(liabilities),
      capitalSections: _parseSections(capital),
      totalAssets: _d(totals['total_assets'] ?? assets['total']),
      totalLiabilities: _d(totals['total_liabilities'] ?? liabilities['total']),
      totalCapital: _d(totals['total_capital'] ?? capital['total']),
      totalLiabilitiesAndEquity: _d(totals['total_liabilities_and_equity']),
      isBalanced: _b(totals['is_balanced']),
      currentYearEarningsLabel: currentYearEarnings['label']?.toString(),
      currentYearEarningsAmount: _d(currentYearEarnings['amount']),
    );
  }
}
