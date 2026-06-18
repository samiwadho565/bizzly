import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/business/controllers/business_controller.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/home/bussiness_card.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_dialouge.dart';

import '../../../components/common/drop_down_menu/drop_down_menu.dart';

class BusinessDetailScreen extends GetView<BusinessDetailController> {
  const BusinessDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<BusinessDetailController>(
      initState: (_) {
        final dynamic args = Get.arguments;
        if (args is BusinessModel) {
          controller.business.value = args;
        }
      },
      builder: (_) {
        final BusinessModel? business = controller.business.value;
        final String businessName = business?.businessName.isNotEmpty == true
            ? business!.businessName
            : 'Business';
        final String imageTag =
            'business_image_${business?.id ?? businessName.hashCode}';
        final String coverTag =
            'business_cover_${business?.id ?? businessName.hashCode}';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: <Widget>[
              // ── Fixed Hero ─────────────────────────────────────
              _buildHero(context, business, businessName, imageTag, coverTag),

              // ── Scrollable Content ─────────────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // "Add" action dropdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              width: 130,
                              child: addDropdownButton(
                                leftText: '',
                                title: 'Add',
                                business: business,
                              ),
                            ),
                          ],
                        ),

                        // Business details card
                        if (business != null) ...<Widget>[
                          const SizedBox(height: 14),
                          _detailsCard(business),
                        ],

                        const SizedBox(height: 20),

