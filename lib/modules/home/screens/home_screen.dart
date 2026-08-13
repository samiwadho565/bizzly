import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/home/bussiness_card.dart';

class HomeScreen extends GetView<HomeScreenController> {
  final VoidCallback? openDrawer;
  const HomeScreen({super.key, this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Fixed Gradient Hero ────────────────────────────────
            _HeroSection(openDrawer: openDrawer),

            // ── Scrollable Body ────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                displacement: 40,
                onRefresh: controller.fetchBusinesses,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business filter for dashboard summary/vouchers
                      const _DashboardBusinessFilter(),
                      const SizedBox(height: 12),

                      // Stats
                      const _DashboardSummary(),
                      const SizedBox(height: 22),

                      // Recent Vouchers
                      const _RecentVouchers(),
                      const SizedBox(height: 22),

                      // Accounting Quick Access
                      const _SectionLabel(title: 'Accounting'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: _ModernQuickCard(
                            icon: Icons.account_tree_outlined,
                            label: 'Chart of Accounts',
                            from: const Color(0xFF3949AB),
                            to: const Color(0xFF1A237E),
                            onTap: () =>
                                Get.toNamed(Routes.chartOfAccountsScreen),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModernQuickCard(
                            icon: Icons.date_range_outlined,
                            label: 'Accounting Periods',
                            from: const Color(0xFF039BE5),
                            to: const Color(0xFF01579B),
                            onTap: () =>
                                Get.toNamed(Routes.accountingPeriodsScreen),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _ModernQuickCard(
                            icon: Icons.receipt_long_outlined,
                            label: 'Vouchers',
                            from: const Color(0xFF00897B),
                            to: const Color(0xFF004D40),
                            onTap: () => Get.toNamed(Routes.vouchersScreen),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModernQuickCard(
                            icon: Icons.menu_book_outlined,
                            label: 'Ledger',
                            from: const Color(0xFF7B1FA2),
                            to: const Color(0xFF4A148C),
                            onTap: () => Get.toNamed(Routes.ledgerScreen),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 22),

                      // Reports Quick Access
                      const _SectionLabel(title: 'Reports'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: _ModernQuickCard(
                            icon: Icons.bar_chart_rounded,
                            label: 'Income Statement',
                            from: const Color(0xFF43A047),
                            to: const Color(0xFF1B5E20),
                            onTap: () =>
                                Get.toNamed(Routes.incomeStatementScreen),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModernQuickCard(
                            icon: Icons.account_balance_outlined,
                            label: 'Balance Sheet',
                            from: const Color(0xFF1E88E5),
                            to: const Color(0xFF0D47A1),
                            onTap: () =>
                                Get.toNamed(Routes.balanceSheetScreen),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _ModernQuickCard(
                            icon: Icons.balance_outlined,
                            label: 'Trial Balance',
                            from: const Color(0xFFFF7043),
                            to: const Color(0xFFBF360C),
                            onTap: () =>
                                Get.toNamed(Routes.trialBalanceScreen),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ]),
                      const SizedBox(height: 22),

                      // All Businesses
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionLabel(title: 'All Businesses'),
                          TextButton.icon(
                            onPressed: () =>
                                Get.toNamed(Routes.addNewBusiness),
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
                              heroTag:
                                  'business_image_${business.id ?? index}',
                              onTap: () async {
                                final dynamic updated = await Get.toNamed(
                                  Routes.businessDetailScreen,
                                  arguments: business,
                                );
                                if (updated is BusinessModel) {
                                  final int idx = controller.businesses
                                      .indexWhere(
                                          (b) => b.id == updated.id);
                                  if (idx >= 0) {
                                    controller.businesses[idx] = updated;
                                  }
                                }
                              },
                            );
                          },
                        );
                      }),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HERO SECTION
// ═══════════════════════════════════════════════════════════════════

class _HeroSection extends GetView<HomeScreenController> {
  final VoidCallback? openDrawer;
  const _HeroSection({this.openDrawer});

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B4B), Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: _HeroCircle(size: 200, opacity: 0.06),
          ),
          Positioned(
            bottom: 30,
            left: -60,
            child: _HeroCircle(size: 180, opacity: 0.05),
          ),
          Positioned(
            top: top + 40,
            right: 60,
            child: _HeroCircle(size: 80, opacity: 0.04),
          ),

          // Content
          Padding(
            padding:
                EdgeInsets.fromLTRB(20, top + 14, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── AppBar row ───────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: openDrawer,
                      child: Image.asset(
                        AppImages.menu,
                        height: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    // Notification bell
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.22), width: 1),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    // Avatar
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.profileScreen),
                      child: Obx(() {
                        final String? url = controller.displayImageUrl;
                        return Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.40),
                                width: 2),
                          ),
                          child: ClipOval(
                            child: url != null && url.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Image.asset(
                                        AppImages.bizzlyLogo,
                                        fit: BoxFit.cover),
                                    errorWidget: (_, __, ___) => Image.asset(
                                        AppImages.bizzlyLogo,
                                        fit: BoxFit.cover),
                                  )
                                : Image.asset(AppImages.bizzlyLogo,
                                    fit: BoxFit.cover),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Greeting ─────────────────────────────────────
                Obx(() {
                  final String name =
                      controller.user.value?.name?.split(' ').first ??
                          'there';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $name 👋',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Here's your accounting overview",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.60),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 18),

                // ── Pending Approvals (glass) ─────────────────────
                const _PendingApprovalsCard(),

                // ── Period Banner (glass) ─────────────────────────
                const _PeriodBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _HeroCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
        border:
            Border.all(color: Colors.white.withOpacity(opacity * 1.8), width: 1),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PERIOD BANNER  (glass card inside hero)
// ═══════════════════════════════════════════════════════════════════

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
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withOpacity(0.20), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 20),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sub,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.60)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF00E676).withOpacity(0.35),
                      width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00E676),
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

// ═══════════════════════════════════════════════════════════════════
// PENDING APPROVALS  (amber glass card inside hero)
// ═══════════════════════════════════════════════════════════════════

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
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6F00).withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFFFAB40).withOpacity(0.45), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F00).withOpacity(0.35),
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
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: Colors.white.withOpacity(0.60)),
            ],
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// DASHBOARD SUMMARY
// ═══════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════
// DASHBOARD BUSINESS FILTER (confirmed working via ?business_id=)
// ═══════════════════════════════════════════════════════════════════

