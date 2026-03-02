class BalanceSheetModel {
  BalanceSheetModel({
    required this.asOfDate,
    required this.currentAssets,
    required this.fixedAssets,
    required this.currentLiabilities,
    required this.retainedEarnings,
    required this.details,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
    required this.totalLiabilitiesAndEquity,
    required this.isBalanced,
  });

  final String asOfDate;
  final BalanceSheetValueGroup currentAssets;
  final BalanceSheetValueGroup fixedAssets;
  final BalanceSheetValueGroup currentLiabilities;
  final num retainedEarnings;
  final BalanceSheetDetails details;
  final num totalAssets;
  final num totalLiabilities;
  final num totalEquity;
  final num totalLiabilitiesAndEquity;
  final bool isBalanced;

  factory BalanceSheetModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map<String, dynamic>)
        : json;
    final Map<String, dynamic> assets =
        _toMap(payload['assets']);
    final Map<String, dynamic> liabilities =
        _toMap(payload['liabilities']);
    final Map<String, dynamic> equity =
        _toMap(payload['equity']);
    final Map<String, dynamic> totals =
        _toMap(payload['totals']);

    return BalanceSheetModel(
      asOfDate: payload['as_of_date']?.toString() ?? '',
      currentAssets: BalanceSheetValueGroup.fromJson(
        _toMap(assets['current_assets']),
      ),
      fixedAssets: BalanceSheetValueGroup.fromJson(
        _toMap(assets['fixed_assets']),
      ),
      currentLiabilities: BalanceSheetValueGroup.fromJson(
        _toMap(liabilities['current_liabilities']),
      ),
      retainedEarnings: _toNum(equity['retained_earnings']) ?? 0,
      details: BalanceSheetDetails.fromJson(_toMap(payload['details'])),
      totalAssets: _toNum(totals['total_assets']) ?? 0,
      totalLiabilities: _toNum(totals['total_liabilities']) ?? 0,
      totalEquity: _toNum(totals['total_equity']) ?? 0,
      totalLiabilitiesAndEquity:
          _toNum(totals['total_liabilities_and_equity']) ?? 0,
      isBalanced: _toBool(totals['is_balanced']),
    );
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}

class BalanceSheetValueGroup {
  BalanceSheetValueGroup({
    required this.values,
    required this.total,
  });

  final Map<String, num> values;
  final num total;

  factory BalanceSheetValueGroup.fromJson(Map<String, dynamic> json) {
    final Map<String, num> parsed = <String, num>{};
    num total = 0;

    json.forEach((key, value) {
      final num? number = BalanceSheetModel._toNum(value);
      if (number == null) return;
      if (key == 'total') {
        total = number;
        return;
      }
      parsed[key] = number;
    });

    return BalanceSheetValueGroup(
      values: parsed,
      total: total,
    );
  }
}

class BalanceSheetDetails {
  BalanceSheetDetails({
    required this.cashTransactions,
    required this.receivablesTransactions,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.assetTransactions,
  });

  final List<BalanceSheetTransaction> cashTransactions;
  final List<BalanceSheetTransaction> receivablesTransactions;
  final List<BalanceSheetTransaction> incomeTransactions;
  final List<BalanceSheetTransaction> expenseTransactions;
  final List<BalanceSheetTransaction> assetTransactions;

  factory BalanceSheetDetails.fromJson(Map<String, dynamic> json) {
    return BalanceSheetDetails(
      cashTransactions: _parseTransactions(json['cash_transactions']),
      receivablesTransactions:
          _parseTransactions(json['receivables_transactions']),
      incomeTransactions: _parseTransactions(json['income_transactions']),
      expenseTransactions: _parseTransactions(json['expense_transactions']),
      assetTransactions: _parseTransactions(json['asset_transactions']),
    );
  }

  static List<BalanceSheetTransaction> _parseTransactions(dynamic value) {
    if (value is! List) return <BalanceSheetTransaction>[];
    return value
        .whereType<Map>()
        .map((e) => BalanceSheetTransaction.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }
}

class BalanceSheetTransaction {
  BalanceSheetTransaction({
    required this.type,
    required this.id,
    required this.date,
    required this.description,
    this.referenceNumber,
    this.invoiceNumber,
    this.accountName,
    this.category,
    this.amount,
    this.value,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.status,
  });

  final String type;
  final int? id;
  final String date;
  final String description;
  final String? referenceNumber;
  final String? invoiceNumber;
  final String? accountName;
  final String? category;
  final num? amount;
  final num? value;
  final num? totalAmount;
  final num? paidAmount;
  final num? remainingAmount;
  final String? status;

  factory BalanceSheetTransaction.fromJson(Map<String, dynamic> json) {
    return BalanceSheetTransaction(
      type: json['type']?.toString() ?? '',
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      date: json['date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      referenceNumber: json['reference_number']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      accountName: json['account_name']?.toString(),
      category: json['category']?.toString(),
      amount: BalanceSheetModel._toNum(json['amount']),
      value: BalanceSheetModel._toNum(json['value']),
      totalAmount: BalanceSheetModel._toNum(json['total_amount']),
      paidAmount: BalanceSheetModel._toNum(json['paid_amount']),
      remainingAmount: BalanceSheetModel._toNum(json['remaining_amount']),
      status: json['status']?.toString(),
    );
  }
}
