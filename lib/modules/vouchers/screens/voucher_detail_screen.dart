import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
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

    // Refresh with live data from GET /api/vouchers/{id} instead of
    // relying only on the (possibly stale) object passed from the list.
    if (c.currentVoucher.value?.id != voucher.id) {
      c.currentVoucher.value = voucher;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        c.fetchVoucherDetail(voucher.id);
      });
    }

    return Obx(() {
      final VoucherModel v = c.currentVoucher.value ?? voucher;
      final bool loading = c.isActionLoading.value;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            GradientScreenHeader(
              title: v.voucherNumber,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Summary Card ──────────────────────────
                    _VoucherHeroCard(v: v),
                    const SizedBox(height: 14),

                    // ── Voucher Info Card ───────────────────────────
                    _SectionCard(
                      title: 'Voucher Info',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (v.accountingPeriod != null)
                            _infoRow('Accounting Period', v.accountingPeriod!.name),
                          if (v.creator != null)
                            _infoRow('Created By', v.creator!.name),
                          if (v.business != null && v.business!.businessEmail != null)
                            _infoRow('Business Email', v.business!.businessEmail!),
                          if (v.business != null && v.business!.phoneNumber != null)
                            _infoRow('Business Phone', v.business!.phoneNumber!),
                          if (v.ledgerEntry != null)
                            _infoRow('Ledger Entry', v.ledgerEntry!.entryNumber),
                          _infoRow('Created', DateFormat('MMM d, y • h:mm a').format(v.createdAt)),
                          if (v.updatedAt != null)
                            _infoRow('Last Updated', DateFormat('MMM d, y • h:mm a').format(v.updatedAt!)),
                          if (v.postedAt != null)
                            _infoRow('Posted At', DateFormat('MMM d, y • h:mm a').format(v.postedAt!)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Customer / Vendor Card ──────────────────────
                    if (v.customer != null || v.vendor != null) ...[
                      _SectionCard(
                        title: v.customer != null ? 'Customer' : 'Vendor',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (v.customer != null) ...[
                              _infoRow('Name', v.customer!.customerName),
                              if (v.customer!.companyName != null)
                                _infoRow('Company', v.customer!.companyName!),
                              if (v.customer!.email != null)
                                _infoRow('Email', v.customer!.email!),
                              if (v.customer!.phoneNumber != null)
                                _infoRow('Phone', v.customer!.phoneNumber!),
                            ],
                            if (v.vendor != null) ...[
                              _infoRow('Name', v.vendor!.vendorName),
                              if (v.vendor!.companyName != null)
                                _infoRow('Company', v.vendor!.companyName!),
                              if (v.vendor!.email != null)
                                _infoRow('Email', v.vendor!.email!),
                              if (v.vendor!.phoneNumber != null)
                                _infoRow('Phone', v.vendor!.phoneNumber!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Journal Lines ──────────────────────────────
                    _SectionCard(
                      title: 'Journal Lines',
                      child: Column(
                        children: [
                          // Header row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text('Account',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w700)),
                                ),
                                SizedBox(
                                  width: 64,
                                  child: Text('Debit',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w700)),
                                ),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 64,
                                  child: Text('Credit',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFC62828),
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...v.lines.map((l) => _JournalLineRow(line: l)),
                          const Divider(height: 20, thickness: 1, color: Color(0xFFF0F0F0)),
                          // Totals row
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text('Total',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Color(0xFF1A1A2E))),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  _fmt(v.totalDebit),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFF2E7D32)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  _fmt(v.totalCredit),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFFC62828)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Activity Timeline (approval_logs) ───────────
                    if (v.approvalLogs.isNotEmpty)
                      _SectionCard(
                        title: 'Activity Timeline',
                        child: Column(
                          children: [
                            for (int i = 0; i < v.approvalLogs.length; i++)
                              _TimelineRow(
                                log: v.approvalLogs[i],
                                isLast: i == v.approvalLogs.length - 1,
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 18),

                    // ── Actions ────────────────────────────────────
                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      )
                    else ...[
                      if (v.isDraft) ...[
                        _GradientActionButton(
                          label: 'Submit for Approval',
                          icon: Icons.send_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shadowColor: const Color(0xFF0D47A1),
                          onTap: () => c.submitVoucher(v),
                        ),
                        const SizedBox(height: 10),
                        _OutlinedActionButton(
                          label: 'Delete Voucher',
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFC62828),
                          onTap: () => c.deleteVoucher(v),
                        ),
                      ],
                      if (v.isSubmitted) ...[
                        _GradientActionButton(
                          label: 'Approve',
                          icon: Icons.check_circle_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shadowColor: const Color(0xFF2E7D32),
                          onTap: () => c.approveVoucher(v),
                        ),
                        const SizedBox(height: 10),
                        _OutlinedActionButton(
                          label: 'Reject',
                          icon: Icons.cancel_outlined,
                          color: const Color(0xFFC62828),
                          onTap: () => c.rejectVoucher(v),
                        ),
                      ],
                      if (v.isRejected)
                        _GradientActionButton(
                          label: 'Edit & Resubmit',
                          icon: Icons.edit_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shadowColor: const Color(0xFF0D47A1),
                          onTap: () async {
                            c.prepareEdit(v);
                            final bool? updated =
                                await Get.to(() => const CreateVoucherScreen());
                            if (updated == true) Get.back();
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Voucher Hero Card ────────────────────────────────────────────
class _VoucherHeroCard extends StatelessWidget {
  const _VoucherHeroCard({required this.v});
  final VoucherModel v;

  static Color _gradientStart(String type) {
    switch (type.toLowerCase()) {
      case 'receipt':    return const Color(0xFF1B5E20);
      case 'payment':    return const Color(0xFFB71C1C);
      case 'journal':    return const Color(0xFF0D1B4B);
      case 'contra':     return const Color(0xFF4A148C);
      case 'adjustment': return const Color(0xFFE65100);
      default:           return const Color(0xFF0D1B4B);
    }
  }

  static Color _gradientEnd(String type) {
    switch (type.toLowerCase()) {
      case 'receipt':    return const Color(0xFF43A047);
      case 'payment':    return const Color(0xFFE53935);
      case 'journal':    return const Color(0xFF1565C0);
      case 'contra':     return const Color(0xFF8E24AA);
      case 'adjustment': return const Color(0xFFF57C00);
      default:           return const Color(0xFF1565C0);
    }
  }

  static IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'receipt':    return Icons.arrow_downward_rounded;
      case 'payment':    return Icons.arrow_upward_rounded;
      case 'journal':    return Icons.receipt_long_rounded;
      case 'contra':     return Icons.swap_horiz_rounded;
      case 'adjustment': return Icons.tune_rounded;
      default:           return Icons.description_outlined;
    }
  }

  static Color _statusColor(String s) {
    switch (s) {
      case 'draft':     return Colors.grey;
      case 'submitted': return Colors.orange;
      case 'posted':    return const Color(0xFF43A047);
      case 'rejected':  return const Color(0xFFE53935);
      default:          return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color c1 = _gradientStart(v.voucherType);
    final Color c2 = _gradientEnd(v.voucherType);
    final Color statusColor = _statusColor(v.status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c2.withOpacity(0.38),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -25,
            right: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge + Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_typeIcon(v.voucherType),
                              size: 13, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            v.voucherType.capitalize!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withOpacity(0.40)),
                      ),
                      child: Text(
                        v.status.capitalize!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: v.status == 'draft' || v.status == 'submitted'
                              ? Colors.white
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Narration
                Text(
                  v.narration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (v.referenceNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${v.referenceNumber}',
                    style:
                        TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12),
                  ),
                ],
                if (v.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.30)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Rejected: ${v.rejectionReason}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Bottom row: date + totals
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colors.white.withOpacity(0.70)),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('MMM d, yyyy').format(v.voucherDate),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.70), fontSize: 12),
                    ),
                    // Extra CRM info
                    if (v.business != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.business_outlined,
                          size: 12, color: Colors.white.withOpacity(0.70)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          v.business!.businessName,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.70),
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Dr/Cr mini pills
                    _AmountPill(label: 'Dr', value: _fmt(v.totalDebit)),
                    const SizedBox(width: 6),
                    _AmountPill(label: 'Cr', value: _fmt(v.totalCredit)),
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

class _AmountPill extends StatelessWidget {
  const _AmountPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Section Card ─────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Journal Line Row ─────────────────────────────────────────────
class _JournalLineRow extends StatelessWidget {
  const _JournalLineRow({required this.line});
  final VoucherLine line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Account icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: line.isDebit
                  ? const Color(0xFF2E7D32).withOpacity(0.10)
                  : const Color(0xFFC62828).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              line.isDebit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 14,
              color: line.isDebit
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.account?.accountName ?? '—',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if ((line.account?.accountCode ?? '').isNotEmpty)
                  Text(
                    line.account!.accountCode,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              line.isDebit ? _fmt(line.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: line.isDebit
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              !line.isDebit ? _fmt(line.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: !line.isDebit
                    ? const Color(0xFFC62828)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient Action Button ───────────────────────────────────────
class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.32),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Outlined Action Button ───────────────────────────────────────
class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.40), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row (label/value pair) ──────────────────────────────────
Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
          ),
        ),
      ],
    ),
  );
}

// ── Timeline Row (one approval_logs entry) ───────────────────────
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.log, required this.isLast});
  final VoucherApprovalLog log;
  final bool isLast;

  static Color _actionColor(String action) {
    switch (action) {
      case 'submitted': return const Color(0xFF1565C0);
      case 'approved':  return const Color(0xFF2E7D32);
      case 'posted':    return const Color(0xFF43A047);
      case 'rejected':  return const Color(0xFFC62828);
      default:          return Colors.grey;
    }
  }

  static IconData _actionIcon(String action) {
    switch (action) {
      case 'submitted': return Icons.send_rounded;
      case 'approved':  return Icons.check_circle_rounded;
      case 'posted':    return Icons.receipt_long_rounded;
      case 'rejected':  return Icons.cancel_rounded;
      default:          return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _actionColor(log.action);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_actionIcon(log.action), size: 14, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade200),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.action.capitalize ?? log.action,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                    ),
                    if (log.user != null)
                      Text(
                        'by ${log.user!.name}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    if (log.comments != null && log.comments!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          log.comments!,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                        ),
                      ),
                    if (log.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          DateFormat('MMM d, y • h:mm a').format(log.createdAt!),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(double v) => NumberFormat('#,##0.##').format(v);
