import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/modules/ledger/controllers/ledger_controller.dart';
import 'package:bizly/modules/ledger/models/ledger_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/gradient_screen_header.dart';

/// Detail screen for GET /api/ledger/{ledger_entry_id}
class LedgerEntryDetailScreen extends GetView<LedgerController> {
  const LedgerEntryDetailScreen({super.key, required this.entryId});
  final int entryId;

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  String _formattedDate(String raw) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  double _balanceDiff(LedgerEntry e) => (e.totalDebit - e.totalCredit).abs();

  bool _isBalanced(LedgerEntry e) => _balanceDiff(e) < 0.005;

  @override
  Widget build(BuildContext context) {
    // Kick off the fetch once when the screen builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEntryDetail(entryId);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientScreenHeader(title: 'Ledger Entry'),
          Expanded(
            child: Obx(() {
              if (controller.isEntryLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.entryError.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(controller.entryError.value,
                          style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => controller.fetchEntryDetail(entryId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final LedgerEntry? e = controller.selectedEntry.value;
              if (e == null) {
                return const SizedBox.shrink();
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.entryNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formattedDate(e.entryDate),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        if (e.narration.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            e.narration,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                          ),
                        ],
                        if (e.voucherNumber.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _infoChip(e.voucherType.toUpperCase()),
                              const SizedBox(width: 6),
                              Text(
                                e.voucherNumber,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              if (e.voucherStatus != null) ...[
                                const SizedBox(width: 6),
                                _infoChip(e.voucherStatus!.toUpperCase()),
                              ],
                            ],
                          ),
                        ],
                        if (e.postedAt != null || e.createdAt != null) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          if (e.createdAt != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Created', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                  Text(_formattedDate(e.createdAt!),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          if (e.postedAt != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Posted', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                Text(_formattedDate(e.postedAt!),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lines',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        ...e.lines.map((line) {
                          final bool isDebit = line.debit > 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: (isDebit ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    isDebit ? 'DR' : 'CR',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isDebit ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        line.accountName,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        line.normalBalance != null
                                            ? '${line.accountCode} · Normal: ${line.normalBalance}'
                                            : line.accountCode,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  isDebit ? _fmt(line.debit) : '—',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  !isDebit ? _fmt(line.credit) : '—',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC62828)),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(
                              '${_fmt(e.totalDebit)}   /   ${_fmt(e.totalCredit)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(
                              _isBalanced(e) ? 'Balanced' : 'Out of balance by ${_fmt(_balanceDiff(e))}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isBalanced(e)
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
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
  }
}
