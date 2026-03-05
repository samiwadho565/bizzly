import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/business/controllers/business_controller.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/home/bussiness_card.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_dialouge.dart';

import '../../../components/common/drop_down_menu/drop_down_menu.dart';

class BusinessDetailScreen extends GetView<BusinessDetailController> {
  const BusinessDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final BusinessModel? business = controller.business.value;
      final String businessName = business?.businessName.isNotEmpty == true
          ? business!.businessName
          : "Business";
      final String imageTag =
          'business_image_${business?.id ?? businessName.hashCode}';
      final String coverTag =
          'business_cover_${business?.id ?? businessName.hashCode}';

      return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: businessName,
        actions: [
          InkWell(
            onTap: () => _showActionsSheet(business),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40),
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Hero(
                          tag: coverTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildCoverImage(business),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: -28,
                          child: Hero(
                            tag: imageTag,
                            child: Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _buildBusinessImage(business),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          businessName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: addDropdownButton(
                            leftText: '',
                            title: "Add",
                            business: business,
                          ),
                        ),
                      ],
                    ),
                    if ((business?.businessAddress ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        business!.businessAddress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (business != null) ...[
                      const SizedBox(height: 14),
                      _detailsCard(business),
                    ],
                  ],
                ),
              ),
            ),
            /// --- Top Section ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CategoryCard(
                              title: "Customers",
                              icon: Icons.people_alt_outlined,
                              onTap: () {
                                Get.toNamed(Routes.customersScreen);
                              },
                            ),
                          ),
                          Expanded(
                            child: CategoryCard(
                              title: "Vendors",
                              icon: Icons.settings_outlined,
                              onTap: () {
                                Get.toNamed(Routes.vendorsScreen);
                              },
                            ),
                          ),
                          Expanded(
                            child: CategoryCard(
                              title: "Team members",
                              icon: Icons.supervised_user_circle_sharp,
                              onTap: () {
                                Get.toNamed(Routes.teamScreen);
                              },
                            ),
                          ),
                          Expanded(
                            child: CategoryCard(
                              title: "Company Assets",
                              icon: Icons.web_asset,
                              onTap: () {
                                Get.toNamed(Routes.companyAssetsScreen);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 20,),
                    // Container(
                    //   //color: Colors.red,
                    //   height: 100,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Expanded(
                    //         child: CategoryCard(
                    //           title: "Company Assets",
                    //           icon: Icons.settings_outlined,
                    //           onTap: () {
                    //             //Get.toNamed(Routes.businessDetailScreen,);
                    //
                    //           },
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: CategoryCard(
                    //           title: "Team Members",
                    //           icon: Icons.settings_outlined,
                    //           onTap: () {
                    //             //Get.toNamed(Routes.businessDetailScreen,);
                    //
                    //           },
                    //         ),
                    //       ),
                    //       // StatCard(
                    //       //   title: "Total Expenses",
                    //       //   value: "\$1,250",
                    //       //   icon: const Icon(
                    //       //     Icons.arrow_upward,
                    //       //     color: Colors.red,
                    //       //   ),
                    //       //   backgroundColor: const Color(0xFFFFF5F5),
                    //       //   contentColor: Colors.red.shade400,
                    //       // ),
                    //       //
                    //       // StatCard(
                    //       //   title: "Pending Tasks",
                    //       //   value: "2",
                    //       //   icon: const Icon(
                    //       //     Icons.assignment_outlined,
                    //       //     color: Colors.orange,
                    //       //   ),
                    //       //   backgroundColor: const Color(0xFFFFF9F0),
                    //       //   contentColor: Colors.orange.shade400,
                    //       // ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Business Activity",
                        onPressed: () {
                          Get.toNamed(Routes.businessTabsScreen);
                        },
                      ),
                    ),
                    const SizedBox(width: 120),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    });
  }

  void _showActionsSheet(BusinessModel? business) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Business Settings",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Manage settings and actions for this specific business.",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Tax Settings",
                color: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.lightGrey,
                onPressed: () {
                  Get.back();
                  if (business != null) {
                    Get.toNamed(
                      Routes.taxSettingsScreen,
                      arguments: business,
                    );
                    return;
                  }
                  Get.toNamed(Routes.taxSettingsScreen);
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Invoice Customization",
                color: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.lightGrey,
                onPressed: () {
                  Get.back();
                  if (business != null) {
                    Get.toNamed(
                      Routes.invoiceCustomizationScreen,
                      arguments: business,
                    );
                    return;
                  }
                  Get.toNamed(Routes.invoiceCustomizationScreen);
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Edit Business",
                onPressed: () async {
                  Get.back();
                  await controller.editBusiness();
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Delete Business",
                color: Colors.white,
                textColor: Colors.red,
                borderColor: Colors.red,
                onPressed: () {
                  Get.back();
                  _confirmDelete(business);
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BusinessModel? business) {
    if (business?.id == null) return;
    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogTrash,
      title: "Delete Business?",
      message: "Are you sure you want to delete this business?",
      actions: [
        AppDialogAction(
          label: "Delete",
          onPressed: controller.deleteBusiness,
          textColor: Colors.red,
        ),
        AppDialogAction(label: "Cancel"),
      ],
    );
  }

  Widget _detailsCard(BusinessModel business) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Business Details",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
          const SizedBox(height: 10),
          _detailRow("Business Name", business.businessName),
          _detailRow("Address", business.businessAddress),
          _detailRow("Phone", business.phoneNumber),
          //_detailRow("Currency", business.currency),
          if (controller.detailsExpanded.value) ...[
            _detailRow("Email", business.businessEmail),
            _detailRow("Tax / NTN", business.taxNtnNumber),
            _detailRow("Website", business.website),
            _detailRow("Social Link", business.socialMediaLink),
            _detailRow("Description", business.businessDescription),
            _detailRow("Operating Hours", business.operatingHours),
            _detailRow("Secondary Contact", business.secondaryContact),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BusinessModel? business) {
    final String? url = business?.businessCoverImageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
      );
    }
    return _buildCoverPlaceholder();
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: AppColors.textField,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.image_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(height: 6),
          Text(
            "No cover image",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessImage(BusinessModel? business) {
    final String? url = business?.businessImageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          AppImages.building,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(AppImages.building, fit: BoxFit.cover);
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 90.0; // TabBar ki height + padding
  @override
  double get maxExtent => 90.0;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Colors.white, // Sticky hone par background color
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant StickyTabBarDelegate oldDelegate) => false;
}
