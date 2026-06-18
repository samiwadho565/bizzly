import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/modules/reports/controllers/trial_balance_controller.dart';
import 'package:bizly/modules/reports/models/trial_balance_model.dart';
import 'package:bizly/modules/reports/screens/report_date_filter.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/date_formats.dart';

class TrialBalanceScreen extends GetView<TrialBalanceController> {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientScreenHeader(title: 'Trial Balance'),
          // ── Date Chips ─────────────────────────────────────────
          ReportRangeChips(
            selectedPreset: controller.selectedPreset,
            onPresetSelected: controller.applyPreset,
            onCustom: () => _showCustomRangeSheet(context),
          ),
          // ── Content ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.report.value == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
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
                              : 'No trial balance data found.',
                          style:
                              TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final TrialBalanceModel report = controller.report.value!;
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchReport,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  children: [
                    _header(report),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            label: 'Total Debit',
                            value: report.totalDebit,
                            color: const Color(0xFF2E7D32),
                            icon: Icons.arrow_circle_down_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            label: 'Total Credit',
                            value: report.totalCredit,
                            color: AppColors.primary,
                            icon: Icons.arrow_circle_up_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _accountsSection(report.accounts),
                    const SizedBox(height: 16),
                    _transactionsSection(report.transactions),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showCustomRangeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomRangeSheet(
        initialFrom: controller.fromDate.value,
        initialTo: controller.toDate.value,
        onApply: controller.applyCustomRange,
      ),
    );
  }

  Widget _header(TrialBalanceModel report) {
    return Obx(() {
      final String from =
          DateFormat('dd MMM yyyy').format(controller.fromDate.value);
      final String to =
          DateFormat('dd MMM yyyy').format(controller.toDate.value);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D47A1).withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.balance_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from  →  $to',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (controller.isLoading.value)
                    const Text(
                      'Refreshing...',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 11),
                    ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: report.isBalanced
                    ? const Color(0xFF00E676).withOpacity(0.18)
                    : Colors.red.withOpacity(0.18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: report.isBalanced
                      ? const Color(0xFF00E676).withOpacity(0.40)
                      : Colors.red.withOpacity(0.40),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: report.isBalanced
                          ? const Color(0xFF00E676)
                          : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    report.isBalanced ? 'Balanced' : 'Unbalanced',
                    style: TextStyle(
                      color: report.isBalanced
                          ? const Color(0xFF00E676)
                          : Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryCard({
    required String label,
    required num value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatMoney(value),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountsSection(List<TrialBalanceAccount> accounts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accounts',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    'Debit',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 90,
                  child: Text(
                    'Credit',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (accounts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'No accounts found.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...accounts.map(_accountRow),
        ],
      ),
    );
  }

  Widget _accountRow(TrialBalanceAccount account) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              account.accountName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              _compactMoney(account.debit),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              _compactMoney(account.credit),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionsSection(List<TrialBalanceTransaction> items) {
    final bool showAll = controller.showAllTransactions.value;
    final List<TrialBalanceTransaction> visibleItems =
        showAll ? items : items.take(12).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transactions',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'No transactions found.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...visibleItems.map(_transactionTile),
          if (items.length > 12)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: controller.toggleTransactionsVisibility,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    showAll
                        ? 'Show Less'
                        : 'Show More (+${items.length - visibleItems.length})',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _transactionTile(TrialBalanceTransaction item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.accountName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'D ${_compactMoney(item.debit)}',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'C ${_compactMoney(item.credit)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (item.date.isNotEmpty) _metaChip(_formatDate(item.date)),
              if ((item.category ?? '').isNotEmpty)
                _metaChip(item.category!),
              if ((item.referenceNumber ?? '').isNotEmpty)
                _metaChip('Ref: ${item.referenceNumber}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(String value) {
    final DateTime? date = DateTime.tryParse(value);
    if (date == null) return value;
    return DateFormats.dMonY(date);
  }

  String _formatMoney(num value) {
    final bool isWhole = value % 1 == 0;
    final String text = isWhole
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return 'PKR $text';
  }

  String _compactMoney(num value) {
    final bool isWhole = value % 1 == 0;
    return isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }
}


