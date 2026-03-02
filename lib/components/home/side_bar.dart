import 'package:bizly/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/routes/routes.dart';

class CustomSideBar extends StatelessWidget {
  const CustomSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryDense,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Image.asset(AppImages.bizzlyLogo),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bizzly",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Your Financial Partner",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    const Padding(
                      padding: EdgeInsets.only(left: 15, top: 15),
                      child: Text(
                        "Selected Business",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _drawerItem(
                      icon: AppImages.building,
                      title: "Add New Business",
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.addNewBusiness);
                      },
                    ),
                    _drawerItem(
                      icon: AppImages.customer,
                      title: "Customers",
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.customersScreen);
                      },
                    ),
                    _drawerItem(
                      icon: AppImages.vendor,
                      title: "Vendors",
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.vendorsScreen);
                      },
                    ),
                    _drawerItem(
                      icon: AppImages.follower,
                      title: "Team",
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.teamScreen);
                      },
                    ),
                    _drawerItem(
                      icon: AppImages.assets,
                      title: "Company Assets",
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.companyAssetsScreen);
                      },
                    ),
                    _drawerItem(
                      icon: AppImages.bill,
                      title: "Balance Sheet",
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.balanceSheetScreen);
                      },
                    ),
                    _drawerItem(
                      icon: AppImages.expense,
                      title: "Trial Balance",
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.trialBalanceScreen);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            _drawerItem(
              icon: AppImages.taskFill,
              title: "Categories",
              onTap: () {
                Get.back();
                Get.toNamed(Routes.categoriesScreen);
              },
            ),
            _drawerItem(
              icon: AppImages.settings,
              title: "Settings",
              onTap: () {
                Get.back();
                Get.toNamed(Routes.profileScreen);
              },
            ),
            _drawerItem(
              icon: AppImages.logOut,
              title: "Logout",
              onTap: () {
                Get.back();
                // logout logic
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------- Reusable Drawer Item ----------
  Widget _drawerItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading:Image.asset(icon,color: Colors.white,height: 27,),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
