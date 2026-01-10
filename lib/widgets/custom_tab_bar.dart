import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> items;
  final Function(int) onTabChanged;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedColor;
  final double fontSize;
  final double? height;
  final double borderRadius;

  const CustomTabBar({
    super.key,
    required this.items,
    required this.onTabChanged,
    this.fontSize = 12,
    this.height = 40,
    this.borderRadius = 25,
    this.selectedTextColor = Colors.white,
    this.selectedColor = AppColors.primary,
    this.unselectedColor = Colors.white,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 🔥 long text safe
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 🔥 width text ke hisaab se
          children: List.generate(widget.items.length, (index) {
            final isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => _currentIndex = index);
                widget.onTabChanged(index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // 🔥 tab width control
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.selectedColor
                      : widget.unselectedColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Text(
                  widget.items[index],
                  maxLines: 1, // ✅ one line only
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? widget.selectedTextColor
                        : Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
