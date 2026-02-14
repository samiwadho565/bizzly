import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';

class ExpensesListController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
    searchController.addListener(() {
      expenses.refresh();
    });
  }

  List<ExpenseModel> get filteredExpenses {
    final String q = searchController.text.toLowerCase().trim();
    if (q.isEmpty) return expenses;
    return expenses.where((e) {
      final combined =
          '${e.title ?? ''} ${e.categoryName ?? ''} ${e.expenseDate ?? ''}'
              .toLowerCase();
      return combined.contains(q);
    }).toList();
  }

  Future<void> fetchExpenses() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.createExpense,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      expenses.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => ExpenseModel.fromJson(e))
            .toList(),
      );
    } else {
      expenses.clear();
      error.value = response.message;
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
