double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

class DashboardModel {
  final DashboardSummary summary;
  final DashboardPeriod? accountingPeriod;
  final DashboardReportingPeriod? reportingPeriod;
  final List<DashboardVoucher> recentVouchers;
  final DashboardRevenueCharts revenueCharts;

  DashboardModel({
    required this.summary,
    this.accountingPeriod,
    this.reportingPeriod,
    required this.recentVouchers,
    required this.revenueCharts,
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
      reportingPeriod: data['reporting_period'] is Map
          ? DashboardReportingPeriod.fromJson(
              Map<String, dynamic>.from(data['reporting_period'] as Map))
          : null,
      recentVouchers: data['recent_vouchers'] is List
          ? (data['recent_vouchers'] as List)
              .whereType<Map>()
              .map((e) => DashboardVoucher.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : [],
      revenueCharts: DashboardRevenueCharts.fromJson(
        data['revenue_charts'] is Map
            ? Map<String, dynamic>.from(data['revenue_charts'] as Map)
            : {},
      ),
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
      id: _i(j['id']),
      name: j['name']?.toString() ?? '',
      startDate: j['start_date']?.toString() ?? '',
      endDate: j['end_date']?.toString() ?? '',
    );
  }
}

/// The date range the summary figures were computed over (separate from
/// the accounting period — e.g. year-to-date vs the fiscal year).
class DashboardReportingPeriod {
  final String fromDate;
  final String toDate;

  DashboardReportingPeriod({required this.fromDate, required this.toDate});

  factory DashboardReportingPeriod.fromJson(Map<String, dynamic> j) {
    return DashboardReportingPeriod(
      fromDate: j['from_date']?.toString() ?? '',
      toDate: j['to_date']?.toString() ?? '',
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
  final String? ledgerEntryNumber;
  final String? createdAt;

  DashboardVoucher({
    required this.id,
    required this.voucherNumber,
    required this.voucherType,
    required this.voucherDate,
    required this.narration,
    required this.status,
    required this.totalDebit,
    required this.totalCredit,
    this.ledgerEntryNumber,
    this.createdAt,
  });

  factory DashboardVoucher.fromJson(Map<String, dynamic> j) {
    return DashboardVoucher(
      id: _i(j['id']),
      voucherNumber: j['voucher_number']?.toString() ?? '',
      voucherType: j['voucher_type']?.toString() ?? '',
      voucherDate: j['voucher_date']?.toString() ?? '',
      narration: j['narration']?.toString() ?? '',
      status: j['status']?.toString() ?? '',
      totalDebit: _d(j['total_debit']),
      totalCredit: _d(j['total_credit']),
      ledgerEntryNumber: j['ledger_entry_number']?.toString(),
      createdAt: j['created_at']?.toString(),
    );
  }
}

/// One point on a revenue trend chart (daily/weekly/monthly/yearly all
/// share this shape — only the label field differs per granularity).
class DashboardRevenuePoint {
  final String label;
  final double revenue;

  DashboardRevenuePoint({required this.label, required this.revenue});

  factory DashboardRevenuePoint.fromJson(Map<String, dynamic> j) {
    final String label = (j['date'] ?? j['week'] ?? j['month'] ?? j['year'])?.toString() ?? '';
    return DashboardRevenuePoint(label: label, revenue: _d(j['revenue']));
  }
}

class DashboardRevenueCharts {
  final List<DashboardRevenuePoint> daily;
  final List<DashboardRevenuePoint> weekly;
  final List<DashboardRevenuePoint> monthly;
  final List<DashboardRevenuePoint> yearly;

  DashboardRevenueCharts({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  static List<DashboardRevenuePoint> _parse(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map>()
        .map((e) => DashboardRevenuePoint.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  factory DashboardRevenueCharts.fromJson(Map<String, dynamic> j) {
    return DashboardRevenueCharts(
      daily: _parse(j['daily']),
      weekly: _parse(j['weekly']),
      monthly: _parse(j['monthly']),
      yearly: _parse(j['yearly']),
    );
  }
}
