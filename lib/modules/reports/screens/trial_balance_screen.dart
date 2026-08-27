import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/modules/reports/controllers/trial_balance_controller.dart';
import 'package:bizly/modules/reports/models/trial_balance_model.dart';
import 'package:bizly/modules/reports/screens/report_date_filter.dart';
import 'package:bizly/modules/vouchers/controllers/voucher_controller.dart' show CrmDropdownItem;
import 'package:bizly/utils/app_colors.dart';

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
          // ── Business Filter ─────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _BusinessFilterButton(controller: controller),
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
      final Color statusColor =
          report.isBalanced ? const Color(0xFF00E676) : const Color(0xFFFF8A80);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D47A1).withOpacity(0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
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
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    report.isBalanced ? 'Balanced' : 'Unbalanced',
                    style: TextStyle(
                      color: statusColor,
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
    // Group accounts under their parent (e.g. "A1000 · Current Assets"),
    // preserving first-seen order, so the trial balance reads like a
    // grouped ledger instead of one flat list.
    final Map<String, List<TrialBalanceAccount>> groups = {};
    final Map<String, String> groupLabels = {};
    for (final a in accounts) {
      final String key = a.parent != null ? a.parent!.accountCode : '—';
      final String label = a.parent != null
          ? (a.parent!.accountCode.isNotEmpty
              ? '${a.parent!.accountCode} · ${a.parent!.accountName}'
              : a.parent!.accountName)
          : 'Ungrouped';
      groups.putIfAbsent(key, () => []).add(a);
      groupLabels[key] = label;
    }

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
          const SizedBox(height: 4),
          Text(
            '${accounts.length} account${accounts.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
            ...groups.entries.expand((entry) => [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
                    child: Text(
                      groupLabels[entry.key] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  ...entry.value.map(_accountRow),
                ]),
        ],
      ),
    );
  }

  Widget _accountRow(TrialBalanceAccount account) {
    final Color natureColor = _natureColor(account.nature);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
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
                    color: natureColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(account.accountCode,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: natureColor)),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  account.accountName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              if (account.isContra) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text('Contra',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black54)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  account.normalBalance != null
                      ? '${account.nature} · Normal: ${account.normalBalance}'
                      : account.nature,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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
        ],
      ),
    );
  }

  Color _natureColor(String nature) {
    switch (nature.toLowerCase().trim()) {
      case 'asset':
        return const Color(0xFF1976D2);
      case 'liability':
        return const Color(0xFFE53935);
      case 'equity':
      case 'capital':
        return const Color(0xFF7B1FA2);
      case 'income':
      case 'revenue':
        return const Color(0xFF388E3C);
      case 'expense':
        return const Color(0xFFF57C00);
      case 'contra':
        return const Color(0xFF6D4C41);
      default:
        return Colors.grey;
    }
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

// ── Business Filter Button + Sheet ──────────────────────────────────
class _BusinessFilterButton extends StatelessWidget {
  const _BusinessFilterButton({required this.controller});
  final TrialBalanceController controller;

  void _open(BuildContext context) {
    controller.fetchFilterBusinesses();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BusinessFilterSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final CrmDropdownItem? selected = controller.filterBusiness.value;
      return GestureDetector(
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apartment_rounded, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selected != null ? selected.name : 'All businesses',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary.withOpacity(0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary.withOpacity(0.6)),
            ],
          ),
        ),
      );
    });
  }
}

class _BusinessFilterSheet extends StatelessWidget {
  const _BusinessFilterSheet({required this.controller});
  final TrialBalanceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter by Business',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                      Text('Restrict the report to one business',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Obx(() {
              if (controller.isLoadingFilterBusinesses.value && controller.filterBusinessList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
              }
              final CrmDropdownItem? selected = controller.filterBusiness.value;
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _businessOption(
                    context,
                    label: 'All businesses',
                    isSelected: selected == null,
                    onTap: () {
                      controller.applyBusiness(null);
                      Navigator.pop(context);
                    },
                  ),
                  ...controller.filterBusinessList.map((b) => _businessOption(
                        context,
                        label: b.name.isNotEmpty ? b.name : 'Business #${b.id}',
                        isSelected: selected?.id == b.id,
                        onTap: () {
                          controller.applyBusiness(b);
                          Navigator.pop(context);
                        },
                      )),
                  if (!controller.isLoadingFilterBusinesses.value && controller.filterBusinessList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No businesses found', style: TextStyle(color: Colors.grey.shade500)),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _businessOption(BuildContext context,
      {required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}


