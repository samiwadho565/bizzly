double _d(dynamic v) => (v as num?)?.toDouble() ?? double.tryParse(v?.toString() ?? '') ?? 0.0;
int _i(dynamic v) => (v as num?)?.toInt() ?? int.tryParse(v?.toString() ?? '') ?? 0;

/// One debit/credit line inside a ledger entry (or account ledger).
class LedgerLine {
  final int id;
  final String lineType; // debit | credit
  final double amount;
  final double debit;
  final double credit;
  final double? runningBalance;
  final String? balanceSide; // debit | credit
  final int? voucherLineId;
  final int accountId;
  final String accountCode;
  final String accountName;
  final String? normalBalance; // debit | credit
  final String? createdAt;

  LedgerLine({
    required this.id,
    required this.lineType,
    required this.amount,
    required this.debit,
    required this.credit,
    this.runningBalance,
    this.balanceSide,
    this.voucherLineId,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    this.normalBalance,
    this.createdAt,
  });

  factory LedgerLine.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic> acc =
        j['account'] is Map ? Map<String, dynamic>.from(j['account'] as Map) : {};

    return LedgerLine(
      id: _i(j['id']),
      lineType: j['line_type']?.toString() ?? '',
      amount: _d(j['amount']),
      debit: _d(j['debit']),
      credit: _d(j['credit']),
      runningBalance: j['running_balance'] == null ? null : _d(j['running_balance']),
      balanceSide: j['balance_side']?.toString(),
      voucherLineId: j['voucher_line_id'] == null ? null : _i(j['voucher_line_id']),
      accountId: _i(acc['id']),
      accountCode: acc['account_code']?.toString() ?? '',
      accountName: acc['account_name']?.toString() ?? '',
      normalBalance: acc['normal_balance']?.toString(),
      createdAt: j['created_at']?.toString(),
    );
  }
}

/// A posted journal/voucher entry, containing one or more debit/credit lines.
class LedgerEntry {
  final int id;
  final String entryNumber;
  final String entryDate;
  final String narration;
  final double totalDebit;
  final double totalCredit;
  final String? postedAt;
  final int? voucherId;
  final String voucherNumber;
  final String voucherType;
  final String? voucherStatus;
  final List<LedgerLine> lines;
  final String? createdAt;

  LedgerEntry({
    required this.id,
    required this.entryNumber,
    required this.entryDate,
    required this.narration,
    required this.totalDebit,
    required this.totalCredit,
    this.postedAt,
    this.voucherId,
    required this.voucherNumber,
    required this.voucherType,
    this.voucherStatus,
    required this.lines,
    this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic> voucher =
        j['voucher'] is Map ? Map<String, dynamic>.from(j['voucher'] as Map) : {};

    final List<dynamic> rawLines = j['lines'] is List ? j['lines'] as List : [];

    return LedgerEntry(
      id: _i(j['id']),
      entryNumber: j['entry_number']?.toString() ?? '',
      entryDate: j['entry_date']?.toString() ?? '',
      narration: j['narration']?.toString() ?? '',
      totalDebit: _d(j['total_debit']),
      totalCredit: _d(j['total_credit']),
      postedAt: j['posted_at']?.toString(),
      voucherId: voucher['id'] == null ? null : _i(voucher['id']),
      voucherNumber: voucher['voucher_number']?.toString() ?? '',
      voucherType: voucher['voucher_type']?.toString() ?? '',
      voucherStatus: voucher['status']?.toString(),
      lines: rawLines
          .whereType<Map>()
          .map((e) => LedgerLine.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: j['created_at']?.toString(),
    );
  }
}

class AccountLedgerTotals {
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;
  final String? normalBalance;
  final String? balanceSide;

  AccountLedgerTotals({
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
    this.normalBalance,
    this.balanceSide,
  });

  factory AccountLedgerTotals.fromJson(Map<String, dynamic> j) {
    return AccountLedgerTotals(
      totalDebit: _d(j['total_debit']),
      totalCredit: _d(j['total_credit']),
      closingBalance: _d(j['closing_balance']),
      normalBalance: j['normal_balance']?.toString(),
      balanceSide: j['balance_side']?.toString(),
    );
  }
}

class AccountLedger {
  final int accountId;
  final String accountCode;
  final String accountName;
  final String? normalBalance;
  final String? nature;
  final List<LedgerLine> lines;
  final AccountLedgerTotals totals;

  AccountLedger({
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    this.normalBalance,
    this.nature,
    required this.lines,
    required this.totals,
  });

  /// Convenience getters so old call-sites (opening/closing balance) keep working.
  double get closingBalance => totals.closingBalance;
  String get closingBalanceType => (totals.balanceSide ?? totals.normalBalance ?? 'debit') == 'credit' ? 'Cr' : 'Dr';

  factory AccountLedger.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic> data =
        j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : j;

    final Map<String, dynamic> acc =
        data['account'] is Map ? Map<String, dynamic>.from(data['account'] as Map) : {};

    final List<dynamic> rawLines = data['lines'] is List ? data['lines'] as List : [];

    final Map<String, dynamic> totals =
        data['totals'] is Map ? Map<String, dynamic>.from(data['totals'] as Map) : {};

    return AccountLedger(
      accountId: _i(acc['id']),
      accountCode: acc['account_code']?.toString() ?? '',
      accountName: acc['account_name']?.toString() ?? '',
      normalBalance: acc['normal_balance']?.toString(),
      nature: acc['nature']?.toString(),
      lines: rawLines
          .whereType<Map>()
          .map((e) => LedgerLine.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      totals: AccountLedgerTotals.fromJson(totals),
    );
  }
}
