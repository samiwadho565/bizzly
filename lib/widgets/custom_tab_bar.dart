import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onSelect;
  final bool isSmall;
  final bool allowUnselectOnReselect; // 👈 NEW

  const CustomTabBar({
    super.key,
    this.isSmall = false,
    this.allowUnselectOnReselect = false, // default OFF
    required this.options,
    required this.selectedOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isSmall ? 30 : 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300,width: 0.5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Row(
          children: options.map((option) {
            bool isSelected = selectedOption == option;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (isSelected && allowUnselectOnReselect) {
                    onSelect(""); // 👈 unselect
                  } else {
                    onSelect(option);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.9)
                        : Colors.transparent,
                    border: Border(
                      right: BorderSide(
                        color: options.last == option
                            ? Colors.transparent
                            : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 14,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                      isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
