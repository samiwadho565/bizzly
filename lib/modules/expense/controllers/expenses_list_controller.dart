import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';

class ExpensesListController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedPaymentMethodId = RxnInt();
  final RxBool isLoading = false.obs;
  final RxBool isDropdownsLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdowns();
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
      queryParameters: <String, dynamic>{
        if (selectedCategoryId.value != null)
          'category_id': selectedCategoryId.value.toString(),
        if (selectedPaymentMethodId.value != null)
          'payment_method_id': selectedPaymentMethodId.value.toString(),
      },
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

  Future<void> fetchDropdowns() async {
    if (isDropdownsLoading.value) return;
    isDropdownsLoading.value = true;
    await Future.wait<void>([
      _fetchCategories(),
      _fetchPaymentMethods(),
    ]);
    isDropdownsLoading.value = false;
  }

  Future<void> _fetchCategories() async {
    final ApiResponse response = await ApiService().get(
      AppUrls.expenseCategories,
      isAuth: true,
    );
    if (!response.success) return;
    final List<dynamic> items = _extractList(response.data);
    categories.assignAll(
      items
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => <String, dynamic>{
              'id': _toInt(e['id']),
              'name': e['name']?.toString() ?? '',
            },
          )
          .where((e) => e['id'] != null && (e['name'] as String).isNotEmpty)
          .toList(),
    );
  }

  Future<void> _fetchPaymentMethods() async {
    final ApiResponse response = await ApiService().get(
      AppUrls.paymentMethods,
      isAuth: true,
    );
    if (!response.success) return;
    final List<dynamic> items = _extractList(response.data);
    paymentMethods.assignAll(
      items
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => <String, dynamic>{
              'id': _toInt(e['id']),
              'name': e['name']?.toString() ?? '',
            },
          )
          .where((e) => e['id'] != null && (e['name'] as String).isNotEmpty)
          .toList(),
    );
  }

  void setCategoryFilterByName(String? name) {
    if (name == null || name.trim().isEmpty) {
      selectedCategoryId.value = null;
      fetchExpenses();
      return;
    }
    for (final Map<String, dynamic> category in categories) {
      if ((category['name']?.toString() ?? '') == name) {
        selectedCategoryId.value = category['id'] as int?;
        fetchExpenses();
        return;
      }
    }
  }

  void setPaymentMethodFilterByName(String? name) {
    if (name == null || name.trim().isEmpty) {
      selectedPaymentMethodId.value = null;
      fetchExpenses();
      return;
    }
    for (final Map<String, dynamic> payment in paymentMethods) {
      if ((payment['name']?.toString() ?? '') == name) {
        selectedPaymentMethodId.value = payment['id'] as int?;
        fetchExpenses();
        return;
      }
    }
  }

  void clearFilters() {
    selectedCategoryId.value = null;
    selectedPaymentMethodId.value = null;
    fetchExpenses();
  }

  String? get selectedCategoryName {
    final int? id = selectedCategoryId.value;
    if (id == null) return null;
    for (final Map<String, dynamic> category in categories) {
      if (category['id'] == id) return category['name']?.toString();
    }
    return null;
  }

  String? get selectedPaymentMethodName {
    final int? id = selectedPaymentMethodId.value;
    if (id == null) return null;
    for (final Map<String, dynamic> payment in paymentMethods) {
      if (payment['id'] == id) return payment['name']?.toString();
    }
    return null;
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) return raw['data'] as List<dynamic>;
    return <dynamic>[];
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
