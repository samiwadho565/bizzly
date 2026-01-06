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

  const CustomSearchDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.height = 32, // 👈 recommended
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

        /// FIELD STYLE
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 8, // 👈 small hint
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppColors.lightGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
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

        /// 🔥 Selected text style
        dropdownBuilder: (context, selectedItem) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              selectedItem ?? hintText,
              maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12, // 👈 KEY FIX
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          );
        },

        /// POPUP
        popupProps: PopupProps.menu(
          showSearchBox: enableSearch,
          fit: FlexFit.loose,
          constraints: const BoxConstraints(maxHeight: 250),
          menuProps: MenuProps(
            backgroundColor: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        /// ICON
        suffixProps: const DropdownSuffixProps(
          dropdownButtonProps: DropdownButtonProps(
            iconClosed: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            iconOpened: Icon(Icons.keyboard_arrow_up_rounded, size: 18),
          ),
        ),
      ),
    );
  }
}
