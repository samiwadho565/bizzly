import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';

Widget addButton(String title,{Icon? icon,VoidCallback? onTap}) {
  return InkWell(
    onTap:onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.background, // Light grey background
        borderRadius: BorderRadius.circular(12), // Rounded corners


          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Jitni zaroorat ho utni width le
        children:  [
          icon??  Icon(
         Icons.add,
            color: Colors.black54,
            size: 17,
          ),
          SizedBox(width: 8), // Icon aur text ke beech ka gap
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}