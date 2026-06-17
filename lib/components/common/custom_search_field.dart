import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';

class CustomSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;

  /// Set [isDark] to true when placed on a dark/gradient background (e.g.
  /// inside [GradientScreenHeader]) to get a glassmorphic frosted style.
  final bool isDark;

  const CustomSearchField({
    super.key,
    required this.hintText,
    required this.controller,
    this.onClear,
    this.onChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDark) return _buildDark();
    return _buildLight();
  }

  // ── Light variant (default — on white / background surfaces) ────
  Widget _buildLight() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: Color(0xFF1565C0), width: 1.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.search_rounded,
                color: Colors.grey.shade400, size: 20),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.cancel_rounded,
                      color: Colors.grey.shade400, size: 18),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ── Dark / glassmorphic variant (on gradient header) ─────────────
  Widget _buildDark() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.45), width: 1.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.search_rounded,
                color: Colors.white.withOpacity(0.65), size: 20),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.cancel_rounded,
                      color: Colors.white.withOpacity(0.65), size: 18),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : null,
        ),
      ),
    );
  }
}