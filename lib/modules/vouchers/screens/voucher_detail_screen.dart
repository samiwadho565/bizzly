import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/modules/vouchers/controllers/voucher_controller.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/modules/vouchers/screens/create_voucher_screen.dart';
import 'package:bizly/utils/app_colors.dart';

class VoucherDetailScreen extends StatelessWidget {
  const VoucherDetailScreen({super.key, required this.voucher});
  final VoucherModel voucher;

  @override
  Widget build(BuildContext context) {
    final VoucherController c = Get.find<VoucherController>();

    return Obx(() {
      final VoucherModel v = c.currentVoucher.value ?? voucher;
      final bool loading = c.isActionLoading.value;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar2(
          title: v.voucherNumber,
          backgroundColor: AppColors.primaryDense,
          textColor: Colors.white,
          actions: v.isEditable
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () async {
                      c.prepareEdit(v);
                      final bool? updated =
                          await Get.to(() => const CreateVoucherScreen());
                      if (updated == true) Get.back();
                    },
                  ),
                ]
              : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ──────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            v.voucherNumber,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDense,
                            ),
                          ),
                        ),
                        _StatusChip(status: v.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _row('Type', v.voucherType.capitalize!),
                    _row('Date',
                        DateFormat('MMM d, yyyy').format(v.voucherDate)),
                    _row('Narration', v.narration),
                    if (v.referenceNumber != null)
                      _row('Ref #', v.referenceNumber!),
                    if (v.business != null)
                      _row('Business', v.business!.businessName),
                    if (v.customer != null)
                      _row('Customer', v.customer!.customerName),
                    if (v.vendor != null)
                      _row('Vendor', v.vendor!.vendorName),
                    if (v.rejectionReason != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 14, color: Colors.red.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Rejected: ${v.rejectionReason}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Lines ────────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Journal Lines',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Header
                    Row(
                      children: [
                        const Expanded(
                            flex: 3,
                            child: Text('Account',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(
                            width: 60,
                            child: Text('Debit',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(width: 8),
                        const SizedBox(
                            width: 60,
                            child: Text('Credit',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const Divider(height: 12),
                    ...v.lines.map((l) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.account?.accountName ?? '—',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      l.account?.accountCode ?? '',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  l.isDebit ? _fmt(l.amount) : '—',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  !l.isDebit ? _fmt(l.amount) : '—',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 16),
                    // Totals
                    Row(
                      children: [
                        const Expanded(
                            flex: 3,
                            child: Text('Total',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13))),
                        SizedBox(
                          width: 60,
                          child: Text(
                            _fmt(v.totalDebit),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: Text(
                            _fmt(v.totalCredit),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Actions ──────────────────────────────────────
              if (loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (v.isDraft) ...[
                  _ActionButton(
                    label: 'Submit for Approval',
                    icon: Icons.send_outlined,
                    color: AppColors.primary,
                    onTap: () => c.submitVoucher(v),
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Delete Voucher',
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    outlined: true,
                    onTap: () => c.deleteVoucher(v),
                  ),
                ],
                if (v.isSubmitted) ...[
                  _ActionButton(
                    label: 'Approve',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onTap: () => c.approveVoucher(v),
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    outlined: true,
                    onTap: () => c.rejectVoucher(v),
                  ),
                ],
                if (v.isRejected)
                  _ActionButton(
                    label: 'Edit & Resubmit',
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    onTap: () async {
                      c.prepareEdit(v);
                      final bool? updated =
                          await Get.to(() => const CreateVoucherScreen());
                      if (updated == true) Get.back();
                    },
                  ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }
}

// ── Widgets ──────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  Color get _color {
    switch (status) {
      case 'draft': return Colors.grey;
      case 'submitted': return Colors.orange;
      case 'posted': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.capitalize!,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: color),
              label: Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: Colors.white),
              label: Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
    );
  }
}

Widget _card({required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );

Widget _row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

String _fmt(double v) => NumberFormat('#,##0.##').format(v);
