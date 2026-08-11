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

    // Flattens a { sections: [ { accounts: [...] , ... } ] } block into a
    // single list of line items. Falls back to a flat list if that's what
    // was sent instead.
    List<dynamic> _flattenAccounts(dynamic block) {
      if (block is Map && block['sections'] is List) {
        final List<dynamic> result = [];
        for (final dynamic section in block['sections'] as List) {
          if (section is Map && section['accounts'] is List) {
            result.addAll(section['accounts'] as List);
          }
        }
        return result;
      }
      if (block is List) return block;
      return [];
    }

    double _blockTotal(dynamic block) {
      if (block is Map) {
        return _d(block['total'] ?? block['net_total'] ?? block['gross_total']);
      }
      return 0.0;
    }

    final dynamic revenueBlock = data['revenue'] ?? data['revenues'];
    final dynamic expensesBlock = data['expenses'];

    final List<dynamic> rawRevenue = _flattenAccounts(revenueBlock);
    final List<dynamic> rawExpenses = _flattenAccounts(expensesBlock);

    // totals can be nested or flat
    final Map<String, dynamic> totals = data['totals'] is Map
        ? Map<String, dynamic>.from(data['totals'] as Map)
        : data['summary'] is Map
            ? Map<String, dynamic>.from(data['summary'] as Map)
            : data;

    final double totalRevenue = totals['total_revenue'] != null ||
            data['total_revenue'] != null
        ? _d(totals['total_revenue'] ?? data['total_revenue'])
        : _blockTotal(revenueBlock);

    final double totalExpenses = totals['total_expenses'] != null ||
            data['total_expenses'] != null
        ? _d(totals['total_expenses'] ?? data['total_expenses'])
        : _blockTotal(expensesBlock);

    final double netIncome = data['net_profit'] != null || data['net_loss'] != null
        ? _d(data['net_profit']) - _d(data['net_loss'])
        : _d(totals['net_income'] ?? data['net_income']);

    return IncomeStatementModel(
      fromDate: data['from_date']?.toString() ?? '',
      toDate: data['to_date']?.toString() ?? '',
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      grossProfit: _d(totals['gross_profit'] ??
          data['gross_profit'] ??
          (totalRevenue - totalExpenses)),
      netIncome: netIncome,
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
          (j['total'] as num?)?.toDouble() ??
          (j['net_balance'] as num?)?.toDouble() ??
          (j['signed_balance'] as num?)?.toDouble() ??
          0.0,
    );
  }
}
