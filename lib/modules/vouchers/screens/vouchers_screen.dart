import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/vouchers/controllers/voucher_controller.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/modules/vouchers/screens/create_voucher_screen.dart';
import 'package:bizly/modules/vouchers/screens/voucher_detail_screen.dart';
import 'package:bizly/utils/app_colors.dart';

class VouchersScreen extends GetView<VoucherController> {
  const VouchersScreen({super.key});

  static const List<_VoucherTypeItem> _types = [
    _VoucherTypeItem(key: 'all',        label: 'All',        icon: Icons.grid_view_rounded,       color: Color(0xFF5C6BC0), gradientEnd: Color(0xFF3949AB)),
    _VoucherTypeItem(key: 'receipt',    label: 'Receipt',    icon: Icons.arrow_downward_rounded,  color: Color(0xFF43A047), gradientEnd: Color(0xFF1B5E20)),
    _VoucherTypeItem(key: 'payment',    label: 'Payment',    icon: Icons.arrow_upward_rounded,    color: Color(0xFFE53935), gradientEnd: Color(0xFFB71C1C)),
    _VoucherTypeItem(key: 'journal',    label: 'Journal',    icon: Icons.receipt_long_rounded,    color: Color(0xFF1976D2), gradientEnd: Color(0xFF0D47A1)),
    _VoucherTypeItem(key: 'contra',     label: 'Contra',     icon: Icons.swap_horiz_rounded,      color: Color(0xFF8E24AA), gradientEnd: Color(0xFF4A148C)),
    _VoucherTypeItem(key: 'adjustment', label: 'Adjustment', icon: Icons.tune_rounded,            color: Color(0xFFF57C00), gradientEnd: Color(0xFFE65100)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Obx(() => GradientScreenHeader(
                title: 'Vouchers',
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list_rounded,
                            color: Colors.white),
                        onPressed: () => _showFilterSheet(context),
                      ),
                      if (controller.hasActiveFilters)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              )),

          // ── Type Chips ──────────────────────────────────────
          const _VoucherTypeChips(),

          // ── Pending Approvals Banner ─────────────────────────
          const _PendingApprovalsBanner(),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: FinancePulseLoader());
              }
              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.error.value,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: controller.fetchVouchers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final List<VoucherModel> list = controller.filteredVouchers;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No vouchers found',
                          style: TextStyle(color: Colors.grey.shade500)),
                      if (controller.hasActiveTypeFilter && !controller.hasActiveServerFilters) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: controller.clearTypeFilter,
                          child: const Text('Clear filter'),
                        ),
                      ] else if (controller.hasActiveServerFilters) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: controller.clearServerFilters,
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchVouchers,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _VoucherTile(voucher: list[i]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          controller.prepareCreate();
          final bool? created =
              await Get.to(() => const CreateVoucherScreen());
          if (created == true) controller.fetchVouchers();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(controller: controller),
    );
  }
}

