import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Color backgroundColor;
  final double elevation;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar2({
    super.key,
    required this.title,
    this.centerTitle = false, // title left side by default
    this.backgroundColor = AppColors.background,
    this.elevation = 0,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: backgroundColor,
      backgroundColor: backgroundColor,
      elevation: elevation,
      title: Padding(
        padding: const EdgeInsets.only(left: 0), // agar extra padding chahiye to adjust kar sakte ho
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
