import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'loader/loader.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final Color color;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56.0,
    this.color = AppColors.primary,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: color,
        borderRadius: BorderRadius.circular(15),
        onPressed: onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? const Center(
            key: ValueKey("loader"),
            child: FinancePulseLoader(
              color: Colors.white,
              size: 45,
            ),
          )
              : Text(
            text,
            key: const ValueKey("text"),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
