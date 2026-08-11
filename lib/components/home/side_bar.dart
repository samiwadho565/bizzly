import 'package:bizly/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/routes/routes.dart';

class CustomSideBar extends StatelessWidget {
  const CustomSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1628), Color(0xFF0D2152), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Decorative circles ─────────────────────────────
              Positioned(
                top: -60,
                right: -60,
                child: _Circle(size: 200, opacity: 0.05),
              ),
              Positioned(
                bottom: 80,
                left: -80,
                child: _Circle(size: 220, opacity: 0.04),
              ),
              Positioned(
                top: 200,
                right: -40,
                child: _Circle(size: 120, opacity: 0.03),
              ),

              // ── Content ─────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _DrawerHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Business ───────────────────────────
                          _SectionLabel('BUSINESS'),
                          _DrawerItem(
                            icon: Icons.add_business_rounded,
                            iconColor: const Color(0xFF00BCD4),
                            title: 'Add New Business',
                            onTap: () { Get.back(); Get.toNamed(Routes.addNewBusiness); },
                          ),
                          _DrawerItem(
                            icon: Icons.people_alt_rounded,
                            iconColor: const Color(0xFF66BB6A),
                            title: 'Customers',
                            onTap: () { Get.back(); Get.toNamed(Routes.customersScreen); },
                          ),
                          _DrawerItem(
                            icon: Icons.local_shipping_rounded,
                            iconColor: const Color(0xFFFF7043),
                            title: 'Vendors',
                            onTap: () { Get.back(); Get.toNamed(Routes.vendorsScreen); },
                          ),
                          _DrawerItem(
                            icon: Icons.groups_rounded,
                            iconColor: const Color(0xFFAB47BC),
                            title: 'Team',
                            onTap: () { Get.back(); Get.toNamed(Routes.teamScreen); },
                          ),
                          _DrawerItem(
                            icon: Icons.manage_accounts_rounded,
                            iconColor: const Color(0xFF26A69A),
                            title: 'Business Team',
                            onTap: () { Get.back(); Get.toNamed(Routes.teamMembersScreen); },
                          ),
                          _DrawerItem(
                            icon: Icons.business_center_rounded,
                            iconColor: const Color(0xFF29B6F6),
                            title: 'Company Assets',
                            onTap: () { Get.back(); Get.toNamed(Routes.companyAssetsScreen); },
                          ),

                          const SizedBox(height: 8),
                          _Divider(),

                          // ── Accounting ─────────────────────────
                          _SectionLabel('ACCOUNTING'),
                          _DrawerItem(
                            icon: Icons.account_tree_rounded,
                            iconColor: const Color(0xFF42A5F5),
                            title: 'Chart of Accounts',
                            onTap: () { Get.back(); Get.toNamed(Routes.chartOfAccountsScreen); },
                          ),
                          _DrawerItem(
                            icon: Icons.date_range_rounded,
                            iconColor: const Color(0xFF26C6DA),
                            title: 'Accounting Periods',
                            onTap: () { Get.back(); Get.toNamed(Routes.accountingPeriodsScreen); },
                          ),
                          _DrawerItem(
                            icon: Icons.receipt_long_rounded,
                            iconColor: const Color(0xFF4DB6AC),
                            title: 'Vouchers',
                            onTap: () { Get.back(); Get.toNamed(Routes.vouchersScreen); },
                          ),

                          const SizedBox(height: 8),
                          _Divider(),

                          // ── Reports ────────────────────────────
                          _SectionLabel('REPORTS'),
                          _DrawerItem(
                            icon: Icons.account_balance_rounded,
                            iconColor: const Color(0xFF7986CB),
                            title: 'Balance Sheet',
                            onTap: () { Get.back(); Get.toNamed(Routes.balanceSheetScreen); },
                          ),
                          _DrawerItem(
                            icon: Icons.balance_rounded,
                            iconColor: const Color(0xFFFF8A65),
                            title: 'Trial Balance',
                            onTap: () { Get.back(); Get.toNamed(Routes.trialBalanceScreen); },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom ───────────────────────────────────────
                  _Divider(),
                  const SizedBox(height: 4),
                  _DrawerItem(
                    icon: Icons.grid_view_rounded,
                    iconColor: const Color(0xFFFFCA28),
                    title: 'Categories',
                    onTap: () { Get.back(); Get.toNamed(Routes.categoriesScreen); },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF90A4AE),
                    title: 'Settings',
                    onTap: () { Get.back(); Get.toNamed(Routes.profileScreen); },
                  ),
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFEF5350),
                    title: 'Log Out',
                    titleColor: const Color(0xFFEF9A9A),
                    onTap: () { Get.back(); },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(AppImages.bizzlyLogo, fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bizzly',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Your Financial Partner',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Thin accent line
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.40),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Drawer Item
// ─────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.06),
      highlightColor: Colors.white.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: iconColor.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Colors.white.withOpacity(0.88),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: Colors.white.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Divider
// ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Decorative Circle
// ─────────────────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
