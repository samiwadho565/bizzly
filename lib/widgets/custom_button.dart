import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'loader/loader.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56.0,
    this.color = AppColors.primary,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isLoading = false;

  Future<void> _handleTap() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // 2 seconds loader show
    await Future.delayed(const Duration(seconds: 2));

    setState(() => isLoading = false);

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: widget.color,
        borderRadius: BorderRadius.circular(15),
        onPressed: _handleTap,
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
            widget.text,
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
