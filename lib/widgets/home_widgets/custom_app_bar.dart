import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../routes/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Only the title is dynamic now
  final double height;
  final Color? backgroundColor;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.height = 80,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: backgroundColor ?? AppColors.background,
        child: Row(
          children: [
            // Leading (optional)
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ],

            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            // Trailing (always fixed)
            Row(
              children: [
                CircleIcon(
                  circleSize: 37,
                  circleColor: Colors.white,
                  icon: Icons.notifications,
                  iconColor: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: (){
                    Get.toNamed(Routes.profileScreen );
                  },
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage(AppImages.profilePlaceholder),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
