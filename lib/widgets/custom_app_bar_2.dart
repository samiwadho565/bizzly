import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:get/get.dart';

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isBackArrow; // ✅ new property

  const CustomAppBar2({
    super.key,
    this.textColor = Colors.black,
    required this.title,
    this.centerTitle = false, // title left side by default
    this.backgroundColor = AppColors.background,
    this.elevation = 0,
    this.leading,
    this.actions,
    this.isBackArrow = true, // default true
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: backgroundColor,
      backgroundColor: backgroundColor,
      elevation: elevation,
      title: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      centerTitle: centerTitle,
      leading: leading ??
          (isBackArrow
              ? IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color:  textColor,
              size: 23,
            ),
            onPressed: () {
              Get.back(); // use GetX to go back
            },
          )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
