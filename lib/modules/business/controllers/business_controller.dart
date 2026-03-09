import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_utils.dart';

class BusinessDetailController extends GetxController {
  /// Selected Tab
  var selectedTab = 'Invoices'.obs;
  final Rxn<BusinessModel> business = Rxn<BusinessModel>();
  final RxBool detailsExpanded = false.obs;
  final RxBool isDeleting = false.obs;

  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  final RxList<TaskModel> tasks = <TaskModel>[].obs;

  final RxBool isExpensesLoading = false.obs;
  final RxBool isInvoicesLoading = false.obs;
  final RxBool isTasksLoading = false.obs;
  final RxString expensesError = ''.obs;
  final RxString invoicesError = ''.obs;
  final RxString tasksError = ''.obs;

  /// Tab change handler
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is BusinessModel) {
      business.value = args;
    }
  }

  Future<void> ensureBusinessActivityLoaded() async {
    await fetchBusinessActivity();
  }

  Future<void> fetchBusinessActivity() async {
    await Future.wait([
      fetchBusinessInvoices(),
      fetchBusinessExpenses(),
      fetchBusinessTasks(),
    ]);
  }

  Future<void> fetchBusinessExpenses({
    int? categoryId,
    int? paymentMethodId,
    String? expenseType = 'business',
    String? dateFrom,
    String? dateTo,
  }) async {
    final int? businessId = business.value?.id;
    if (businessId == null || isExpensesLoading.value) return;
    isExpensesLoading.value = true;
    expensesError.value = '';

    final Map<String, dynamic> query = <String, dynamic>{
      'business_id': businessId.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (paymentMethodId != null)
        'payment_method_id': paymentMethodId.toString(),
      if (expenseType != null && expenseType.trim().isNotEmpty)
        'expense_type': expenseType.trim(),
      if (dateFrom != null && dateFrom.trim().isNotEmpty)
        'date_from': dateFrom.trim(),
      if (dateTo != null && dateTo.trim().isNotEmpty) 'date_to': dateTo.trim(),
    };

    final ApiResponse response = await ApiService().get(
      AppUrls.createExpense,
      queryParameters: query,
      isAuth: true,
    );

    if (response.success) {
      final List<dynamic> items = _extractList(response.data);
      expenses.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => ExpenseModel.fromJson(e))
            .toList(),
      );
    } else {
      expenses.clear();
      expensesError.value = response.message;
    }

    isExpensesLoading.value = false;
  }

  Future<void> fetchBusinessInvoices() async {
    final int? businessId = business.value?.id;
    if (businessId == null || isInvoicesLoading.value) return;
    isInvoicesLoading.value = true;
    invoicesError.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.createInvoice,
      queryParameters: <String, dynamic>{
        'business_id': businessId.toString(),
      },
      isAuth: true,
    );

    if (response.success) {
      final List<dynamic> items = _extractList(response.data);
      invoices.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => InvoiceModel.fromJson(e))
            .toList(),
      );
    } else {
      invoices.clear();
      invoicesError.value = response.message;
    }

    isInvoicesLoading.value = false;
  }

  Future<void> fetchBusinessTasks({
    String? status,
    String? priority,
    int? assignTo,
    String? dueDateFilter,
  }) async {
    final int? businessId = business.value?.id;
    if (businessId == null || isTasksLoading.value) return;
    isTasksLoading.value = true;
    tasksError.value = '';

    final Map<String, dynamic> query = <String, dynamic>{
      'business_id': businessId.toString(),
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (priority != null && priority.trim().isNotEmpty)
        'priority': priority.trim(),
      if (assignTo != null) 'assign_to': assignTo.toString(),
      if (dueDateFilter != null && dueDateFilter.trim().isNotEmpty)
        'due_date_filter': dueDateFilter.trim(),
    };

    final ApiResponse response = await ApiService().get(
      AppUrls.getAllTasks,
      queryParameters: query,
      isAuth: true,
    );

    if (response.success) {
      final List<dynamic> items = _extractList(response.data);
      tasks.assignAll(
        items
            .where((e) => e is Map)
            .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } else {
      tasks.clear();
      tasksError.value = response.message;
    }

    isTasksLoading.value = false;
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) {
      return raw['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  void toggleDetails() {
    detailsExpanded.value = !detailsExpanded.value;
  }

  void applyUpdatedBusiness(BusinessModel updated) {
    business.value = updated;
    _syncHomeBusiness(updated);
  }

  Future<void> editBusiness() async {
    final BusinessModel? current = business.value;
    if (current == null) {
      await Get.toNamed(Routes.addNewBusiness);
      return;
    }

    final dynamic updated = await Get.toNamed(
      Routes.addNewBusiness,
      arguments: current,
    );
    if (updated is BusinessModel) {
      applyUpdatedBusiness(updated);
    }
  }

  Future<void> deleteBusiness() async {
    final int? id = business.value?.id;
    if (id == null || isDeleting.value) return;
    isDeleting.value = true;

    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.updateBusiness}/$id',
      isAuth: true,
    );
    AppDialogs.closeDialog();
    isDeleting.value = false;

    if (response.success) {
      _removeFromHome(id);
      Get.back();
      Future.microtask(() {
        AppUtils.showAppSnackbar(
          "Success",
          "Business deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          type: AppSnackType.success,
        );
      });
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  void _syncHomeBusiness(BusinessModel updated) {
    if (!Get.isRegistered<HomeScreenController>()) return;
    final HomeScreenController home = Get.find<HomeScreenController>();
    final int index = home.businesses.indexWhere((b) => b.id == updated.id);
    if (index >= 0) {
      home.businesses[index] = updated;
    }
  }

  void _removeFromHome(int id) {
    if (!Get.isRegistered<HomeScreenController>()) return;
    final HomeScreenController home = Get.find<HomeScreenController>();
    home.businesses.removeWhere((b) => b.id == id);
  }
}
