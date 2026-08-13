import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/accounting_periods/controllers/accounting_period_controller.dart';
import 'package:bizly/modules/accounting_periods/models/accounting_period_model.dart';
import 'package:bizly/utils/app_colors.dart';

class AccountingPeriodsScreen extends GetView<AccountingPeriodController> {
  const AccountingPeriodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientScreenHeader(title: 'Accounting Periods'),
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
                      Text(controller.error.value, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: controller.fetchAll,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  children: [
                    // ── Current Period Card ────────────────────
                    if (controller.currentPeriod.value != null) ...[
                      _CurrentPeriodCard(period: controller.currentPeriod.value!),
                      const SizedBox(height: 24),
                    ],

                    // ── All Periods ────────────────────────────
                    if (controller.periods.isNotEmpty) ...[
                      Text(
                        'All Periods',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...controller.periods.map((p) => _PeriodTile(period: p)),
                    ],

                    if (controller.periods.isEmpty && controller.currentPeriod.value == null)
                      const Center(child: Text('No accounting periods found')),
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

// ── Current Period Highlight Card ─────────────────────────────────
class _CurrentPeriodCard extends StatelessWidget {
  const _CurrentPeriodCard({required this.period});
  final AccountingPeriodModel period;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B4B), Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
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
              width: 90,
              height: 90,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF69F0AE),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active Period',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  period.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.date_range_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '${_fmt(period.startDate)}  →  ${_fmt(period.endDate)}',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      period.isGlobal ? Icons.public : Icons.apartment_rounded,
                      size: 13,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      period.isGlobal
                          ? 'Global period'
                          : 'Business #${period.businessId}',
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
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

// ── Period List Tile ──────────────────────────────────────────────
class _PeriodTile extends StatelessWidget {
  const _PeriodTile({required this.period});
  final AccountingPeriodModel period;

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PeriodDetailSheet(period: period),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmt(period.startDate)} – ${_fmt(period.endDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    period.isGlobal ? 'Global period' : 'Business #${period.businessId}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: period.isOpen
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period.isOpen ? 'Open' : 'Closed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: period.isOpen
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ── Period Detail Bottom Sheet ──────────────────────────────────────
class _PeriodDetailSheet extends StatelessWidget {
  const _PeriodDetailSheet({required this.period});
  final AccountingPeriodModel period;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              period.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _row('Status', period.isOpen ? 'Open' : 'Closed'),
            _row('Start Date', _fmt(period.startDate)),
            _row('End Date', _fmt(period.endDate)),
            _row('Scope', period.isGlobal ? 'Global (all businesses)' : 'Business #${period.businessId}'),
            if (period.closedAt != null)
              _row('Closed At', _fmt(period.closedAt!)),
            if (period.priorPeriodId != null)
              _row('Prior Period ID', '#${period.priorPeriodId}'),
            if (period.closingVoucherId != null)
              _row('Closing Voucher ID', '#${period.closingVoucherId}'),
            if (period.openingVoucherId != null)
              _row('Opening Voucher ID', '#${period.openingVoucherId}'),
            if (period.carryForwards.isNotEmpty)
              _row('Carry Forwards', '${period.carryForwards.length} entries'),
            if (period.createdAt != null)
              _row('Created', _fmt(period.createdAt!)),
            if (period.updatedAt != null)
              _row('Last Updated', _fmt(period.updatedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmt(DateTime d) => DateFormat('MMM d, yyyy').format(d);
