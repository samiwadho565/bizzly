import 'dart:ui';

import 'package:bizly/assets/images.dart';
import 'package:flutter/material.dart';

import 'package:bizly/utils/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double navBarHeight = 84;
    final BorderRadius borderRadius = BorderRadius.circular(28);
    final List<_NavItemData> items = <_NavItemData>[
      const _NavItemData(
        label: 'Home',
        icon: AppImages.home,
        activeIcon: AppImages.homeFill,
      ),
      const _NavItemData(
        label: 'Expenses',
        icon: AppImages.expense,
        activeIcon: AppImages.expenseFill,
      ),
      const _NavItemData(
        label: 'Invoices',
        icon: AppImages.bill,
        activeIcon: AppImages.billFill,
      ),
      const _NavItemData(
        label: 'Tasks',
        icon: AppImages.task,
        activeIcon: AppImages.taskFill,
      ),
      const _NavItemData(
        label: 'Settings',
        icon: AppImages.settings,
        activeIcon: AppImages.settings,
      ),
    ];

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: navBarHeight,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: borderRadius,
                border: Border.all(
                  color: AppColors.primaryDense.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDense.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.75),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Row(
                  children: List<Widget>.generate(
                    items.length,
                    (int index) => Expanded(
                      child: _NavBarItem(
                        item: items[index],
                        isSelected: currentIndex == index,
                        onTap: () => onTap(index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        isSelected ? Colors.white : AppColors.primaryDense.withOpacity(0.72);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: isSelected
            ? const LinearGradient(
                colors: <Color>[
                  AppColors.primary,
                  AppColors.primaryDense,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.transparent,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    isSelected ? item.activeIcon : item.icon,
                    height: 18,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: iconColor,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String icon;
  final String activeIcon;
}
