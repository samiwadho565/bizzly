import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/circle_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:bizly/routes/routes.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Only the title is dynamic now
  final double height;
  final Color? backgroundColor;
  final Widget? leading;
  final VoidCallback? onLeadingTap;
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.onLeadingTap,
    this.height = 80,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: backgroundColor ?? AppColors.background,
        child: Row(
          children: [
            // Leading (optional)
            if (leading != null) ...[
              InkWell(
                  onTap: onLeadingTap,
                  child: leading!),
              const SizedBox(width: 16),
            ],

            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
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
                  onTap: () {
                    Get.toNamed(Routes.profileScreen);
                  },
                  child: Obx(() {
                    final HomeScreenController homeController =
                        Get.find<HomeScreenController>();
                    final String? url = homeController.displayImageUrl;
                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade400,
                      child: ClipOval(
                        child: url != null && url.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: url,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Image(
                                  image:
                                      AssetImage(AppImages.profilePlaceholder),
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (_, __, ___) => const Image(
                                  image:
                                      AssetImage(AppImages.profilePlaceholder),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Image(
                                image:
                                    AssetImage(AppImages.profilePlaceholder),
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  }),
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
