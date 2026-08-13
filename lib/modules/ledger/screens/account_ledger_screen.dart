import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/modules/ledger/controllers/ledger_controller.dart';
import 'package:bizly/modules/ledger/models/ledger_model.dart';
import 'package:bizly/modules/ledger/screens/ledger_entry_detail_screen.dart';
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

              final bool isCreditNormal =
                  (ledger.totals.balanceSide ?? ledger.totals.normalBalance) == 'credit';

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.fetchAccountLedger(accountId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Account hero card ──────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCreditNormal
                              ? const [Color(0xFF6A1B9A), Color(0xFF0D1B4B)]
                              : const [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0D47A1).withOpacity(0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ledger.accountName.isNotEmpty
                                          ? ledger.accountName
                                          : (accountName ?? ''),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          ledger.accountCode.isNotEmpty
                                              ? ledger.accountCode
                                              : (accountCode ?? ''),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.75),
                                          ),
                                        ),
                                        if (ledger.nature != null && ledger.nature!.isNotEmpty) ...[
                                          Text('  ·  ',
                                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                                          Text(
                                            ledger.nature!,
                                            style: TextStyle(
                                                fontSize: 12, color: Colors.white.withOpacity(0.75)),
                                          ),
                                        ],
                                        if (ledger.normalBalance != null &&
                                            ledger.normalBalance!.isNotEmpty) ...[
                                          Text('  ·  Normal: ',
                                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                                          Text(
                                            ledger.normalBalance!,
                                            style: TextStyle(
                                                fontSize: 12, color: Colors.white.withOpacity(0.75)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _TotalTile(
                                  label: 'Total Debit',
                                  value: _fmt(ledger.totals.totalDebit),
                                ),
                              ),
                              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.15)),
                              Expanded(
                                child: _TotalTile(
                                  label: 'Total Credit',
                                  value: _fmt(ledger.totals.totalCredit),
                                ),
                              ),
                              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.15)),
                              Expanded(
                                child: _TotalTile(
                                  label: 'Closing Balance',
                                  value:
                                      '${_fmt(ledger.totals.closingBalance)} ${ledger.closingBalanceType}',
                                  emphasize: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

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
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          'TRANSACTIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      ...ledger.lines.map((line) => _LedgerLineTile(line: line)),
                    ],
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
  const _TotalTile({required this.label, required this.value, this.emphasize = false});
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 13 : 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.65)),
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
    final Color accent = isDebit ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final LedgerLineEntryRef? entry = line.entry;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: entry == null
              ? null
              : () => Get.to(() => LedgerEntryDetailScreen(entryId: entry.id)),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDebit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          size: 15,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  line.lineType.isNotEmpty ? line.lineType.toUpperCase() : '—',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (entry != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      entry.entryNumber,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isDebit ? _fmt(line.debit) : _fmt(line.credit),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: accent),
                          ),
                          if (line.runningBalance != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Bal: ${_fmt(line.runningBalance!)}',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ],
                      ),
                      if (entry != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
