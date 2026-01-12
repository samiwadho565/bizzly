import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon; // Aap yahan String path bhi de sakte hain agar image use karni ho
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
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
            height: 70, // Aap apni requirement ke mutabiq adjust kar sakte hain
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // Light grey background
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Icon(
              icon,
              size: 34,
              color:  AppColors.primary.withOpacity(0.8),// Teal color jo aapki image mein hai
            ),
          ),
          const SizedBox(height: 5),
          // Title Text
          Expanded(
            child: Text(
              title,
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