import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;

  const CustomSearchField({
    super.key,
    required this.hintText,
    required this.controller,
    this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyButtonColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          border: InputBorder.none,

          /// 🔍 Search icon (left)
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary.withOpacity(0.5),
          ),

          /// ❌ Clear icon (right)
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.primary.withOpacity(0.5),
            ),
            onPressed: () {
              controller.clear();
              if (onClear != null) onClear!();
            },
          )
              : null,
        ),
      ),
    );
  }
}
