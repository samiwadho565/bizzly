import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
 final double? verticalPadding;
 final int maxLine;
  const CustomTextField({
    super.key,
    this.maxLine=1,
    this.verticalPadding,
    required this.hintText,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: widget.maxLine,
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        fillColor: AppColors.textField,
        labelText: widget.hintText, // ✅ String allowed
        // hintText: widget.hintText,
// focusColor: AppColors.primaryDense,
        filled: true,
        contentPadding:  EdgeInsets.symmetric(horizontal: 20, vertical:widget.verticalPadding?? 18),
        border: InputBorder.none, // Border remove kar diya style ke liye
        labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.2), // Boht halki border
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primary, // Aapka primary color
            width: 1.5,
          ),
        ),
        // Password field ke liye eye icon
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color:  AppColors.primary.withOpacity(0.5), // Image wala icon color
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}