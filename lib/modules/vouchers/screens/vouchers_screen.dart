import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/vouchers/controllers/voucher_controller.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/modules/vouchers/screens/create_voucher_screen.dart';
import 'package:bizly/modules/vouchers/screens/voucher_detail_screen.dart';
import 'package:bizly/utils/app_colors.dart';

class VouchersScreen extends GetView<VoucherController> {
  const VouchersScreen({super.key});

  static const List<_VoucherTypeItem> _types = [
    _VoucherTypeItem(key: 'all',        label: 'All',        icon: Icons.grid_view_rounded,       color: Color(0xFF5C6BC0)),
    _VoucherTypeItem(key: 'receipt',    label: 'Receipt',    icon: Icons.arrow_downward_rounded,  color: Color(0xFF388E3C)),
    _VoucherTypeItem(key: 'payment',    label: 'Payment',    icon: Icons.arrow_upward_rounded,    color: Color(0xFFE53935)),
    _VoucherTypeItem(key: 'journal',    label: 'Journal',    icon: Icons.receipt_long_rounded,    color: Color(0xFF1976D2)),
    _VoucherTypeItem(key: 'contra',     label: 'Contra',     icon: Icons.swap_horiz_rounded,      color: Color(0xFF7B1FA2)),
    _VoucherTypeItem(key: 'adjustment', label: 'Adjustment', icon: Icons.tune_rounded,            color: Color(0xFFF57C00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryDense,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // App bar with filter icon
                Obx(() => CustomAppBar2(
                      title: 'Vouchers',
                      backgroundColor: AppColors.primaryDense,
                      textColor: Colors.white,
                      actions: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.filter_list_rounded,
                                  color: Colors.white),
                              onPressed: () =>
                                  _showFilterSheet(context),
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
              ],
            ),
          ),

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
              colors: [Color(0xFFFFF3E0), Color(0xFFFFFDE7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCC80), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFB8C00).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pending_actions_rounded,
                    size: 17, color: Color(0xFFFB8C00)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count voucher${count > 1 ? 's' : ''} awaiting your approval',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    const Text(
                      'Tap to review',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFB8C00)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFFB8C00), size: 20),
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
      return SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: VouchersScreen._types.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final _VoucherTypeItem item = VouchersScreen._types[i];
            final bool isSelected = selected == item.key;
            return GestureDetector(
              onTap: () => controller.applyType(item.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? item.color : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? item.color : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: item.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 14, color: isSelected ? Colors.white : item.color),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
  const _VoucherTypeItem({required this.key, required this.label, required this.icon, required this.color});
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

  static const List<Map<String, String>> _statuses = [
    {'key': 'all', 'label': 'All'},
    {'key': 'draft', 'label': 'Draft'},
    {'key': 'submitted', 'label': 'Submitted'},
    {'key': 'posted', 'label': 'Posted'},
    {'key': 'rejected', 'label': 'Rejected'},
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.controller.filterStatus.value;
    _from = widget.controller.fromDate.value;
    _to = widget.controller.toDate.value;
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
    widget.controller.filterStatus.value = _status;
    widget.controller.applyDateRange(_from, _to);
    Navigator.pop(context);
  }

  void _clear() {
    setState(() {
      _status = 'all';
      _from = null;
      _to = null;
    });
    widget.controller.clearServerFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String fmt = 'MMM d, yyyy';
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Filter Vouchers',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (widget.controller.hasActiveServerFilters)
                TextButton(
                  onPressed: _clear,
                  child: Text('Clear all',
                      style: TextStyle(color: Colors.red.shade400)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Status ─────────────────────────────────────────
          const Text('Status',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses.map((s) {
              final bool sel = _status == s['key'];
              return GestureDetector(
                onTap: () => setState(() => _status = s['key']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primaryDense
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Date Range ─────────────────────────────────────
          const Text('Date Range',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'From',
                  value: _from != null
                      ? DateFormat(fmt).format(_from!)
                      : null,
                  onTap: () => _pickDate(isFrom: true),
                  onClear: _from != null
                      ? () => setState(() => _from = null)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateTile(
                  label: 'To',
                  value: _to != null
                      ? DateFormat(fmt).format(_to!)
                      : null,
                  onTap: () => _pickDate(isFrom: false),
                  onClear: _to != null
                      ? () => setState(() => _to = null)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Apply ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDense,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Filters',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDense)),
                  const SizedBox(height: 2),
                  Text(
                    value ?? 'Select date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: value != null ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 16, color: AppColors.primaryDense),
              )
            else
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.primaryDense),
          ],
        ),
      ),
    );
  }
}
