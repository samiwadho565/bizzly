import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/views/profile_screen/tax_settings_screen/tax_settings_screen.dart';
import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../routes/routes.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_drop_down.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/custom_toggle_button.dart';
import '../../widgets/home_widgets/bussiness_card.dart';
import '../../widgets/home_widgets/custom_app_bar.dart';
import '../../widgets/home_widgets/custom_revenue_chart.dart';
import '../../widgets/home_widgets/flow_chart.dart';
import '../../widgets/invoice_screen_widgets/invoice_card.dart';
import '../../widgets/projects_screen_widgets/project_detail_card.dart';
import '../../widgets/task_card_widget.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
// ProfileTile ko import karein
// import 'package:bizly/widgets/profile_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(title: "Profile"),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
        Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  AssetImage(AppImages.profilePlaceholder), // Replace with user's image
                ),
                // Edit icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      print("Edit profile image tapped");
                      AppUtils.showEditProfileSheet(currentName: "Lisa Smith", currentEmail: "LisaSmith@gmail.com", currentPhone: "+1 (212) 555-0147", onSave: (){});
                      // TODO: Open image picker or edit profile sheet
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blue, // primary color
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Lisa Smith",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "LisaSmith@gmail.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "+1 (212) 555-0147",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
      ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle("Financial"),
                  ProfileTile(title: "Tax Settings", onTap: () {

                    Get.to(()=>TaxSettingsScreen());
                        }),
                  ProfileTile(title: "Invoice Customization", onTap: () {

                    Get.toNamed(Routes.invoiceCustomizationScreen);
                  }),

                  const SizedBox(height: 10),
                  _buildSectionTitle("Security "),
                  ProfileTile(title: "Change Password", onTap: () {}),

                  const SizedBox(height: 10),
                  _buildSectionTitle("Support and Legal"),
                  ProfileTile(title: "Contact Support", onTap: () {}),
                  ProfileTile(
                      title: "Data Export",
                      trailingText: "CSV/PDF",
                      onTap: () {}
                  ),
                  ProfileTile(title: "Terms and Conditions", onTap: () {}),
                  ProfileTile(
                      title: "Log Out",
                      textColor: AppColors.primary.withOpacity(0.7),
                      onTap: () {}
                  ),
                  ProfileTile(
                      title: "Delete Account",
                      textColor: Colors.red,
                      onTap: () {}
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 10),
      child: Text(
        title,
        style:  TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Color? textColor;

  const ProfileTile({
    super.key,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.4),// Light grey background
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Colors.black87,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: textColor ?? Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}