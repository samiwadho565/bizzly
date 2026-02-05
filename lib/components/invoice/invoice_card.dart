import 'package:flutter/material.dart';

import 'package:bizly/utils/app_colors.dart';

class InvoiceCard extends StatelessWidget {
  final String clientName;
  final String businessName;
  final String itemName;
  final String amount;
  final String status;

  const InvoiceCard({
    super.key,
    required this.clientName,
    required this.businessName,
    required this.itemName,
    required this.amount,
    required this.status,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case "paid":
        return  AppColors.statusCancelled;// green
      case "sent":
        return  AppColors.statusSent; // blue
      case "pending":
        return  AppColors.statusPending;// yellow
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          width: 0.6,
          color: Colors.grey.shade300
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                clientName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$status",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Business name: $businessName",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            "Item name: $itemName",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "Amount: $amount",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
