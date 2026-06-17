import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/modules/ledger/controllers/ledger_controller.dart';
import 'package:bizly/modules/ledger/models/ledger_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/gradient_screen_header.dart';

class LedgerScreen extends GetView<LedgerController> {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientScreenHeader(title: 'General Ledger'),
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
              return _LedgerEntryCard(entry: e);
            },
          ),
        );
      })),
        ],
      ),
    );
  }
}

class _LedgerEntryCard extends StatelessWidget {
  const _LedgerEntryCard({required this.entry});
  final LedgerEntry entry;

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
      default:
        return AppColors.primary;
    }
  }

  String get _formattedDate {
    try {
      final DateTime d = DateTime.parse(entry.date);
      return DateFormat('dd MMM yyyy').format(d);
    } catch (_) {
      return entry.date;
    }
  }

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    entry.voucherType.toUpperCase(),
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
                    entry.voucherNumber,
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
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Account + narration
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_outlined,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.accountName.isNotEmpty
                                ? entry.accountName
                                : 'Account ${entry.accountCode}',
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
                const SizedBox(height: 12),

                // Dr / Cr / Balance row
                Row(
                  children: [
                    Expanded(
                      child: _AmountTile(
                        label: 'Debit',
                        value: entry.debit > 0 ? _fmt(entry.debit) : '—',
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFF0F0F0)),
                    Expanded(
                      child: _AmountTile(
                        label: 'Credit',
                        value: entry.credit > 0 ? _fmt(entry.credit) : '—',
                        color: const Color(0xFFC62828),
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFF0F0F0)),
                    Expanded(
                      child: _AmountTile(
                        label: 'Balance',
                        value: '${_fmt(entry.runningBalance)} ${entry.balanceType}',
                        color: AppColors.primary,
                      ),
                    ),
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
