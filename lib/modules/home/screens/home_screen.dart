import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/home/bussiness_card.dart';
import 'package:bizly/components/home/custom_app_bar.dart';

class HomeScreen extends GetView<HomeScreenController> {
  final VoidCallback? openDrawer;
  const HomeScreen({super.key, this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        appBar: CustomAppBar(
          title: "Dashboard",
          leading: Image.asset(AppImages.menu, height: 40),
          onLeadingTap: () => openDrawer?.call(),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchBusinesses,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Greeting ──────────────────────────────────────
                Obx(() {
                  final String name =
                      controller.user.value?.name?.split(' ').first ?? 'there';
                  return Text(
                    'Hello, $name 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                }),
                const SizedBox(height: 3),
                Text(
                  'Here\'s your accounting overview',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),

                // ── Pending Approvals Card ────────────────────────
                const _PendingApprovalsCard(),

                // ── Current Period Banner ─────────────────────────
                const _PeriodBanner(),
                const SizedBox(height: 14),

                // ── Dashboard Summary ─────────────────────────────
                const _DashboardSummary(),
                const SizedBox(height: 16),

                // ── Recent Vouchers ───────────────────────────────
                const _RecentVouchers(),
                const SizedBox(height: 16),

                // ── Accounting Quick Access ────────────────────────
                const Text(
                  'Accounting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.account_tree_outlined,
                        label: 'Chart of Accounts',
                        onTap: () => Get.toNamed(Routes.chartOfAccountsScreen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.date_range_outlined,
                        label: 'Accounting Periods',
                        onTap: () => Get.toNamed(Routes.accountingPeriodsScreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Vouchers',
                        onTap: () => Get.toNamed(Routes.vouchersScreen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.menu_book_outlined,
                        label: 'Ledger',
                        onTap: () => Get.toNamed(Routes.ledgerScreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Reports Quick Access ───────────────────────────
                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Income Statement',
                        onTap: () => Get.toNamed(Routes.incomeStatementScreen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.account_balance_outlined,
                        label: 'Balance Sheet',
                        onTap: () => Get.toNamed(Routes.balanceSheetScreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.balance_outlined,
                        label: 'Trial Balance',
                        onTap: () => Get.toNamed(Routes.trialBalanceScreen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 20),

                // ── All Businesses ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Businesses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Get.toNamed(Routes.addNewBusiness),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Obx(() {
                  if (controller.isBusinessesLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    );
                  }
                  if (controller.businesses.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          controller.businessesError.value.isNotEmpty
                              ? controller.businessesError.value
                              : 'No businesses found.',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.businesses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final BusinessModel business =
                          controller.businesses[index];
                      return CategoryCard(
                        title: business.businessName,
                        imageUrl: business.businessImageUrl,
                        heroTag: 'business_image_${business.id ?? index}',
                        onTap: () async {
                          final dynamic updated = await Get.toNamed(
                            Routes.businessDetailScreen,
                            arguments: business,
                          );
                          if (updated is BusinessModel) {
                            final int idx = controller.businesses
                                .indexWhere((b) => b.id == updated.id);
                            if (idx >= 0) {
                              controller.businesses[idx] = updated;
                            }
                          }
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Period Banner ─────────────────────────────────────────────────
class _PeriodBanner extends GetView<HomeScreenController> {
  const _PeriodBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final period = controller.dashboard.value?.accountingPeriod;
      final String name = period?.name ?? 'Accounting Period';
      final String sub = (period != null)
          ? '${period.startDate}  →  ${period.endDate}'
          : 'Tap to view';

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.accountingPeriodsScreen),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gradient icon box
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sub,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00A040),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Dashboard Summary ─────────────────────────────────────────────
class _DashboardSummary extends GetView<HomeScreenController> {
  const _DashboardSummary();

  static String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading = controller.isDashboardLoading.value;
      final dashboard = controller.dashboard.value;

      if (loading && dashboard == null) {
        return SizedBox(
          height: 130,
          child: Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2),
          ),
        );
      }

      final s = dashboard?.summary;

      final List<_StatData> stats = [
        _StatData(
          label: 'Revenue',
          value: _fmt(s?.totalRevenue ?? 0),
          icon: Icons.trending_up_rounded,
          accent: const Color(0xFF00BFA5),
          bg: const Color(0xFF00897B),
          gradientEnd: const Color(0xFF004D40),
        ),
        _StatData(
          label: 'Expenses',
          value: _fmt(s?.totalExpenses ?? 0),
          icon: Icons.trending_down_rounded,
          accent: const Color(0xFFEF5350),
          bg: const Color(0xFFE53935),
          gradientEnd: const Color(0xFFB71C1C),
        ),
        _StatData(
          label: s?.isProfit == true ? 'Net Profit' : 'Net Loss',
          value: _fmt(s?.isProfit == true
              ? (s?.netProfit ?? 0)
              : (s?.netLoss ?? 0)),
          icon: s?.isProfit == true
              ? Icons.show_chart_rounded
              : Icons.signal_cellular_alt_rounded,
          accent: s?.isProfit == true
              ? const Color(0xFF42A5F5)
              : const Color(0xFFAB47BC),
          bg: s?.isProfit == true
              ? const Color(0xFF1E88E5)
              : const Color(0xFF8E24AA),
          gradientEnd: s?.isProfit == true
              ? const Color(0xFF0D47A1)
              : const Color(0xFF4A148C),
        ),
        _StatData(
          label: 'Cash & Bank',
          value: _fmt(s?.cashAndBank ?? 0),
          icon: Icons.account_balance_wallet_rounded,
          accent: const Color(0xFF29B6F6),
          bg: const Color(0xFF039BE5),
          gradientEnd: const Color(0xFF01579B),
        ),
        _StatData(
          label: 'Receivable',
          value: _fmt(s?.accountsReceivable ?? 0),
          icon: Icons.arrow_circle_down_rounded,
          accent: const Color(0xFFFF8A65),
          bg: const Color(0xFFFF7043),
          gradientEnd: const Color(0xFFBF360C),
        ),
        _StatData(
          label: 'Payable',
          value: _fmt(s?.accountsPayable ?? 0),
          icon: Icons.arrow_circle_up_rounded,
          accent: const Color(0xFFBA68C8),
          bg: const Color(0xFF7B1FA2),
          gradientEnd: const Color(0xFF4A148C),
        ),
        _StatData(
          label: 'Total Assets',
          value: _fmt(s?.totalAssets ?? 0),
          icon: Icons.business_center_rounded,
          accent: const Color(0xFF7986CB),
          bg: const Color(0xFF3949AB),
          gradientEnd: const Color(0xFF1A237E),
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Scrollable Stat Cards ──────────────────────────────
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: stats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _GradientStatCard(data: stats[i]),
            ),
          ),
        ],
      );
    });
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color bg;
  final Color gradientEnd;
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.bg,
    required this.gradientEnd,
  });
}

class _GradientStatCard extends StatelessWidget {
  const _GradientStatCard({required this.data});
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.bg, data.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: data.gradientEnd.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle circle decoration top-right
          Positioned(
            top: -14,
            right: -14,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.value,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.78),
                        fontWeight: FontWeight.w500,
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


// ── Recent Vouchers ───────────────────────────────────────────────
class _RecentVouchers extends GetView<HomeScreenController> {
  const _RecentVouchers();

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'receipt':    return const Color(0xFF00897B);
      case 'payment':    return const Color(0xFFE53935);
      case 'journal':    return const Color(0xFF1E88E5);
      case 'contra':     return const Color(0xFF8E24AA);
      case 'adjustment': return const Color(0xFFFF7043);
      default:           return AppColors.primary;
    }
  }

  static Color _typeBg(String type) {
    switch (type.toLowerCase()) {
      case 'receipt':    return const Color(0xFFE0F2F1);
      case 'payment':    return const Color(0xFFFFEBEE);
      case 'journal':    return const Color(0xFFE3F2FD);
      case 'contra':     return const Color(0xFFF3E5F5);
      case 'adjustment': return const Color(0xFFFBE9E7);
      default:           return const Color(0xFFEDE7F6);
    }
  }

  static IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'receipt':    return Icons.arrow_circle_down_rounded;
      case 'payment':    return Icons.arrow_circle_up_rounded;
      case 'journal':    return Icons.import_export_rounded;
      case 'contra':     return Icons.swap_horiz_rounded;
      case 'adjustment': return Icons.tune_rounded;
      default:           return Icons.receipt_long_rounded;
    }
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'posted':    return const Color(0xFF2E7D32);
      case 'submitted': return const Color(0xFF1E88E5);
      case 'rejected':  return const Color(0xFFE53935);
      default:          return Colors.grey;
    }
  }

  static String _fmtAmount(double v) {
    if (v <= 0) return '—';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vouchers = controller.dashboard.value?.recentVouchers ?? [];
      if (vouchers.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Vouchers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.vouchersScreen),
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Compact Voucher List ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: () {
                final int count =
                    vouchers.length > 3 ? 3 : vouchers.length;
                final List<Widget> rows = [];
                for (int i = 0; i < count; i++) {
                  final v = vouchers[i];
                  final Color accent = _typeColor(v.voucherType);
                  final Color bg = _typeBg(v.voucherType);
                  final Color statusC = _statusColor(v.status);
                  final String amount = _fmtAmount(
                      v.totalDebit > 0 ? v.totalDebit : v.totalCredit);

                  if (i > 0) {
                    rows.add(const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 62,
                      endIndent: 0,
                      color: Color(0xFFF0F0F0),
                    ));
                  }

                  rows.add(GestureDetector(
                    onTap: () => Get.toNamed(Routes.vouchersScreen),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_typeIcon(v.voucherType),
                                color: accent, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.voucherNumber,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  v.narration.isEmpty
                                      ? v.voucherType
                                      : v.narration,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                amount,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusC.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  v.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: statusC,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ));
                }
                return rows;
              }(),
            ),
          ),
        ],
      );
    });
  }
}

// ── Pending Approvals Card ────────────────────────────────────────
class _PendingApprovalsCard extends GetView<HomeScreenController> {
  const _PendingApprovalsCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<VoucherModel> list = controller.pendingApprovals;
      if (list.isEmpty) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.vouchersScreen),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE65100).withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${list.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Vouchers pending your approval',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Colors.white70),
              ],
            ),
          ),
        ),
      );
    });
  }
}


// ── Quick Access Card ─────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryDense),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
