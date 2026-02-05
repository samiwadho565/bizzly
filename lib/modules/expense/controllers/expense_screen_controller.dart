// File: lib/modules/expense/controllers/expense_screen_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseScreenController extends GetxController {
  final RxList<Map<String, String>> expenses = <Map<String, String>>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString selectedCategory = 'All'.obs;
  Rx<DateTime> selectedDate= DateTime.now().obs;

  RxInt index = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Sample data
    expenses.addAll([
      {
        "title": "Lunch with client",
        "category": "Business",
        "amount": "\$24.50",
        "date": "2025-01-05",
        "icon": ""
      },
      {
        "title": "Office Supplies",
        "category": "Business",
        "amount": "\$58.00",
        "date": "2025-01-02",
        "icon": ""
      },
      {
        "title": "Uber ride",
        "category": "Personal",
        "amount": "\$12.30",
        "date": "2025-01-03",
        "icon": ""
      },
    ]);
    // Ensure UI updates when search text changes
    searchController.addListener(() {
      expenses.refresh();
    });
  }

  void setCategory(String c) {
    selectedCategory.value = c;
  }

  List<Map<String, String>> get filteredExpenses {
    final q = searchController.text.toLowerCase().trim();
    return expenses.where((e) {
      final matchesCategory =
          selectedCategory.value == 'All' || e['category'] == selectedCategory.value;
      final combined = (e["title"] ?? '') + ' ' + (e["category"] ?? '') + ' ' + (e["date"] ?? '');
      final matchesQuery = q.isEmpty || combined.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
