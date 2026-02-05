import 'package:bizly/components/common/add_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';

Widget addDropdownButton({required String leftText, required String title}) {
  final List<Map<String, dynamic>> items = [
    {
      'text': 'Add New Business',
      'icon': Icons.receipt_long,
      'route': Routes.addNewBusiness, // define this route in your Routes
    },
    {
      'text': 'Add Expense',
      'icon': Icons.money,
      'route': Routes.addExpenseScreen, // route for Add Expense
    },
    {
      'text': 'Create Invoice',
      'icon': Icons.receipt_long,
      'route': Routes.createInvoiceScreen, // define this route in your Routes
    },
    {
      'text': 'Add Team',
      'icon': Icons.work_outline,
      'route': Routes.addEmployeeScreen,// define this route too
    },
    {
      'text': 'Create Task',
      'icon': Icons.task_alt,
      'route':Routes.createTaskScreen // define this route
    },
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
          // Find the item with the selected text
          final selectedItem =
          items.firstWhere((item) => item['text'] == value);
          if (selectedItem['route'] != null) {
            Get.toNamed(selectedItem['route']); // Navigate to the route
          }
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
                  //   color: AppColors.primary, // icon color
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
            children: [
              Icon(Icons.arrow_drop_down, color: Colors.white),
              const SizedBox(width: 5),
              const Text(
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
