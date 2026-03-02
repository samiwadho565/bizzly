import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/top_border_ccontainer.dart';
import 'package:bizly/modules/reports/controllers/balance_sheet_controller.dart';
import 'package:bizly/modules/reports/models/balance_sheet_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/date_formats.dart';

class BalanceSheetScreen extends GetView<BalanceSheetController> {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(
        title: 'Balance Sheet',
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 16,
            color: AppColors.primaryDense,
          ),
          Expanded(
            child: TopBorderContainer(
              child: Obx(() {
                if (controller.isLoading.value && controller.report.value == null) {
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
                                : 'No balance sheet data found.',
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final BalanceSheetModel report = controller.report.value!;
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.fetchReport,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      children: [
                        _reportHeader(report),
                        const SizedBox(height: 16),
                        _summaryRow(
                          leftLabel: 'Total Assets',
                          leftValue: report.totalAssets,
                          rightLabel: 'L + E',
                          rightValue: report.totalLiabilitiesAndEquity,
                        ),
                        const SizedBox(height: 16),
                        _groupCard(
                          title: 'Current Assets',
                          group: report.currentAssets,
                          accent: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _groupCard(
                          title: 'Fixed Assets',
                          group: report.fixedAssets,
                          accent: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        _groupCard(
                          title: 'Current Liabilities',
                          group: report.currentLiabilities,
                          accent: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _equityCard(report),
                        const SizedBox(height: 18),
                        _detailSection(
                          title: 'Cash Transactions',
                          items: report.details.cashTransactions,
                        ),
                        const SizedBox(height: 12),
                        _detailSection(
                          title: 'Receivables',
                          items: report.details.receivablesTransactions,
                        ),
                        const SizedBox(height: 12),
                        _detailSection(
                          title: 'Income',
                          items: report.details.incomeTransactions,
                        ),
                        const SizedBox(height: 12),
                        _detailSection(
                          title: 'Expenses',
                          items: report.details.expenseTransactions,
                        ),
                        const SizedBox(height: 12),
                        _detailSection(
                          title: 'Asset Records',
                          items: report.details.assetTransactions,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportHeader(BalanceSheetModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDense,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'As Of Date',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(report.asOfDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: report.isBalanced
                  ? Colors.green.withOpacity(0.18)
                  : Colors.red.withOpacity(0.18),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              report.isBalanced ? 'Balanced' : 'Unbalanced',
              style: TextStyle(
                color: report.isBalanced ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String leftLabel,
    required num leftValue,
    required String rightLabel,
    required num rightValue,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryTile(
            label: leftLabel,
            value: leftValue,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryTile(
            label: rightLabel,
            value: rightValue,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String label,
    required num value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
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
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatMoney(value),
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard({
    required String title,
    required BalanceSheetValueGroup group,
    required Color accent,
  }) {
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
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatMoney(group.total),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (group.values.isEmpty)
            const Text(
              'No records',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...group.values.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _humanize(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      _formatMoney(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _equityCard(BalanceSheetModel report) {
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
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equity',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'Retained Earnings',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatMoney(report.retainedEarnings),
            style: TextStyle(
              color: report.retainedEarnings < 0 ? Colors.red : AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required List<BalanceSheetTransaction> items,
  }) {
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
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'No transactions',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...items.take(8).map(_transactionTile),
          if (items.length > 8)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${items.length - 8} more records',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _transactionTile(BalanceSheetTransaction item) {
    final num? primaryValue =
        item.amount ?? item.value ?? item.remainingAmount ?? item.totalAmount;
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
                child: Text(
                  item.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (primaryValue != null)
                Text(
                  _formatMoney(primaryValue),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              if (item.date.isNotEmpty) _metaChip(_formatDate(item.date)),
              if ((item.status ?? '').isNotEmpty) _metaChip(_humanize(item.status!)),
              if ((item.category ?? '').isNotEmpty) _metaChip(item.category!),
              if ((item.invoiceNumber ?? '').isNotEmpty) _metaChip(item.invoiceNumber!),
              if ((item.referenceNumber ?? '').isNotEmpty)
                _metaChip('Ref: ${item.referenceNumber}'),
            ],
          ),
          if (item.paidAmount != null || item.remainingAmount != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Paid: ${_formatMoney(item.paidAmount ?? 0)}  Remaining: ${_formatMoney(item.remainingAmount ?? 0)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
    final String text = isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return 'PKR $text';
  }

  String _humanize(String value) {
    final List<String> words = value
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return words
        .map(
          (word) => '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