// ── Voucher Tile ─────────────────────────────────────────────────
class _VoucherTile extends StatelessWidget {
  const _VoucherTile({required this.voucher});
  final VoucherModel voucher;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<VoucherController>().currentVoucher.value = voucher;
        Get.to(() => VoucherDetailScreen(voucher: voucher));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Type icon circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _typeColor(voucher.voucherType).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _typeIcon(voucher.voucherType),
                size: 20,
                color: _typeColor(voucher.voucherType),
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
                        voucher.voucherNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: voucher.status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    voucher.narration,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('MMM d, yyyy').format(voucher.voucherDate),
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Dr ${_fmt(voucher.totalDebit)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cr ${_fmt(voucher.totalCredit)}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.capitalize!,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ── Pending Approvals Banner ─────────────────────────────────────
class _PendingApprovalsBanner extends GetView<VoucherController> {
  const _PendingApprovalsBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int count = controller.pendingApprovals.length;
      if (count == 0) return const SizedBox.shrink();
      return GestureDetector(
        onTap: () => _showPendingSheet(context),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFB8C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE65100).withOpacity(0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -18,
                right: -18,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pending_actions_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count voucher${count > 1 ? 's' : ''} awaiting approval',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Tap to review',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showPendingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PendingApprovalsSheet(controller: controller),
    );
  }
}

class _PendingApprovalsSheet extends StatelessWidget {
  const _PendingApprovalsSheet({required this.controller});
  final VoucherController controller;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pending_actions_rounded,
                          color: Color(0xFFFB8C00), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Pending Approvals',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFB8C00),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${controller.pendingCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
              ],
            ),
          ),
          // List
          Expanded(
            child: Obx(() {
              final List<VoucherModel> list = controller.pendingApprovals;
              if (controller.isLoadingPending.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) {
                return const Center(child: Text('No pending approvals'));
              }
              return ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final VoucherModel v = list[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      controller.currentVoucher.value = v;
                      Get.to(() => VoucherDetailScreen(voucher: v));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _typeColor(v.voucherType).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_typeIcon(v.voucherType),
                                size: 18, color: _typeColor(v.voucherType)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.voucherNumber,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(v.narration,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Dr ${_fmt(v.totalDebit)}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.chevron_right,
                                      size: 16, color: Color(0xFFFB8C00)),
                                  const Text('Review',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFFB8C00),
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ],
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
  }
}

// ── Helpers ──────────────────────────────────────────────────────
Color _typeColor(String type) {
  switch (type) {
    case 'receipt': return Colors.green;
    case 'payment': return Colors.red;
    case 'journal': return Colors.blue;
    case 'contra': return Colors.purple;
    case 'adjustment': return Colors.orange;
    default: return Colors.grey;
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'receipt': return Icons.arrow_downward_rounded;
    case 'payment': return Icons.arrow_upward_rounded;
    case 'journal': return Icons.receipt_long_outlined;
    case 'contra': return Icons.swap_horiz_rounded;
    case 'adjustment': return Icons.tune_rounded;
    default: return Icons.description_outlined;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'draft': return Colors.grey;
    case 'submitted': return Colors.orange;
    case 'posted': return Colors.green;
    case 'rejected': return Colors.red;
    default: return Colors.grey;
  }
}

String _fmt(double v) => NumberFormat('#,##0.##').format(v);

// ── Voucher Type Chips ───────────────────────────────────────────
class _VoucherTypeChips extends GetView<VoucherController> {
  const _VoucherTypeChips();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String selected = controller.filterType.value;
      return Container(
        color: Colors.white,
        child: SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            itemCount: VouchersScreen._types.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final _VoucherTypeItem item = VouchersScreen._types[i];
              final bool isSelected = selected == item.key;
              return GestureDetector(
                onTap: () => controller.applyType(item.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [item.color, item.gradientEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : item.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [BoxShadow(color: item.gradientEnd.withOpacity(0.38), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.20)
                              : item.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 12,
                          color: isSelected ? Colors.white : item.color,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : item.color,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _VoucherTypeItem {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  const _VoucherTypeItem({required this.key, required this.label, required this.icon, required this.color, required this.gradientEnd});
}

// ── Filter Bottom Sheet ───────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.controller});
  final VoucherController controller;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _status;
  late DateTime? _from;
  late DateTime? _to;
  late CrmDropdownItem? _business;

  static const List<_StatusItem> _statuses = [
    _StatusItem(key: 'all',       label: 'All',       icon: Icons.grid_view_rounded,        color: Color(0xFF5C6BC0), gradientEnd: Color(0xFF3949AB)),
    _StatusItem(key: 'draft',     label: 'Draft',     icon: Icons.edit_note_rounded,        color: Color(0xFF78909C), gradientEnd: Color(0xFF455A64)),
    _StatusItem(key: 'submitted', label: 'Submitted', icon: Icons.send_rounded,             color: Color(0xFFF57C00), gradientEnd: Color(0xFFE65100)),
    _StatusItem(key: 'posted',    label: 'Posted',    icon: Icons.check_circle_rounded,     color: Color(0xFF43A047), gradientEnd: Color(0xFF1B5E20)),
    _StatusItem(key: 'rejected',  label: 'Rejected',  icon: Icons.cancel_rounded,           color: Color(0xFFE53935), gradientEnd: Color(0xFFB71C1C)),
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.controller.filterStatus.value;
    _from = widget.controller.fromDate.value;
    _to = widget.controller.toDate.value;
    _business = widget.controller.filterBusiness.value;
    widget.controller.fetchFilterBusinesses();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final DateTime initial = (isFrom ? _from : _to) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryDense),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to != null && _to!.isBefore(picked)) _to = null;
      } else {
        _to = picked;
        if (_from != null && _from!.isAfter(picked)) _from = null;
      }
    });
  }

  void _apply() {
    widget.controller.applyFilters(
      status: _status,
      business: _business,
      from: _from,
      to: _to,
    );
    Navigator.pop(context);
  }

  void _clear() {
    setState(() {
      _status = 'all';
      _from = null;
      _to = null;
      _business = null;
    });
    widget.controller.clearServerFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String fmt = 'MMM d, yyyy';
    final bool hasFilters = widget.controller.hasActiveServerFilters ||
        _status != 'all' || _from != null || _to != null || _business != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ─────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
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
                  child: const Icon(Icons.filter_list_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Vouchers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        'Narrow results by status or date',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (hasFilters)
                  GestureDetector(
                    onTap: _clear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE53935).withOpacity(0.25)),
                      ),
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.grey.shade100,
          ),
          const SizedBox(height: 20),

          // ── Status section label ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Status chips ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((s) {
                final bool sel = _status == s.key;
                return GestureDetector(
                  onTap: () => setState(() => _status = s.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: sel
                          ? LinearGradient(
                              colors: [s.color, s.gradientEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: sel ? null : s.color.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: s.gradientEnd.withOpacity(0.32),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: sel
                                ? Colors.white.withOpacity(0.20)
                                : s.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(s.icon,
                              size: 11,
                              color: sel ? Colors.white : s.color),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : s.color,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),

          // ── Business section label ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Business',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Business chips ─────────────────────────────────
          Obx(() {
            final List<CrmDropdownItem> options = widget.controller.filterBusinessList;
            if (widget.controller.isLoadingFilterBusinesses.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDense),
                ),
              );
            }
            if (options.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('No businesses found', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _BusinessChip(
                    label: 'All',
                    selected: _business == null,
                    onTap: () => setState(() => _business = null),
                  ),
                  ...options.map((b) => _BusinessChip(
                        label: b.name,
                        selected: _business?.id == b.id,
                        onTap: () => setState(() => _business = b),
                      )),
                ],
              ),
            );
          }),
          const SizedBox(height: 22),

          // ── Date Range section label ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Date tiles ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'From',
                    value: _from != null ? DateFormat(fmt).format(_from!) : null,
                    onTap: () => _pickDate(isFrom: true),
                    onClear:
                        _from != null ? () => setState(() => _from = null) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTile(
                    label: 'To',
                    value: _to != null ? DateFormat(fmt).format(_to!) : null,
                    onTap: () => _pickDate(isFrom: false),
                    onClear:
                        _to != null ? () => setState(() => _to = null) : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Apply button ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: _apply,
              child: Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  const _StatusItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.gradientEnd,
  });
}

class _BusinessChip extends StatelessWidget {
  const _BusinessChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppColors.primaryDense.withOpacity(0.07),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.primaryDense,
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasValue
              ? const Color(0xFF0D47A1).withOpacity(0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF1565C0).withOpacity(0.30)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: hasValue
                    ? const LinearGradient(
                        colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: hasValue ? null : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: hasValue ? Colors.white : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: hasValue
                          ? const Color(0xFF0D47A1)
                          : Colors.grey.shade400,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? 'Select date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          hasValue ? FontWeight.w600 : FontWeight.w400,
                      color:
                          hasValue ? const Color(0xFF1A1A2E) : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 12, color: Color(0xFFE53935)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
