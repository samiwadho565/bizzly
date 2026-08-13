import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
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
      body: Column(
        children: [
          const GradientScreenHeader(title: 'Balance Sheet'),
          // ── As-Of Date Chips ─────────────────────────────────
          _AsOfDateChips(
            selectedPreset: controller.selectedPreset,
            onPresetSelected: controller.applyPreset,
            onCustom: () => _showCustomDateSheet(context),
          ),
          Expanded(
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
                        const SizedBox(height: 18),

                        _statementGroup(
                          title: 'Assets',
                          total: report.totalAssets,
                          sections: report.assetSections,
                          accent: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(height: 16),
                        _statementGroup(
                          title: 'Liabilities',
                          total: report.totalLiabilities,
                          sections: report.liabilitySections,
                          accent: const Color(0xFFC62828),
                        ),
                        const SizedBox(height: 16),
                        _statementGroup(
                          title: 'Capital / Equity',
                          total: report.totalCapital,
                          sections: report.capitalSections,
                          accent: const Color(0xFF6A1B9A),
                          trailing: (report.currentYearEarningsLabel != null)
                              ? _currentYearEarningsRow(report)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
            }),
          ),
        ],
      ),
    );
  }

  Widget _reportHeader(BalanceSheetModel report) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B4B), Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -25,
            right: -25,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Row(
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
                      ? Colors.green.withOpacity(0.20)
                      : Colors.red.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: report.isBalanced
                        ? Colors.greenAccent.withOpacity(0.40)
                        : Colors.redAccent.withOpacity(0.40),
                  ),
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

  // ── Statement group (Assets / Liabilities / Capital) ─────────────
  // Renders each section (with its subtotal) and every account line,
  // including any contra accounts netted against it.
  Widget _statementGroup({
    required String title,
    required double total,
    required List<BalanceSheetSection> sections,
    required Color accent,
    Widget? trailing,
  }) {
    final List<BalanceSheetSection> nonEmpty =
        sections.where((s) => s.accounts.isNotEmpty).toList();

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
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Text(
                _formatMoney(total),
                style: TextStyle(color: accent, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (nonEmpty.isEmpty)
            if (trailing == null)
              const Text('No accounts posted in this category',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12))
            else
              const SizedBox.shrink()
          else
            ...nonEmpty.expand((s) => [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.sectionCode.isNotEmpty
                                ? '${s.sectionCode} · ${s.sectionName}'
                                : s.sectionName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: accent.withOpacity(0.75),
                            ),
                          ),
                        ),
                        Text(
                          _formatMoney(s.netTotal),
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: accent.withOpacity(0.75)),
                        ),
                      ],
                    ),
                  ),
                  ...s.accounts.map((a) => _accountLine(a, accent)),
                ]),
          if (trailing != null) ...[
            const SizedBox(height: 4),
            const Divider(height: 20),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _accountLine(BalanceSheetAccount account, Color accent) {
    final bool hasContra = account.contraAccounts.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
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
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(account.accountCode,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(account.accountName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                _formatMoney(hasContra ? account.grossBalance : account.netBalance),
                style: TextStyle(fontWeight: FontWeight.w700, color: accent),
              ),
            ],
          ),
          if (account.normalBalance != null || account.debit > 0 || account.credit > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (account.debit > 0 || account.credit > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: (account.debit > 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      account.debit > 0 ? 'DR ${_formatMoney(account.debit)}' : 'CR ${_formatMoney(account.credit)}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: account.debit > 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (account.normalBalance != null)
                  Text(
                    'Normal: ${account.normalBalance}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ],
          if (hasContra) ...[
            const SizedBox(height: 6),
            ...account.contraAccounts.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 3),
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
                      Text('- ${_formatMoney(c.netBalance)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                )),
            const Divider(height: 12),
            Row(
              children: [
                const Spacer(),
                Text('Net: ',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
                Text(_formatMoney(account.netBalance),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: accent)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _currentYearEarningsRow(BalanceSheetModel report) {
    return Row(
      children: [
        Expanded(
          child: Text(
            report.currentYearEarningsLabel ?? 'Current Year Earnings',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          _formatMoney(report.currentYearEarningsAmount),
          style: TextStyle(
            color: report.currentYearEarningsAmount < 0 ? Colors.red : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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

  void _showCustomDateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AsOfCustomDateSheet(
        initialDate: controller.asOfDate.value,
        onApply: controller.applyCustomDate,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// As-Of Date Chip Data
// ─────────────────────────────────────────────────────────────────────────────

class _AsOfChip {
  const _AsOfChip({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.gradientEnd,
  });
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
}

const List<_AsOfChip> _asOfChips = [
  _AsOfChip(
    key: 'today',
    label: 'Today',
    icon: Icons.today_rounded,
    color: Color(0xFF00897B),
    gradientEnd: Color(0xFF004D40),
  ),
  _AsOfChip(
    key: 'end_of_month',
    label: 'Month End',
    icon: Icons.calendar_month_rounded,
    color: Color(0xFF1E88E5),
    gradientEnd: Color(0xFF0D47A1),
  ),
  _AsOfChip(
    key: 'end_of_quarter',
    label: 'Qtr End',
    icon: Icons.bar_chart_rounded,
    color: Color(0xFF8E24AA),
    gradientEnd: Color(0xFF4A148C),
  ),
  _AsOfChip(
    key: 'end_of_year',
    label: 'Year End',
    icon: Icons.event_rounded,
    color: Color(0xFFF57C00),
    gradientEnd: Color(0xFFE65100),
  ),
  _AsOfChip(
    key: 'custom',
    label: 'Custom',
    icon: Icons.tune_rounded,
    color: Color(0xFF546E7A),
    gradientEnd: Color(0xFF263238),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// As-Of Date Chips Widget
// ─────────────────────────────────────────────────────────────────────────────

class _AsOfDateChips extends StatelessWidget {
  const _AsOfDateChips({
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.onCustom,
  });

  final RxString selectedPreset;
  final void Function(String) onPresetSelected;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String current = selectedPreset.value;
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _asOfChips.map((chip) {
              final bool selected = current == chip.key;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    if (chip.key == 'custom') {
                      onCustom();
                    } else {
                      onPresetSelected(chip.key);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: [chip.color, chip.gradientEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: selected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: chip.color.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withOpacity(0.20)
                                : chip.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            chip.icon,
                            size: 14,
                            color: selected ? Colors.white : chip.color,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          chip.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF3D3D3D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom As-Of Date Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AsOfCustomDateSheet extends StatefulWidget {
  const _AsOfCustomDateSheet({
    required this.initialDate,
    required this.onApply,
  });

  final DateTime initialDate;
  final void Function(DateTime) onApply;

  @override
  State<_AsOfCustomDateSheet> createState() => _AsOfCustomDateSheetState();
}

class _AsOfCustomDateSheetState extends State<_AsOfCustomDateSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  String _fmtDisplay(DateTime d) => DateFormat('d MMM yyyy').format(d);

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0D47A1),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select As-Of Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          // Date tile
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF0D47A1).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF0D47A1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'As Of Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fmtDisplay(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_calendar_rounded,
                    color: Color(0xFF0D47A1),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D47A1).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onApply(_selectedDate);
                },
                child: const Text(
                  'Apply Date',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
