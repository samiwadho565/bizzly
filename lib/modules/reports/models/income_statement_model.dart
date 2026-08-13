double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int? _i(dynamic v) => v == null ? null : ((v as num?)?.toInt() ?? int.tryParse(v.toString()));

/// Lightweight reference to a parent account (id/code/name only).
class IncomeStatementParentRef {
  final int id;
  final String accountCode;
  final String accountName;

  IncomeStatementParentRef({
    required this.id,
    required this.accountCode,
    required this.accountName,
  });

  factory IncomeStatementParentRef.fromJson(Map<String, dynamic> j) {
    return IncomeStatementParentRef(
      id: _i(j['id']) ?? 0,
      accountCode: j['account_code']?.toString() ?? '',
      accountName: j['account_name']?.toString() ?? '',
    );
  }
}

/// One account line inside a section — carries the full breakdown the
/// backend sends, including contra accounts netted against it.
class IncomeStatementAccount {
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
  final IncomeStatementParentRef? parent;
  final List<IncomeStatementAccount> contraAccounts;
  final double grossBalance;
  final double contraTotal;
  final double netBalance;

  IncomeStatementAccount({
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

  /// Convenience getters so existing call-sites (flat name/code/amount)
  /// keep working without every screen needing a rewrite.
  String get name => accountName;
  String get code => accountCode;
  double get amount => netBalance;

  factory IncomeStatementAccount.fromJson(Map<String, dynamic> j) {
    final List<dynamic> rawContra =
        j['contra_accounts'] is List ? j['contra_accounts'] as List : [];

    return IncomeStatementAccount(
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
          ? IncomeStatementParentRef.fromJson(Map<String, dynamic>.from(j['parent'] as Map))
          : null,
      contraAccounts: rawContra
          .whereType<Map>()
          .map((e) => IncomeStatementAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      grossBalance: _d(j['gross_balance']),
      contraTotal: _d(j['contra_total']),
      netBalance: _d(j['net_balance'] ??
          j['signed_balance'] ??
          j['amount'] ??
          j['total']),
    );
  }
}

/// A section of the report (e.g. "Operating/Trading Revenue"), with its
/// own subtotal — sections can be empty (accounts: []).
class IncomeStatementSection {
  final String sectionCode;
  final String sectionName;
  final List<IncomeStatementAccount> accounts;
  final double grossTotal;
  final double netTotal;

  IncomeStatementSection({
    required this.sectionCode,
    required this.sectionName,
    required this.accounts,
    required this.grossTotal,
    required this.netTotal,
  });

  /// Back-compat aliases used by older call-sites.
  String get accountName => sectionName;
  String get accountCode => sectionCode;
  double get amount => netTotal;

  factory IncomeStatementSection.fromJson(Map<String, dynamic> j) {
    final List<dynamic> rawAccounts = j['accounts'] is List ? j['accounts'] as List : [];
    return IncomeStatementSection(
      sectionCode: j['section_code']?.toString() ?? '',
      sectionName: j['section_name']?.toString() ?? '',
      accounts: rawAccounts
          .whereType<Map>()
          .map((e) => IncomeStatementAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      grossTotal: _d(j['gross_total']),
      netTotal: _d(j['net_total'] ?? j['gross_total']),
    );
  }
}

class IncomeStatementModel {
  final String fromDate;
  final String toDate;
  final double totalRevenue;
  final double totalExpenses;
  final double grossProfit;
  final double netIncome;
  final double netProfit;
  final double netLoss;
  final bool isProfit;
  final List<IncomeStatementSection> revenueSections;
  final List<IncomeStatementSection> expenseSections;

  IncomeStatementModel({
    required this.fromDate,
    required this.toDate,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.grossProfit,
    required this.netIncome,
    required this.netProfit,
    required this.netLoss,
    required this.isProfit,
    required this.revenueSections,
    required this.expenseSections,
  });

  /// Flattened line items across every revenue/expense section — kept for
  /// any call-site that still wants a plain list rather than sections.
  List<IncomeStatementAccount> get revenueLines =>
      revenueSections.expand((s) => s.accounts).toList();
  List<IncomeStatementAccount> get expenseLines =>
      expenseSections.expand((s) => s.accounts).toList();

  factory IncomeStatementModel.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic> data =
        j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : j;

    final Map<String, dynamic> revenueBlock =
        data['revenue'] is Map ? Map<String, dynamic>.from(data['revenue'] as Map) : {};
    final Map<String, dynamic> expensesBlock =
        data['expenses'] is Map ? Map<String, dynamic>.from(data['expenses'] as Map) : {};

    final List<dynamic> rawRevenueSections =
        revenueBlock['sections'] is List ? revenueBlock['sections'] as List : [];
    final List<dynamic> rawExpenseSections =
        expensesBlock['sections'] is List ? expensesBlock['sections'] as List : [];

    final List<IncomeStatementSection> revenueSections = rawRevenueSections
        .whereType<Map>()
        .map((e) => IncomeStatementSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final List<IncomeStatementSection> expenseSections = rawExpenseSections
        .whereType<Map>()
        .map((e) => IncomeStatementSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final double totalRevenue = _d(revenueBlock['total']);
    final double totalExpenses = _d(expensesBlock['total']);
    final double netProfit = _d(data['net_profit']);
    final double netLoss = _d(data['net_loss']);
    final bool isProfit = data['is_profit'] == true;

    return IncomeStatementModel(
      fromDate: data['from_date']?.toString() ?? '',
      toDate: data['to_date']?.toString() ?? '',
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      grossProfit: totalRevenue - totalExpenses,
      netIncome: netProfit - netLoss,
      netProfit: netProfit,
      netLoss: netLoss,
      isProfit: isProfit,
      revenueSections: revenueSections,
      expenseSections: expenseSections,
    );
  }
}
