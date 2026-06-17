class LedgerEntry {
  final int id;
  final String voucherNumber;
  final String voucherType;
  final String date;
  final String narration;
  final String accountCode;
  final String accountName;
  final double debit;
  final double credit;
  final double runningBalance;
  final String balanceType; // 'Dr' or 'Cr'

  LedgerEntry({
    required this.id,
    required this.voucherNumber,
    required this.voucherType,
    required this.date,
    required this.narration,
    required this.accountCode,
    required this.accountName,
    required this.debit,
    required this.credit,
    required this.runningBalance,
    required this.balanceType,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> j) {
    double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

    // account may be nested or flat
    final Map<String, dynamic> acc = j['account'] is Map
        ? Map<String, dynamic>.from(j['account'] as Map)
        : {};

    return LedgerEntry(
      id: (j['id'] as num?)?.toInt() ?? 0,
      voucherNumber: j['voucher_number']?.toString() ??
          (j['voucher'] is Map
              ? (j['voucher'] as Map)['voucher_number']?.toString() ?? ''
              : ''),
      voucherType: j['voucher_type']?.toString() ??
          (j['voucher'] is Map
              ? (j['voucher'] as Map)['voucher_type']?.toString() ?? ''
              : ''),
      date: j['date']?.toString() ??
          (j['voucher'] is Map
              ? (j['voucher'] as Map)['date']?.toString() ?? ''
              : ''),
      narration: j['narration']?.toString() ??
          (j['voucher'] is Map
              ? (j['voucher'] as Map)['narration']?.toString() ?? ''
              : ''),
      accountCode: acc['code']?.toString() ?? j['account_code']?.toString() ?? '',
      accountName: acc['name']?.toString() ?? j['account_name']?.toString() ?? '',
      debit: _d(j['debit']),
      credit: _d(j['credit']),
      runningBalance: _d(j['running_balance'] ?? j['balance']),
      balanceType: j['balance_type']?.toString() ?? 'Dr',
    );
  }
}

class AccountLedger {
  final String accountCode;
  final String accountName;
  final double openingBalance;
  final String openingBalanceType;
  final double closingBalance;
  final String closingBalanceType;
  final List<LedgerEntry> entries;

  AccountLedger({
    required this.accountCode,
    required this.accountName,
    required this.openingBalance,
    required this.openingBalanceType,
    required this.closingBalance,
    required this.closingBalanceType,
    required this.entries,
  });

  factory AccountLedger.fromJson(Map<String, dynamic> j) {
    double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

    final Map<String, dynamic> data =
        j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : j;

    final Map<String, dynamic> acc = data['account'] is Map
        ? Map<String, dynamic>.from(data['account'] as Map)
        : {};

    final List<dynamic> rawEntries =
        data['entries'] is List ? data['entries'] as List : [];

    return AccountLedger(
      accountCode: acc['code']?.toString() ?? '',
      accountName: acc['name']?.toString() ?? '',
      openingBalance: _d(data['opening_balance']),
      openingBalanceType: data['opening_balance_type']?.toString() ?? 'Dr',
      closingBalance: _d(data['closing_balance']),
      closingBalanceType: data['closing_balance_type']?.toString() ?? 'Dr',
      entries: rawEntries
          .whereType<Map>()
          .map((e) => LedgerEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
