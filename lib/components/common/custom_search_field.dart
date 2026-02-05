import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';

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
      // Shadow ko bahar rakha hai taake aesthetic look aaye
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

          // 1. Default Border (Jab tap na kiya ho)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.08), // Boht halki border
              width: 1,
            ),
          ),

          // 2. Focused Border (Jab tap karein - Enable ho jaye)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.primary, // Aapka primary color
              width: 1.5,
            ),
          ),

          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary.withOpacity(0.5),
          ),

          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.primary.withOpacity(0.5),
              size: 20,
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