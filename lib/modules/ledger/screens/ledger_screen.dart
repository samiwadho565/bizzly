import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/modules/ledger/controllers/ledger_controller.dart';
import 'package:bizly/modules/ledger/models/ledger_model.dart';
import 'package:bizly/modules/ledger/screens/account_ledger_screen.dart';
import 'package:bizly/modules/ledger/screens/ledger_entry_detail_screen.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/gradient_screen_header.dart';

class LedgerScreen extends GetView<LedgerController> {
  const LedgerScreen({super.key});

  void _openAccountPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountPickerSheet(
        onSelect: (CoaDropdownItem item) {
          Get.back(); // close sheet
          Get.to(() => AccountLedgerScreen(
                accountId: item.id,
                accountCode: item.accountCode,
                accountName: item.accountName,
              ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientScreenHeader(title: 'General Ledger'),

          // ── Select Account (chart of accounts dropdown) ─────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: GestureDetector(
              onTap: () => _openAccountPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'View ledger for an account…',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ),

          Expanded(child: Obx(() {
        if (controller.isLoading.value && controller.entries.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.error.value.isNotEmpty && controller.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(controller.error.value,
                    style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.fetchEntries,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (controller.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined,
                    size: 56, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Text('No ledger entries yet',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchEntries,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final LedgerEntry e = controller.entries[i];
              return _LedgerEntryCard(
                entry: e,
                onTap: () => Get.to(() => LedgerEntryDetailScreen(entryId: e.id)),
              );
            },
          ),
        );
      })),
        ],
      ),
    );
  }
}

// ── Account Picker Sheet (Chart of Accounts dropdown) ──────────────
class _AccountPickerSheet extends GetView<LedgerController> {
  const _AccountPickerSheet({required this.onSelect});
  final ValueChanged<CoaDropdownItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    Text(
                      'Select Account',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingCoa.value && controller.coaDropdown.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (controller.coaDropdown.isEmpty) {
                    return Center(
                      child: Text('No accounts found',
                          style: TextStyle(color: Colors.grey.shade500)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: controller.coaDropdown.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final CoaDropdownItem item = controller.coaDropdown[i];
                      return ListTile(
                        dense: true,
                        title: Text(
                          item.label.isNotEmpty
                              ? item.label
                              : '${item.accountCode}  ${item.accountName}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          item.nature.isNotEmpty ? item.nature : item.accountCode,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        onTap: () => onSelect(item),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LedgerEntryCard extends StatelessWidget {
  const _LedgerEntryCard({required this.entry, this.onTap});
  final LedgerEntry entry;
  final VoidCallback? onTap;

  Color get _typeColor {
    switch (entry.voucherType.toLowerCase()) {
      case 'receipt':
        return const Color(0xFF2E7D32);
      case 'payment':
        return const Color(0xFFC62828);
      case 'journal':
        return const Color(0xFF1565C0);
      case 'contra':
        return const Color(0xFF6A1B9A);
      case 'adjustment':
        return const Color(0xFF8E24AA);
      default:
        return AppColors.primary;
    }
  }

  String get _formattedDate {
    try {
      final DateTime d = DateTime.parse(entry.entryDate);
      return DateFormat('dd MMM yyyy').format(d);
    } catch (_) {
      return entry.entryDate;
    }
  }

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  double _balanceDiff(LedgerEntry e) => (e.totalDebit - e.totalCredit).abs();

  bool _isBalanced(LedgerEntry e) => _balanceDiff(e) < 0.005;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.voucherType.isNotEmpty
                        ? entry.voucherType.toUpperCase()
                        : 'ENTRY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _typeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.voucherNumber.isNotEmpty
                        ? entry.voucherNumber
                        : entry.entryNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Text(
                  _formattedDate,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entry number + narration
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_outlined,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.entryNumber,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          if (entry.narration.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.narration,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 8),

                // One row per account line (debit or credit)
                ...entry.lines.map((line) {
                  final bool isDebit = line.debit > 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.accountName.isNotEmpty
                                ? '${line.accountCode}  ${line.accountName}'
                                : line.accountCode,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            isDebit ? _fmt(line.debit) : '',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            !isDebit ? _fmt(line.credit) : '',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC62828),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 8),

                // Totals row
                Row(
                  children: [
                    Expanded(
                      child: _AmountTile(
                        label: 'Total Debit',
                        value: _fmt(entry.totalDebit),
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFF0F0F0)),
                    Expanded(
                      child: _AmountTile(
                        label: 'Total Credit',
                        value: _fmt(entry.totalCredit),
                        color: const Color(0xFFC62828),
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFF0F0F0)),
                    Expanded(
                      child: _AmountTile(
                        label: _isBalanced(entry) ? 'Balance' : 'Out of Balance',
                        value: _isBalanced(entry) ? 'Balanced' : _fmt(_balanceDiff(entry)),
                        color: _isBalanced(entry)
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
