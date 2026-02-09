import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/assets/images.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? image;
  final String? imageUrl;
  final String? heroTag;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
     this.icon,
    required this.onTap,
    this.image,
    this.imageUrl,
    this.heroTag,
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
                color: Colors.grey.shade100,
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
          child: _buildImage()),
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

  Widget _buildImage() {
    if (icon != null) {
      return Icon(
        icon,
        size: 34,
        color: AppColors.primary.withOpacity(0.8),
      );
    }

    final bool hasBusinessHero = heroTag != null && heroTag!.isNotEmpty;

    Widget imageWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            AppImages.building,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (image != null && image!.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Image.asset(
              image!, fit: BoxFit.cover),
        ),
      );
    } else {
      imageWidget = Image.asset(AppImages.building, fit: BoxFit.cover);
    }

    if (hasBusinessHero) {
      return Hero(tag: heroTag!, child: imageWidget);
    }

    return imageWidget;
  }
}
