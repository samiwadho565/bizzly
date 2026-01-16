// File: lib/widgets/expense_screen_widgets/expense_card.dart
import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/circle_icon_widget.dart';
import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String title;
  final String category;
  final String amount;
  final String date;
  final String? iconPath;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.08),
          //     blurRadius: 6,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: Row(
          children: [

            // CircleIcon(
            //   size: 44,
            //   backgroundColor: AppColors.primary.withOpacity(0.08),
            //   iconPath: iconPath ?? Images.defaultExpenseIcon,
            //
            // ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
