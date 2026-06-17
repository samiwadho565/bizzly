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
  /// Optional gradient override. If null, derives a gradient from [color].
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56.0,
    this.color = AppColors.primary,
    this.isLoading = false,
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.gradient,
  });

  Gradient get _effectiveGradient {
    if (gradient != null) return gradient!;
    // Default primary → deep navy-to-blue gradient
    if (color == AppColors.primary || color == const Color(0xFF0D47A1)) {
      return const LinearGradient(
        colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    // For other colors, derive a subtle gradient (color → slightly lighter)
    return LinearGradient(
      colors: [color, Color.lerp(color, Colors.white, 0.18)!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _effectiveGradient,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != Colors.transparent
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
