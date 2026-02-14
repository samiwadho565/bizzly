import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';

class CustomSearchDropdown extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  final double height;
  final double width;
  final bool enableSearch;
  final double? iconSize;
  final double? horizontalPadding;
  final double? verticalPadding;
  final TextStyle? textStyle;
  final TextStyle? popupTextStyle;
  final String? displayValue;

  const CustomSearchDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.displayValue,
    this.height = 32,
    this.iconSize,
    this.horizontalPadding,
    this.verticalPadding,
    this.textStyle,
    this.popupTextStyle,
    this.width = double.infinity,
    this.enableSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.1), // Halka shadow
      //       blurRadius: 10,
      //       offset: const Offset(-4, 4), // Shadow position
      //     ),
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.02), // Halka shadow
      //       blurRadius: 10,
      //       offset: const Offset(4, 0), // Shadow position
      //     ),
      //   ],
      // ),

      child: DropdownSearch<String>(
        items: (filter, infiniteScrollProps) => items,
        selectedItem: selectedItem,
        onChanged: onChanged,

        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            // hintText: hintText,
            hintStyle: textStyle ??
                const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
            filled: true,
            fillColor: AppColors.textField,
            contentPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 8,
              vertical: (height - 20) / 2,
            ),
            constraints: BoxConstraints(
              minHeight: height,
              maxHeight: height,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        dropdownBuilder: (context, selectedItem) {
          final String? resolvedDisplay = displayValue ?? selectedItem;
          return Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    (resolvedDisplay != null && resolvedDisplay.isNotEmpty)
                        ? resolvedDisplay
                        : hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle ??
                        const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: iconSize ?? 18,
                  ),
                ),
              ],
            ),
          );
        },

        popupProps: PopupProps.menu(
          showSearchBox: enableSearch,
          itemBuilder: (context, item, isDisabled, isSelected) {
            print("item : $item");
            return Container(
              decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : item == "Add New Category" ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10))
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 12),

              child: Text(
                item,
                textAlign: item == "Add New Category"  ?TextAlign.center : TextAlign.left,
                style: popupTextStyle ??
                     TextStyle(
                      fontSize: 14,
                      fontWeight: item == "Add New Category" ? FontWeight.w600 : FontWeight.w500,
                      color: item == "Add New Category" ? Colors.white : Colors.black,
                    ),
              ),
            );
          },
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          fit: FlexFit.loose,
          constraints: const BoxConstraints(maxHeight: 250),
          menuProps: MenuProps(
            backgroundColor: AppColors.background,
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        suffixProps: const DropdownSuffixProps(
          dropdownButtonProps: DropdownButtonProps(
            isVisible: false,
          ),
        ),
      ),
    );
  }
}
