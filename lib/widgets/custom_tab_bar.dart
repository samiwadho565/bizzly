import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> items;
  final Function(int) onTabChanged;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedColor;
final double fontSize;
  final double? width;
  final double? height;
  final double borderRadius;

  const CustomTabBar({
    super.key,
    required this.items,
    this.fontSize = 14,
    this.width,
    this.height,
    this.borderRadius =25,
    required this.onTabChanged,
    this.selectedTextColor = Colors.white,
    this.selectedColor = const Color(0xFF025959), // Default Teal
    this.unselectedColor = Colors.white,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBar();
}

class _CustomTabBar extends State<CustomTabBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:widget.height?? 50,
      width: widget.width??null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Row(
          children: List.generate(widget.items.length, (index) {
            bool isSelected = _currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = index);
                  widget.onTabChanged(index);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? widget.selectedColor : widget.unselectedColor,
                    // Items ke beech mein divider
                    border: index != widget.items.length - 1 && !isSelected && _currentIndex != index + 1
                        ? Border(right: BorderSide(color: Colors.grey.shade300, width: 1))
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.items[index],
                      style: TextStyle(
                        color: isSelected ? widget.selectedTextColor : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        fontSize: widget.fontSize,
                      ),
                    ),
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