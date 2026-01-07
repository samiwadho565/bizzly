import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomToggleButton extends StatefulWidget {
  final List<String> items;
  final Function(int) onSelected;
  final int initialIndex;

  const CustomToggleButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.initialIndex = 0,
  });

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            bool isSelected = _currentIndex == index;
            bool isLast = index == widget.items.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = index);
                    widget.onSelected(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      // Selected item ka background thoda off-white/grey hai design mein
                      color: isSelected ?  AppColors.lightGrey: Colors.white,
                      borderRadius: _getBorderRadius(index, 12),
                    ),
                    child: Text(
                      widget.items[index],
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Dividers (sirf last item se pehle dikhenge)
                if (!isLast)
                  VerticalDivider(
                    color: Colors.grey.withOpacity(0.3),
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    width: 0,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Corners ko round rakhne ke liye logic
  BorderRadius _getBorderRadius(int index, int total) {
    if (index == 0) {
      return const BorderRadius.horizontal(left: Radius.circular(30));
    } else if (index == total - 1) {
      return const BorderRadius.horizontal(right: Radius.circular(30));
    }
    return BorderRadius.zero;
  }
}