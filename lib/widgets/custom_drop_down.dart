import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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

  const CustomSearchDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.selectedItem,
    required this.onChanged,
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
    return SizedBox(
      width: width,
      height: height,
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
            fillColor: AppColors.lightGrey.withOpacity(0.5),
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
          return Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItem ?? hintText,
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
            return Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 12),
              color: isSelected
                  ? AppColors.primaryTeal.withOpacity(0.2)
                  : Colors.transparent,
              child: Text(
                item,
                style: popupTextStyle ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
              ),
            );
          },
          fit: FlexFit.loose,
          constraints: const BoxConstraints(maxHeight: 250),
          menuProps: MenuProps(
            backgroundColor: AppColors.lightGrey,
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
