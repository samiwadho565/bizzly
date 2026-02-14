// File: lib/modules/expense/controllers/expense_screen_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/expense/controllers/expenses_list_controller.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';
import 'package:bizly/utils/date_formats.dart';

class AddExpenseScreenController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxList<Map<String, String>> expenses = <Map<String, String>>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString selectedCategory = 'All'.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool hasSelectedDate = false.obs;

  RxInt index = 0.obs;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceNumberController = TextEditingController();
  final TextEditingController taxAmountController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final RxString expenseType = ''.obs;
  final RxBool hasSelectedExpenseType = false.obs;
  final RxBool isRecurringMonthly = false.obs;
  final Rxn<File> receiptFile = Rxn<File>();
  final ImagePicker _picker = ImagePicker();
  final RxBool isSubmitting = false.obs;
  final RxBool didResetForm = false.obs;
  final RxBool isDropdownsLoading = false.obs;
  final RxnInt editingExpenseId = RxnInt();
  final RxString receiptUrl = ''.obs;
  final RxBool receiptCleared = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isCategoryCreating = false.obs;

  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[].obs;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxList<VendorModel> vendors = <VendorModel>[].obs;
  final RxList<BusinessModel> businesses = <BusinessModel>[].obs;

  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedPaymentMethodId = RxnInt();
  final RxnInt selectedCustomerId = RxnInt();
  final RxnInt selectedVendorId = RxnInt();
  final RxnInt selectedBusinessId = RxnInt();

  ExpenseModel expenseModel = ExpenseModel();

  Future<void> pickReceipt() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      receiptFile.value = File(picked.path);
      receiptCleared.value = false;
      receiptUrl.value = '';
    }
  }

  void clearReceipt() {
    receiptFile.value = null;
    receiptUrl.value = '';
    receiptCleared.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    resetFormState();
    final dynamic args = Get.arguments;
    if (args is ExpenseModel) {
      loadForEditFromModel(args);
    }
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

    fetchDropdowns();
  }

  void resetFormState() {
    expenseType.value = '';
    hasSelectedExpenseType.value = false;
    hasSelectedDate.value = false;
    selectedDate.value = DateTime.now();
    selectedCategoryId.value = null;
    selectedPaymentMethodId.value = null;
    selectedCustomerId.value = null;
    selectedVendorId.value = null;
    selectedBusinessId.value = null;
    titleController.clear();
    amountController.clear();
    referenceNumberController.clear();
    taxAmountController.clear();
    projectNameController.clear();
    notesController.clear();
    receiptFile.value = null;
    receiptUrl.value = '';
    receiptCleared.value = false;
    isRecurringMonthly.value = false;
    editingExpenseId.value = null;
    didResetForm.value = true;
  }

  void setCategory(String c) {
    selectedCategory.value = c;
  }

  Future<void> fetchDropdowns() async {
    if (isDropdownsLoading.value) return;
    isDropdownsLoading.value = true;
    try {
      await Future.wait([
        fetchCategories(),
        fetchPaymentMethods(),
        fetchCustomers(),
        fetchVendors(),
        fetchBusinesses(),
      ]);
    } finally {
      isDropdownsLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    if (isCategoriesLoading.value) return;
    isCategoriesLoading.value = true;
    try {
      final ApiResponse response = await ApiService().get(
        AppUrls.expenseCategories,
        isAuth: true,
      );
      if (response.success) {
        final dynamic raw = response.data;
        final List<dynamic> items = raw is List
            ? raw
            : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
        categories.assignAll(items.whereType<Map>().map((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList());
      } else {
        categories.clear();
      }
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<bool> createCategory(String name) async {
    if (isCategoryCreating.value) return false;
    isCategoryCreating.value = true;
    try {
      final ApiResponse response = await ApiService().post(
        AppUrls.createCategory,
        data: {'name': name.trim()},
        isAuth: true,
      );
      if (response.success) {
        final dynamic raw = response.data;
        final Map<String, dynamic>? payload = raw is Map
            ? Map<String, dynamic>.from(raw)
            : null;
        final Map<String, dynamic>? data = payload != null && payload['data'] is Map
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : payload;
        if (data != null) {
          final int? id = data['id'] is int
              ? data['id'] as int
              : int.tryParse(data['id']?.toString() ?? '');
          final String? newName = data['name']?.toString();
          if (id != null && newName != null && newName.isNotEmpty) {
            selectedCategoryId.value = id;
          }
        }
        await fetchCategories();
        return true;
      }
      return false;
    } finally {
      isCategoryCreating.value = false;
    }
  }

  Future<void> fetchPaymentMethods() async {
    final ApiResponse response = await ApiService().get(
      AppUrls.paymentMethods,
      isAuth: true,
    );
    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      paymentMethods.assignAll(items.whereType<Map>().map((e) {
        return Map<String, dynamic>.from(e as Map);
      }).toList());
    } else {
      paymentMethods.clear();
    }
  }

  Future<void> fetchCustomers() async {
    final ApiResponse response = await ApiService().get(
      AppUrls.createCustomer,
      isAuth: true,
    );
    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      customers.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => CustomerModel.fromJson(e))
            .toList(),
      );
    } else {
      customers.clear();
    }
  }

  Future<void> fetchVendors() async {
    final ApiResponse response = await ApiService().get(
      AppUrls.createVendor,
      isAuth: true,
    );
    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      vendors.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => VendorModel.fromJson(e))
            .toList(),
      );
    } else {
      vendors.clear();
    }
  }

  Future<void> fetchBusinesses() async {
    final ApiResponse response = await ApiService().get(
      AppUrls.getAllBusinesses,
      isAuth: true,
    );
    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      businesses.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => BusinessModel.fromJson(e))
            .toList(),
      );
    } else {
      businesses.clear();
    }
  }

  bool validateRequiredSelections() {
    String error = "";
    if (selectedCategoryId.value == null) { error = "Please select Category"; }
    if (!hasSelectedExpenseType.value) { error =  "Please select Expense Type"; }
    if (!hasSelectedDate.value) { error =   "Please select Expense Date";}
    if (selectedPaymentMethodId.value == null) { error =   "Please select Payment Method"; }
    if (selectedBusinessId.value == null) { error =  "Please select Business"; }

    if(error.isNotEmpty){
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Required Fields",
        message: error,
        actions: [AppDialogAction(label: "Ok")],
      );
      return false;
    }
    error = "";
    return true;
  }

  Future<void> createExpense() async {
    if (isSubmitting.value) return;
    final bool formOk = formKey.currentState?.validate() ?? false;
    if (!formOk) return;
    if (!validateRequiredSelections()) return;

    isSubmitting.value = true;
    //AppDialogs.showLoading(message: "Saving...");

    final String dateStr = DateFormats.yyyyMmDd(selectedDate.value);

    final ExpenseModel model = ExpenseModel(
      id: editingExpenseId.value,
      categoryId: selectedCategoryId.value,
      categoryName: _nameById(categories, selectedCategoryId.value, 'name'),
      title: titleController.text.trim(),
      amount: amountController.text.trim(),
      expenseDate: dateStr,
      paymentMethodId: selectedPaymentMethodId.value,
      paymentMethodName:
          _nameById(paymentMethods, selectedPaymentMethodId.value, 'name'),
      expenseType: expenseType.value,
      isRecurringMonthly: isRecurringMonthly.value,
      referenceNumber: referenceNumberController.text.trim(),
      taxAmount: taxAmountController.text.trim(),
      projectName: projectNameController.text.trim(),
      customerId: selectedCustomerId.value,
      customerName: _nameByIdFromModels(
        customers.map((e) => {'id': e.id, 'name': e.customerName}).toList(),
        selectedCustomerId.value,
      ),
      vendorId: selectedVendorId.value,
      vendorName: _nameByIdFromModels(
        vendors.map((e) => {'id': e.id, 'name': e.vendorName}).toList(),
        selectedVendorId.value,
      ),
      notes: notesController.text.trim(),
      businessId: selectedBusinessId.value,
      businessName: _nameByIdFromModels(
        businesses.map((e) => {'id': e.id, 'name': e.businessName}).toList(),
        selectedBusinessId.value,
      ),
      receiptFile: receiptFile.value,
      receiptUrl: receiptUrl.value.isNotEmpty ? receiptUrl.value : null,
      receiptCleared: receiptCleared.value,
    );



    final ApiResponse response = editingExpenseId.value != null
        ? await ApiService().postMultipart(
            '${AppUrls.updateExpense}/${editingExpenseId.value}',
            data: model.toJson(),
            isAuth: true,
          )
        : await ApiService().postMultipart(
            AppUrls.createExpense,
            data: model.toJson(),
            isAuth: true,
          );

    expenseModel = model;

    expenseModel.receiptUrl = response.data['receipt'] ?? "";
    print("response.data : ${response.data}");
    //AppDialogs.closeDialog();
    isSubmitting.value = false;

    if (response.success) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: editingExpenseId.value != null ? "Expense Updated!" : "Expense Added!",
        message: editingExpenseId.value != null
            ? "Expense updated successfully."
            : "Expense created successfully.",
        actions: [
          if (editingExpenseId.value == null)
            AppDialogAction(
              label: "New Expense",
              onPressed: () {
                resetFormState();
              },
            ),
          AppDialogAction(
            label: "Done",
            onPressed: () {
              if (Get.isRegistered<ExpensesListController>()) {
                Get.find<ExpensesListController>().fetchExpenses();
              }
              if (editingExpenseId.value != null) {
                Get.back(result: expenseModel);
                return;
              }
              Get.back();
            },
          ),
        ],
      );
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  void loadForEditFromModel(ExpenseModel model) {
    editingExpenseId.value = model.id;
    editingExpenseId.refresh();
    print("editingExpenseId.value : ${editingExpenseId.value}");
    titleController.text = model.title ?? '';
    amountController.text = model.amount?.toString() ?? '';
    referenceNumberController.text = model.referenceNumber ?? '';
    taxAmountController.text = model.taxAmount?.toString() ?? '';
    projectNameController.text = model.projectName ?? '';
    notesController.text = model.notes ?? '';
    expenseType.value = model.expenseType ?? '';
    hasSelectedExpenseType.value = expenseType.value.isNotEmpty;
    final DateTime? date = DateTime.tryParse(model.expenseDate ?? '');
    if (date != null) {
      selectedDate.value = date;
      hasSelectedDate.value = true;
    }
    selectedCategoryId.value = model.categoryId;
    selectedPaymentMethodId.value = model.paymentMethodId;
    selectedCustomerId.value = model.customerId;
    selectedVendorId.value = model.vendorId;
    selectedBusinessId.value = model.businessId;
    isRecurringMonthly.value = model.isRecurringMonthly == true;
    receiptUrl.value = model.receiptUrl ?? '';
    receiptCleared.value = false;
    receiptFile.value = null;
    expenseModel = model;
    print("model : ${model.toJson()}");
    print("");
    print("");
    print("expenseModel : ${expenseModel.toJson()}");
  }

  String? _nameById(
    List<Map<String, dynamic>> items,
    int? id,
    String key,
  ) {
    if (id == null) return null;
    for (final item in items) {
      if (item['id'] == id) {
        return item[key]?.toString();
      }
    }
    return null;
  }

  String? _nameByIdFromModels(
    List<Map<String, dynamic>> items,
    int? id,
  ) {
    if (id == null) return null;
    for (final item in items) {
      if (item['id'] == id) {
        return item['name']?.toString();
      }
    }
    return null;
  }


  List<Map<String, String>> get filteredExpenses {
    final q = searchController.text.toLowerCase().trim();
    return expenses.where((e) {
      final matchesCategory =
          selectedCategory.value == 'All' || e['category'] == selectedCategory.value;
      final combined = '${e["title"] ?? ''} ${e["category"] ?? ''} ${e["date"] ?? ''}';
      final matchesQuery = q.isEmpty || combined.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    titleController.dispose();
    amountController.dispose();
    referenceNumberController.dispose();
    taxAmountController.dispose();
    projectNameController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