class _DashboardBusinessFilter extends GetView<HomeScreenController> {
  const _DashboardBusinessFilter();

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DashboardBusinessSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final BusinessModel? selected = controller.dashboardFilterBusiness.value;
      return GestureDetector(
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apartment_rounded, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selected != null ? selected.businessName : 'All businesses',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary.withOpacity(0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary.withOpacity(0.6)),
            ],
          ),
        ),
      );
    });
  }
}

class _DashboardBusinessSheet extends StatelessWidget {
  const _DashboardBusinessSheet({required this.controller});
  final HomeScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 16),
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
                  child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter Dashboard',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                      Text('Show stats for one business',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Obx(() {
              if (controller.isBusinessesLoading.value && controller.businesses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
              }
              final BusinessModel? selected = controller.dashboardFilterBusiness.value;
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _option(
                    context,
                    label: 'All businesses',
                    isSelected: selected == null,
                    onTap: () {
                      controller.applyDashboardBusiness(null);
                      Navigator.pop(context);
                    },
                  ),
                  ...controller.businesses.map((b) => _option(
                        context,
                        label: b.businessName,
                        isSelected: selected?.id == b.id,
                        onTap: () {
                          controller.applyDashboardBusiness(b);
                          Navigator.pop(context);
                        },
                      )),
                  if (!controller.isBusinessesLoading.value && controller.businesses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No businesses found', style: TextStyle(color: Colors.grey.shade500)),
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

  Widget _option(BuildContext context,
      {required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

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
        return const SizedBox(
          height: 116,
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
        _StatData(
          label: 'Approvals',
          value: '${s?.pendingVoucherApprovals ?? 0}',
          icon: Icons.pending_actions_rounded,
          accent: const Color(0xFFFFCA28),
          bg: const Color(0xFFF9A825),
          gradientEnd: const Color(0xFFE65100),
        ),
        _StatData(
          label: 'Posted',
          value: '${s?.postedVouchers ?? 0}',
          icon: Icons.receipt_long_rounded,
          accent: const Color(0xFF4DB6AC),
          bg: const Color(0xFF00897B),
          gradientEnd: const Color(0xFF004D40),
        ),
        _StatData(
          label: 'Team',
          value: '${s?.totalTeamMembers ?? 0}',
          icon: Icons.groups_rounded,
          accent: const Color(0xFF64B5F6),
          bg: const Color(0xFF1976D2),
          gradientEnd: const Color(0xFF0D47A1),
        ),
        _StatData(
          label: 'Tasks',
          value: '${s?.pendingTasks ?? 0}',
          icon: Icons.task_alt_rounded,
          accent: const Color(0xFFE57373),
          bg: const Color(0xFFD32F2F),
          gradientEnd: const Color(0xFFB71C1C),
        ),
      ];

      return SizedBox(
        height: 116,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: stats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _GradientStatCard(data: stats[i]),
        ),
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
                  child:
                      Icon(data.icon, color: Colors.white, size: 18),
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

// ═══════════════════════════════════════════════════════════════════
// RECENT VOUCHERS
// ═══════════════════════════════════════════════════════════════════

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionLabel(title: 'Recent Vouchers'),
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

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
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
                          horizontal: 14, vertical: 12),
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
                                if (v.ledgerEntryNumber != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ledger: ${v.ledgerEntryNumber}',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade400),
                                  ),
                                ],
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
                                  color: statusC.withOpacity(0.10),
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

// ═══════════════════════════════════════════════════════════════════
// MODERN QUICK CARD
// ═══════════════════════════════════════════════════════════════════

class _ModernQuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color from;
  final Color to;
  final VoidCallback onTap;

  const _ModernQuickCard({
    required this.icon,
    required this.label,
    required this.from,
    required this.to,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [from, to],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 10, color: Color(0xFFBBBBBB)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
