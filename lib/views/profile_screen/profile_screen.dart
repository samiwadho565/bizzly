import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(AppImages.profilePlaceholder), // Replace with Lisa's image
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Lisa Smith",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text("LisaSmith@gmail.com", style: TextStyle(color: Colors.grey[600])),
                      Text("+1 (212) 555-0147", style: TextStyle(color: Colors.grey[600])),
                    ],
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
                  ProfileTile(title: "Expense Categories", onTap: () {}),
                  ProfileTile(title: "Invoice Customization", onTap: () {}),

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