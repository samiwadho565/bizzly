import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/modules/reports/controllers/income_statement_controller.dart';
import 'package:bizly/modules/reports/models/income_statement_model.dart';
import 'package:bizly/modules/reports/screens/report_date_filter.dart';
import 'package:bizly/utils/app_colors.dart';

class IncomeStatementScreen extends GetView<IncomeStatementController> {
  const IncomeStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientScreenHeader(title: 'Income Statement'),
          // ── Date Chips ───────────────────────────────────────
          ReportRangeChips(
            selectedPreset: controller.selectedPreset,
            onPresetSelected: controller.applyPreset,
            onCustom: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CustomRangeSheet(
                initialFrom: controller.fromDate.value,
                initialTo: controller.toDate.value,
                onApply: controller.applyCustomRange,
              ),
            ),
          ),
          // ── Content ─────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.report.value == null) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.report.value == null) {
                return RefreshIndicator(
                  onRefresh: controller.fetchReport,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 140),
                      Center(
                        child: Text(
                          controller.error.value.isNotEmpty
                              ? controller.error.value
                              : 'No data found.',
                          style:
                              TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final IncomeStatementModel report = controller.report.value!;
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchReport,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    // ── Net Income Summary Card ────────────────
                    _SummaryCard(report: report),
                    const SizedBox(height: 20),

                    // ── Revenue ───────────────────────────────
                    if (report.revenueSections.isNotEmpty) ...[
                      _SectionHeader(
                        label: 'Revenue',
                        total: report.totalRevenue,
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 8),
                      ...report.revenueSections
                          .where((s) => s.accounts.isNotEmpty)
                          .expand((s) => [
                                _SubSectionLabel(
                                  code: s.sectionCode,
                                  name: s.sectionName,
                                  total: s.netTotal,
                                  color: const Color(0xFF2E7D32),
                                ),
                                ...s.accounts.map(
                                  (a) => _LineItem(account: a, color: const Color(0xFF2E7D32)),
                                ),
                              ]),
                      const SizedBox(height: 20),
                    ],

                    // ── Expenses ──────────────────────────────
                    if (report.expenseSections.isNotEmpty) ...[
                      _SectionHeader(
                        label: 'Expenses',
                        total: report.totalExpenses,
                        color: const Color(0xFFC62828),
                      ),
                      const SizedBox(height: 8),
                      ...report.expenseSections
                          .where((s) => s.accounts.isNotEmpty)
                          .expand((s) => [
                                _SubSectionLabel(
                                  code: s.sectionCode,
                                  name: s.sectionName,
                                  total: s.netTotal,
                                  color: const Color(0xFFC62828),
                                ),
                                ...s.accounts.map(
                                  (a) => _LineItem(account: a, color: const Color(0xFFC62828)),
                                ),
                              ]),
                      const SizedBox(height: 20),
                    ],

                    // ── Net Income Footer ─────────────────────
                    _NetIncomeFooter(netIncome: report.netIncome),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});
  final IncomeStatementModel report;

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final bool isProfit = report.netIncome >= 0;
    final List<Color> colors = isProfit
        ? [const Color(0xFF00897B), const Color(0xFF004D40)]
        : [const Color(0xFFE53935), const Color(0xFFB71C1C)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isProfit ? 'Net Profit' : 'Net Loss',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _fmt(report.netIncome.abs()),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MiniStat(
                        label: 'Revenue',
                        value: _fmt(report.totalRevenue),
                        positive: true),
                    const SizedBox(height: 8),
                    _MiniStat(
                        label: 'Expenses',
                        value: _fmt(report.totalExpenses),
                        positive: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.positive});
  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Colors.white.withOpacity(0.7))),
        const SizedBox(width: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.label, required this.total, required this.color});
  final String label;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            NumberFormat('#,##0.00').format(total),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-section label (e.g. "G2000 · Other Misc Revenue") ─────────
class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel(
      {required this.code, required this.name, required this.total, required this.color});
  final String code;
  final String name;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code.isNotEmpty ? '$code · $name' : name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: color.withOpacity(0.75),
              ),
            ),
          ),
          Text(
            NumberFormat('#,##0.00').format(total),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }
}

// ── Line Item ─────────────────────────────────────────────────────
class _LineItem extends StatelessWidget {
  const _LineItem({required this.account, required this.color});
  final IncomeStatementAccount account;
  final Color color;

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final bool hasContra = account.contraAccounts.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (account.accountCode.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(account.accountCode,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(account.accountName,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3D3D3D))),
              ),
              Text(
                _fmt(hasContra ? account.grossBalance : account.netBalance),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
          // Contra accounts (e.g. Sales Return netted against Sales) —
          // shown as deductions with the final net balance below.
          if (hasContra) ...[
            const SizedBox(height: 6),
            ...account.contraAccounts.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 3),
                  child: Row(
                    children: [
                      Icon(Icons.subdirectory_arrow_right_rounded,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${c.accountCode.isNotEmpty ? '${c.accountCode} · ' : ''}${c.accountName} (contra)',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ),
                      Text(
                        '- ${_fmt(c.netBalance)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 12),
            Row(
              children: [
                const Spacer(),
                Text('Net: ',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                Text(
                  _fmt(account.netBalance),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Net Income Footer ─────────────────────────────────────────────
class _NetIncomeFooter extends StatelessWidget {
  const _NetIncomeFooter({required this.netIncome});
  final double netIncome;

  @override
  Widget build(BuildContext context) {
    final bool profit = netIncome >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: profit
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: profit
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            profit
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: profit
                ? const Color(0xFF2E7D32)
                : const Color(0xFFC62828),
          ),
          const SizedBox(width: 10),
          Text(
            profit ? 'Net Profit' : 'Net Loss',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: profit
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
          const Spacer(),
          Text(
            NumberFormat('#,##0.00').format(netIncome.abs()),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: profit
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }
}
