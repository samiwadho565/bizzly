import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/modules/ledger/controllers/ledger_controller.dart';
import 'package:bizly/modules/ledger/models/ledger_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/gradient_screen_header.dart';

/// Detail screen for GET /api/ledger/account/{account_id}
/// Reached from the Chart of Accounts detail screen via "View Ledger".
class AccountLedgerScreen extends StatelessWidget {
  const AccountLedgerScreen({
    super.key,
    required this.accountId,
    this.accountCode,
    this.accountName,
  });

  final int accountId;
  final String? accountCode;
  final String? accountName;

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    // This screen can be opened without ever visiting /ledger_screen first,
    // so LedgerController may not be registered yet — ensure it is.
    final LedgerController controller = Get.isRegistered<LedgerController>()
        ? Get.find<LedgerController>()
        : Get.put(LedgerController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAccountLedger(accountId);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientScreenHeader(
            title: accountName?.isNotEmpty == true ? accountName! : 'Account Ledger',
          ),
          Expanded(
            child: Obx(() {
              if (controller.isAccountLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final AccountLedger? ledger = controller.accountLedger.value;
              if (ledger == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Could not load ledger',
                          style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => controller.fetchAccountLedger(accountId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.fetchAccountLedger(accountId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Account + totals card ──────────────────
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
                            ledger.accountName.isNotEmpty
                                ? ledger.accountName
                                : (accountName ?? ''),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ledger.accountCode.isNotEmpty
                                ? ledger.accountCode
                                : (accountCode ?? ''),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _TotalTile(
                                  label: 'Total Debit',
                                  value: _fmt(ledger.totals.totalDebit),
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              Expanded(
                                child: _TotalTile(
                                  label: 'Total Credit',
                                  value: _fmt(ledger.totals.totalCredit),
                                  color: const Color(0xFFC62828),
                                ),
                              ),
                              Expanded(
                                child: _TotalTile(
                                  label: 'Closing Balance',
                                  value:
                                      '${_fmt(ledger.totals.closingBalance)} ${ledger.closingBalanceType}',
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (ledger.lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text('No transactions yet',
                                  style: TextStyle(color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...ledger.lines.map((line) => _LedgerLineTile(line: line)),
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

class _TotalTile extends StatelessWidget {
  const _TotalTile({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
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

class _LedgerLineTile extends StatelessWidget {
  const _LedgerLineTile({required this.line});
  final LedgerLine line;

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final bool isDebit = line.debit > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.lineType.isNotEmpty ? line.lineType.toUpperCase() : '—',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDebit ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  ),
                ),
                if (line.createdAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    line.createdAt!.split('T').first,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          Text(
            isDebit ? _fmt(line.debit) : '—',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 16),
          Text(
            !isDebit ? _fmt(line.credit) : '—',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFC62828)),
          ),
          if (line.runningBalance != null) ...[
            const SizedBox(width: 16),
            Text(
              _fmt(line.runningBalance!),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
