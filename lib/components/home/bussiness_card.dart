import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:bizly/utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? image;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
     this.icon,
    required this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          Container(
            height: Get.size.height*0.08, // Aap apni requirement ke mutabiq adjust kar sakte hain
            width: Get.size.width*0.18,
          decoration: BoxDecoration(
            color: Colors.white, // use light grey for better neumorphism
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              // dark shadow bottom-right
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(3, 3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
              // light shadow top-left
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-3, -3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
            // decoration: BoxDecoration(
            //   color: AppColors.background,// Light grey background
            //   borderRadius: BorderRadius.circular(10), // Rounded corners
            // ),
          //   child: Icon(
          //     icon,
          //     size: 34,
          //     color:  AppColors.primary.withOpacity(0.8),// Teal color jo aapki image mein hai
          //   ),
          // ),
          child:
          icon != null ?Icon(
                icon,
                size: 34,
                color:  AppColors.primary.withOpacity(0.8),// Teal color jo aapki image mein hai
              ):image != null ?
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(image!, fit: BoxFit.cover)) : SizedBox()),
          const SizedBox(height: 5),
          // Title Text
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          )

        ],
      ),
    );
  }
}