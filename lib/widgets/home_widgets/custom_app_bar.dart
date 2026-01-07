import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading; // Leading widget (icon, text, image, etc.)
  final Widget? title; // Title widget (text, logo, etc.)
  final Widget? trailing; // Trailing widget (notification, profile, or any custom)
  final double height;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.height = 80,
    this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: height,

        padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: backgroundColor??AppColors.background,
        child: Row(
          children: [
            // Leading
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ],

            // Title
            if (title != null)
              Expanded(child: title!)
            else
              const Spacer(),

            // Trailing
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