                        // Quick actions label
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Quick action cards
                        SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: CategoryCard(
                                  title: 'Customers',
                                  icon: Icons.people_alt_outlined,
                                  onTap: () =>
                                      Get.toNamed(Routes.customersScreen),
                                ),
                              ),
                              Expanded(
                                child: CategoryCard(
                                  title: 'Vendors',
                                  icon: Icons.local_shipping_outlined,
                                  onTap: () =>
                                      Get.toNamed(Routes.vendorsScreen),
                                ),
                              ),
                              Expanded(
                                child: CategoryCard(
                                  title: 'Team',
                                  icon: Icons.groups_outlined,
                                  onTap: () => Get.toNamed(
                                    Routes.teamScreen,
                                    arguments: controller.business.value,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CategoryCard(
                                  title: 'Assets',
                                  icon: Icons.web_asset_outlined,
                                  onTap: () =>
                                      Get.toNamed(Routes.companyAssetsScreen),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Business Activity gradient button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFF1565C0),
                                  Color(0xFF0A2472),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: const Color(0xFF1565C0)
                                      .withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => Get.toNamed(
                                Routes.businessTabsScreen,
                                arguments: business,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.bar_chart_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Business Activity',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Fixed Hero Header
  // ─────────────────────────────────────────────────────────────────

  Widget _buildHero(
    BuildContext context,
    BusinessModel? business,
    String businessName,
    String imageTag,
    String coverTag,
  ) {
    final double topPad = MediaQuery.of(context).padding.top;
    final bool hasCover = (business?.businessCoverImageUrl ?? '').isNotEmpty;

    return SizedBox(
      height: 220 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background: cover image or gradient
          if (hasCover)
            Hero(
              tag: coverTag,
              child: Image.network(
                business!.businessCoverImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => _gradientBackground(),
              ),
            )
          else
            Hero(
              tag: coverTag,
              child: _gradientBackground(),
            ),

          // Dark overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.black.withOpacity(hasCover ? 0.25 : 0.0),
                  Colors.black.withOpacity(hasCover ? 0.65 : 0.45),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative circles when no cover
          if (!hasCover) ...<Widget>[
            Positioned(
              top: topPad - 30,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
          ],

          // Top bar: back + settings
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showActionsSheet(business),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.tune_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Business name + logo at bottom of hero
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: <Widget>[
                Hero(
                  tag: imageTag,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFF1565C0),
                          Color(0xFF0A2472),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: _buildBusinessImage(business),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        businessName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          shadows: <Shadow>[
                            Shadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                      ),
                      if ((business?.businessAddress ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 3),
                        Text(
                          business!.businessAddress,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Actions bottom sheet
  // ─────────────────────────────────────────────────────────────────

  void _showActionsSheet(BusinessModel? business) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Business Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage settings and actions for this business.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _sheetAction(
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF1565C0),
                label: 'Tax Settings',
                onTap: () {
                  Get.back();
                  if (business != null) {
                    Get.toNamed(Routes.taxSettingsScreen, arguments: business);
                    return;
                  }
                  Get.toNamed(Routes.taxSettingsScreen);
                },
              ),
              const SizedBox(height: 8),
              _sheetAction(
                icon: Icons.palette_outlined,
                iconColor: const Color(0xFF8E24AA),
                label: 'Invoice Customization',
                onTap: () {
                  Get.back();
                  if (business != null) {
                    Get.toNamed(Routes.invoiceCustomizationScreen,
                        arguments: business);
                    return;
                  }
                  Get.toNamed(Routes.invoiceCustomizationScreen);
                },
              ),
              const SizedBox(height: 8),
              _sheetAction(
                icon: Icons.edit_outlined,
                iconColor: const Color(0xFF00897B),
                label: 'Edit Business',
                onTap: () async {
                  Get.back();
                  await controller.editBusiness();
                },
              ),
              const SizedBox(height: 8),
              _sheetAction(
                icon: Icons.delete_outline_rounded,
                iconColor: Colors.red,
                label: 'Delete Business',
                labelColor: Colors.red,
                onTap: () {
                  Get.back();
                  _confirmDelete(business);
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BusinessModel? business) {
    if (business?.id == null) return;
    AppDialogs.showDeleteDialog(
      title: 'Delete Business?',
      message: 'This business and all its data will be permanently removed.',
      onDelete: controller.deleteBusiness,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Details card
  // ─────────────────────────────────────────────────────────────────

  Widget _detailsCard(BusinessModel business) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Business Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: controller.toggleDetails,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    controller.detailsExpanded.value
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow('Business Name', business.businessName,
              icon: Icons.business_rounded,
              color: const Color(0xFF1565C0)),
          _detailRow('Address', business.businessAddress,
              icon: Icons.location_on_rounded,
              color: const Color(0xFF00897B)),
          _detailRow('Phone', business.phoneNumber,
              icon: Icons.phone_rounded,
              color: const Color(0xFFE53935)),
          if (controller.detailsExpanded.value) ...<Widget>[
            _detailRow('Email', business.businessEmail,
                icon: Icons.email_rounded,
                color: const Color(0xFF1565C0)),
            _detailRow('Tax / NTN', business.taxNtnNumber,
                icon: Icons.numbers_rounded,
                color: const Color(0xFFF57C00)),
            _detailRow('Website', business.website,
                icon: Icons.language_rounded,
                color: const Color(0xFF00897B)),
            _detailRow('Social Link', business.socialMediaLink,
                icon: Icons.share_rounded,
                color: const Color(0xFF8E24AA)),
            _detailRow('Description', business.businessDescription,
                icon: Icons.description_rounded,
                color: const Color(0xFF546E7A)),
            _detailRow('Hours', business.operatingHours,
                icon: Icons.access_time_rounded,
                color: const Color(0xFFE53935)),
            _detailRow('Secondary', business.secondaryContact,
                icon: Icons.contact_phone_rounded,
                color: const Color(0xFF00897B)),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String? value, {
    IconData? icon,
    Color? color,
  }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null)
            Container(
              margin: const EdgeInsets.only(right: 10, top: 1),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(icon, size: 13, color: color ?? AppColors.primary),
            ),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Image helpers
  // ─────────────────────────────────────────────────────────────────

  Widget _buildBusinessImage(BusinessModel? business) {
    final String? url = business?.businessImageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: 56,
        height: 56,
        errorBuilder: (_, __, ___) =>
            Image.asset(AppImages.building, fit: BoxFit.cover),
      );
    }
    return Image.asset(AppImages.building, fit: BoxFit.cover);
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 90.0;
  @override
  double get maxExtent => 90.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant StickyTabBarDelegate oldDelegate) => false;
}
