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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'View ledger for an account…',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withOpacity(0.85),
                        ),
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chevron_right_rounded,
                          size: 16, color: AppColors.primary),
                    ),
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

// ── Nature → color mapping (matches Chart of Accounts styling) ─────
class _NatureStyle {
  static const Map<String, List<Color>> _gradients = {
    'asset': [Color(0xFF1976D2), Color(0xFF0D47A1)],
    'liability': [Color(0xFFE53935), Color(0xFFB71C1C)],
    'equity': [Color(0xFF8E24AA), Color(0xFF4A148C)],
    'capital': [Color(0xFF8E24AA), Color(0xFF4A148C)],
    'income': [Color(0xFF43A047), Color(0xFF1B5E20)],
    'revenue': [Color(0xFF43A047), Color(0xFF1B5E20)],
    'expense': [Color(0xFFF57C00), Color(0xFFE65100)],
    'contra': [Color(0xFF6D4C41), Color(0xFF3E2723)],
  };

  static List<Color> forNature(String nature) =>
      _gradients[nature.toLowerCase()] ?? const [Color(0xFF5C6BC0), Color(0xFF3949AB)];
}

// ── Account Picker Sheet (Chart of Accounts dropdown) ──────────────
class _AccountPickerSheet extends StatefulWidget {
  const _AccountPickerSheet({required this.onSelect});
  final ValueChanged<CoaDropdownItem> onSelect;

  @override
  State<_AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends State<_AccountPickerSheet> {
  final LedgerController controller = Get.find<LedgerController>();
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _query = ''.obs;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CoaDropdownItem> _filtered() {
    final String q = _query.value.toLowerCase().trim();
    if (q.isEmpty) return controller.coaDropdown;
    return controller.coaDropdown.where((item) {
      final String label = item.label.isNotEmpty
          ? item.label
          : '${item.accountCode} ${item.accountName}';
      return label.toLowerCase().contains(q) ||
          item.accountCode.toLowerCase().contains(q) ||
          item.accountName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ─────────────────────────────────────────
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
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Account',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                          ),
                          Text(
                            'Choose an account to view its ledger',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Search field ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _query.value = v,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by name or code…',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Obx(() {
                  if (controller.isLoadingCoa.value && controller.coaDropdown.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  final List<CoaDropdownItem> list = _filtered();
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text('No accounts found',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final CoaDropdownItem item = list[i];
                      final List<Color> grad = _NatureStyle.forNature(item.nature);
                      final String initials = item.accountCode.isNotEmpty
                          ? item.accountCode.substring(0, item.accountCode.length >= 2 ? 2 : 1)
                          : (item.accountName.isNotEmpty ? item.accountName[0] : '?');
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => widget.onSelect(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: grad,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.accountName.isNotEmpty
                                            ? item.accountName
                                            : item.label,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            item.accountCode,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                          if (item.nature.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: grad.first.withOpacity(0.10),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                item.nature,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: grad.first,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
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
                if (entry.voucherStatus != null &&
                    entry.voucherStatus!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.voucherStatus!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
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
                if (entry.postedAt != null && entry.postedAt!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Posted ${entry.postedAt!.split('T').first}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
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
