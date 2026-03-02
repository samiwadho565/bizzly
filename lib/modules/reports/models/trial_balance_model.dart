class TrialBalanceModel {
  TrialBalanceModel({
    required this.fromDate,
    required this.toDate,
    required this.accounts,
    required this.transactions,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });

  final String fromDate;
  final String toDate;
  final List<TrialBalanceAccount> accounts;
  final List<TrialBalanceTransaction> transactions;
  final num totalDebit;
  final num totalCredit;
  final bool isBalanced;

  factory TrialBalanceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map<String, dynamic>)
        : json;
    final Map<String, dynamic> totals = payload['totals'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(payload['totals'] as Map<String, dynamic>)
        : <String, dynamic>{};

    return TrialBalanceModel(
      fromDate: payload['from_date']?.toString() ?? '',
      toDate: payload['to_date']?.toString() ?? '',
      accounts: _parseAccounts(payload['accounts']),
      transactions: _parseTransactions(payload['transactions']),
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

  static List<TrialBalanceTransaction> _parseTransactions(dynamic value) {
    if (value is! List) return <TrialBalanceTransaction>[];
    return value
        .whereType<Map>()
        .map((e) =>
            TrialBalanceTransaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
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

class TrialBalanceAccount {
  TrialBalanceAccount({
    required this.accountName,
    required this.debit,
    required this.credit,
  });

  final String accountName;
  final num debit;
  final num credit;

  factory TrialBalanceAccount.fromJson(Map<String, dynamic> json) {
    return TrialBalanceAccount(
      accountName: json['account_name']?.toString() ?? '',
      debit: TrialBalanceModel._toNum(json['debit']) ?? 0,
      credit: TrialBalanceModel._toNum(json['credit']) ?? 0,
    );
  }
}

class TrialBalanceTransaction {
  TrialBalanceTransaction({
    required this.type,
    required this.id,
    required this.date,
    required this.description,
    required this.accountName,
    required this.debit,
    required this.credit,
    this.referenceNumber,
    this.category,
  });

  final String type;
  final int? id;
  final String date;
  final String description;
  final String accountName;
  final num debit;
  final num credit;
  final String? referenceNumber;
  final String? category;

  factory TrialBalanceTransaction.fromJson(Map<String, dynamic> json) {
    return TrialBalanceTransaction(
      type: json['type']?.toString() ?? '',
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      date: json['date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      debit: TrialBalanceModel._toNum(json['debit']) ?? 0,
      credit: TrialBalanceModel._toNum(json['credit']) ?? 0,
      referenceNumber: json['reference_number']?.toString(),
      category: json['category']?.toString(),
    );
  }
}
