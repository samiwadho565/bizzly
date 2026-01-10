import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class ProjectDetailCard extends StatelessWidget {
  final String title;
  final String ownerName;
  final String dateRange;
  final String status;
  final Color statusColor;


  ProjectDetailCard ({
    super.key,
    required this.title,
    required this.ownerName,
    required this.dateRange,
    this.status = "Active",
    this.statusColor =AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.13),
          //   blurRadius: 7,
          //   offset: const Offset(0, 4),
          // ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Left Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ownerName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 15,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Status Chip
          Container(
            padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: status=="Active"?AppColors.active.withOpacity(0.7):status=="Low"?AppColors.priorityLow.withOpacity(0.7):status=="High"?AppColors.priorityHigh.withOpacity(0.7):AppColors.statusCompleted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
