import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> items;
  final Function(int) onTabChanged;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomTabBar({
    super.key,
    required this.items,
    required this.onTabChanged,
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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
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
                  child: Text(
                    widget.items[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
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