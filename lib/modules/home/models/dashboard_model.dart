class DashboardModel {
  final DashboardSummary summary;
  final DashboardPeriod? accountingPeriod;
  final List<DashboardVoucher> recentVouchers;

  DashboardModel({
    required this.summary,
    this.accountingPeriod,
    required this.recentVouchers,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic> data =
        j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : j;

    return DashboardModel(
      summary: DashboardSummary.fromJson(
        data['summary'] is Map
            ? Map<String, dynamic>.from(data['summary'] as Map)
            : {},
      ),
      accountingPeriod: data['accounting_period'] is Map
          ? DashboardPeriod.fromJson(
              Map<String, dynamic>.from(data['accounting_period'] as Map))
          : null,
      recentVouchers: data['recent_vouchers'] is List
          ? (data['recent_vouchers'] as List)
              .whereType<Map>()
              .map((e) => DashboardVoucher.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }
}

class DashboardSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double netLoss;
  final bool isProfit;
  final double totalAssets;
  final double cashAndBank;
  final double accountsReceivable;
  final double accountsPayable;
  final int pendingVoucherApprovals;
  final int postedVouchers;
  final int totalTeamMembers;
  final int pendingTasks;

  DashboardSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.netLoss,
    required this.isProfit,
    required this.totalAssets,
    required this.cashAndBank,
    required this.accountsReceivable,
    required this.accountsPayable,
    required this.pendingVoucherApprovals,
    required this.postedVouchers,
    required this.totalTeamMembers,
    required this.pendingTasks,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) {
    double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
    int _i(dynamic v) => (v as num?)?.toInt() ?? 0;
    return DashboardSummary(
      totalRevenue: _d(j['total_revenue']),
      totalExpenses: _d(j['total_expenses']),
      netProfit: _d(j['net_profit']),
      netLoss: _d(j['net_loss']),
      isProfit: j['is_profit'] == true,
      totalAssets: _d(j['total_assets']),
      cashAndBank: _d(j['cash_and_bank']),
      accountsReceivable: _d(j['accounts_receivable']),
      accountsPayable: _d(j['accounts_payable']),
      pendingVoucherApprovals: _i(j['pending_voucher_approvals']),
      postedVouchers: _i(j['posted_vouchers']),
      totalTeamMembers: _i(j['total_team_members']),
      pendingTasks: _i(j['pending_tasks']),
    );
  }
}

class DashboardPeriod {
  final int id;
  final String name;
  final String startDate;
  final String endDate;

  DashboardPeriod({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory DashboardPeriod.fromJson(Map<String, dynamic> j) {
    return DashboardPeriod(
      id: (j['id'] as num?)?.toInt() ?? 0,
      name: j['name']?.toString() ?? '',
      startDate: j['start_date']?.toString() ?? '',
      endDate: j['end_date']?.toString() ?? '',
    );
  }
}

class DashboardVoucher {
  final int id;
  final String voucherNumber;
  final String voucherType;
  final String voucherDate;
  final String narration;
  final String status;
  final double totalDebit;
  final double totalCredit;

  DashboardVoucher({
    required this.id,
    required this.voucherNumber,
    required this.voucherType,
    required this.voucherDate,
    required this.narration,
    required this.status,
    required this.totalDebit,
    required this.totalCredit,
  });

  factory DashboardVoucher.fromJson(Map<String, dynamic> j) {
    return DashboardVoucher(
      id: (j['id'] as num?)?.toInt() ?? 0,
      voucherNumber: j['voucher_number']?.toString() ?? '',
      voucherType: j['voucher_type']?.toString() ?? '',
      voucherDate: j['voucher_date']?.toString() ?? '',
      narration: j['narration']?.toString() ?? '',
      status: j['status']?.toString() ?? '',
      totalDebit: (j['total_debit'] as num?)?.toDouble() ?? 0.0,
      totalCredit: (j['total_credit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
