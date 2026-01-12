import 'package:bizly/widgets/add_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

Widget addDropdownButton({required String leftText,required String title}) {

  final List<Map<String, dynamic>> items = [
    {'text': 'Add Expense', 'icon': Icons.money},
    {'text': 'Create Invoice', 'icon': Icons.receipt_long},
    {'text': 'Add New Business', 'icon': Icons.business},
    {'text': 'Add Project', 'icon': Icons.work_outline},
    {'text': 'Create Task', 'icon': Icons.task_alt},
  ];

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Left side text
      Text(
        leftText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),

      // Right side dropdown button
      PopupMenuButton<String>(
        onSelected: (value) {
          print("Selected: $value");

        },
        color: Colors.white,
        itemBuilder: (BuildContext context) {
          return items.map((item) {
            return PopupMenuItem<String>(
              value: item['text'],
              child: Row(
                children: [
                  // Icon(
                  //   item['icon'],
                  //   color: AppColors.primaryLightTeal, // icon color
                  // ),
                  const SizedBox(width: 10),
                  Text(item['text']),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: const [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 5),
              Text(
                "Add",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
