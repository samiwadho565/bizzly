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
      backgroundColor: AppColors. primaryDense,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Header ----------
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children:  [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Image.asset(AppImages.bizzlyLogo)
                  ),
                  SizedBox(width: 12),
                  Column(
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
            Padding(
              padding: const EdgeInsets.only(left: 15,top: 15),
              child: Text(
                "Selected Business",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 15,),
            // ---------- Menu Items ----------

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
              onTap: () => Get.toNamed(Routes.vendorsScreen),
            ),
            _drawerItem(
              icon: AppImages.follower,
              title: "Team",
                onTap: () {
                  Get.back();Get.toNamed(Routes.teamScreen);}
            ),
            _drawerItem(
              icon: AppImages.assets,
              title: "Company Assets",
              onTap: () => Get.toNamed(Routes.companyAssetsScreen),
            ),

            _drawerItem(
              icon: AppImages.expenseFill,
              title: "Expanses",
              onTap: () => Get.toNamed(Routes.companyAssetsScreen),
            ),


            _drawerItem(
              icon: AppImages.billFill,
              title: "Invoices",
              onTap: () => Get.toNamed(Routes.companyAssetsScreen),
            ),

            _drawerItem(
              icon: AppImages.taskFill,
              title: "Tasks",
              onTap: () => Get.toNamed(Routes.companyAssetsScreen),
            ),

            //const Spacer(),



            // _drawerItem(
            //   icon: AppImages.building,
            //   title: "Businesses",
            //   onTap: () {
            //     Get.back();
            //     Get.toNamed(Routes.allBusinessScreen);
            //   },
            // ),
            const Divider(color: Colors.white24),
            _drawerItem(
              icon: AppImages.settings,
              title: "Settings",

              onTap: () => Get.toNamed(Routes.profileScreen),
            ),
            _drawerItem(
              icon: AppImages.logOut,
              title: "Logout",
              onTap: () {
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
