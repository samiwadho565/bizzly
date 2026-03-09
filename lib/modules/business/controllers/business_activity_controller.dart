import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/services/api_service.dart';

class BusinessActivityController extends GetxController {
  final RxString selectedTab = 'Invoices'.obs;
  final Rxn<BusinessModel> business = Rxn<BusinessModel>();

  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  final RxList<TaskModel> tasks = <TaskModel>[].obs;

  final RxBool isExpensesLoading = false.obs;
  final RxBool isInvoicesLoading = false.obs;
  final RxBool isTasksLoading = false.obs;

  final RxString expensesError = ''.obs;
  final RxString invoicesError = ''.obs;
  final RxString tasksError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is BusinessModel) {
      business.value = args;
    } else if (args is Map) {
      final int? id = _toInt(args['id'] ?? args['businessId'] ?? args['business_id']);
      if (id != null) {
        business.value = BusinessModel(
          id: id,
          businessName: (args['businessName'] ?? args['business_name'] ?? 'Business')
              .toString(),
          businessAddress: '',
          phoneNumber: '',
          currency: '',
          businessImageUrl: args['businessImageUrl']?.toString(),
        );
      }
    }
    fetchBusinessActivity();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
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
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId.toString(),
      if (expenseType != null && expenseType.trim().isNotEmpty)
        'expense_type': expenseType.trim(),
      if (dateFrom != null && dateFrom.trim().isNotEmpty) 'date_from': dateFrom.trim(),
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
      if (priority != null && priority.trim().isNotEmpty) 'priority': priority.trim(),
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

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
