class IncomeStatementModel {
  final String fromDate;
  final String toDate;
  final double totalRevenue;
  final double totalExpenses;
  final double grossProfit;
  final double netIncome;
  final List<IncomeStatementSection> revenueSections;
  final List<IncomeStatementSection> expenseSections;

  IncomeStatementModel({
    required this.fromDate,
    required this.toDate,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.grossProfit,
    required this.netIncome,
    required this.revenueSections,
    required this.expenseSections,
  });

  factory IncomeStatementModel.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic> data =
        j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : j;

    double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

    // revenue and expenses can be top-level or nested
    final List<dynamic> rawRevenue = data['revenue'] is List
        ? data['revenue'] as List
        : data['revenues'] is List
            ? data['revenues'] as List
            : [];

    final List<dynamic> rawExpenses = data['expenses'] is List
        ? data['expenses'] as List
        : [];

    // totals can be nested or flat
    final Map<String, dynamic> totals = data['totals'] is Map
        ? Map<String, dynamic>.from(data['totals'] as Map)
        : data['summary'] is Map
            ? Map<String, dynamic>.from(data['summary'] as Map)
            : data;

    return IncomeStatementModel(
      fromDate: data['from_date']?.toString() ?? '',
      toDate: data['to_date']?.toString() ?? '',
      totalRevenue: _d(totals['total_revenue'] ?? data['total_revenue']),
      totalExpenses: _d(totals['total_expenses'] ?? data['total_expenses']),
      grossProfit: _d(totals['gross_profit'] ?? data['gross_profit']),
      netIncome: _d(totals['net_income'] ?? data['net_income']),
      revenueSections: rawRevenue
          .whereType<Map>()
          .map((e) => IncomeStatementSection.fromJson(
              Map<String, dynamic>.from(e)))
          .toList(),
      expenseSections: rawExpenses
          .whereType<Map>()
          .map((e) => IncomeStatementSection.fromJson(
              Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class IncomeStatementSection {
  final String accountName;
  final String accountCode;
  final double amount;

  IncomeStatementSection({
    required this.accountName,
    required this.accountCode,
    required this.amount,
  });

  factory IncomeStatementSection.fromJson(Map<String, dynamic> j) {
    return IncomeStatementSection(
      accountName: j['account_name']?.toString() ??
          j['name']?.toString() ?? '',
      accountCode: j['account_code']?.toString() ??
          j['code']?.toString() ?? '',
      amount: (j['amount'] as num?)?.toDouble() ??
          (j['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
