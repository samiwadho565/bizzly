import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
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
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryDense,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const CustomAppBar2(
              title: 'Accounting Periods',
              backgroundColor: AppColors.primaryDense,
              textColor: Colors.white,
            ),
          ),
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
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDense,
            AppColors.primaryDense.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Current Period',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            period.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
        ],
      ),
    );
  }
}

// ── Period List Tile ──────────────────────────────────────────────
class _PeriodTile extends StatelessWidget {
  const _PeriodTile({required this.period});
  final AccountingPeriodModel period;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
      ),
    );
  }
}

String _fmt(DateTime d) => DateFormat('MMM d, yyyy').format(d);
