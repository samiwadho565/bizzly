import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bizly/utils/app_colors.dart';
import 'loader/loader.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final Color color;
  final bool isLoading;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56.0,
    this.color = AppColors.primary,
    this.isLoading = false,
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          onPressed: onPressed,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? Center(
                    key: const ValueKey("loader"),
                    child: FinancePulseLoader(
                      color: textColor,
                      size: 45,
                    ),
                  )
                : Text(
                    text,
                    key: const ValueKey("text"),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
