// File: lib/modules/expense/controllers/expense_screen_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:bizly/utils/form_validations.dart';

class AddExpenseScreenController extends GetxController {
  static const String forcedExpenseType = 'business';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> titleFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> amountFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> projectNameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> referenceNumberFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> taxAmountFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> notesFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey categoryFieldKey = GlobalKey();
  final GlobalKey expenseTypeFieldKey = GlobalKey();
  final GlobalKey expenseDateFieldKey = GlobalKey();
  final GlobalKey paymentMethodFieldKey = GlobalKey();
  final GlobalKey businessFieldKey = GlobalKey();
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
  final RxBool isBusinessLocked = false.obs;
  final RxString lockedBusinessName = ''.obs;
  final RxBool isVendorLocked = false.obs;
  final RxString lockedVendorName = ''.obs;

  static const int expenseTitleMax = 80;
  static const int expenseAmountMax = 15;
  static const int expenseProjectNameMax = 80;
  static const int expenseReferenceMax = 40;
  static const int expenseTaxAmountMax = 15;
  static const int expenseNotesMax = 300;

  ExpenseModel expenseModel = ExpenseModel();

  List<TextInputFormatter> get expenseTitleInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(expenseTitleMax),
      ];

  List<TextInputFormatter> get expenseAmountInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(expenseAmountMax),
      ];

  List<TextInputFormatter> get expenseProjectNameInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(expenseProjectNameMax),
      ];

  List<TextInputFormatter> get expenseReferenceInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(expenseReferenceMax),
      ];

  List<TextInputFormatter> get expenseTaxAmountInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(expenseTaxAmountMax),
      ];

  List<TextInputFormatter> get expenseNotesInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(expenseNotesMax),
      ];

  FormFieldValidator<String> get titleValidator => (String? value) {
        return FormValidations.validateRequiredMinMax(
          value ?? '',
          fieldName: "Title",
          min: 2,
          max: expenseTitleMax,
        );
      };

  FormFieldValidator<String> get amountValidator => (String? value) {
        return FormValidations.validateRequiredNumber(
          value ?? '',
          fieldName: "Amount",
        );
      };

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
    isBusinessLocked.value = false;
    lockedBusinessName.value = '';
    isVendorLocked.value = false;
    lockedVendorName.value = '';
    resetFormState();
    final dynamic args = Get.arguments;
    if (args is ExpenseModel) {
      loadForEditFromModel(args);
    } else {
      _applyBusinessSelectionFromArgs(args);
      _applyVendorSelectionFromArgs(args);
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
    final int? lockedBusinessId =
        isBusinessLocked.value ? selectedBusinessId.value : null;
    final int? lockedVendorId =
        isVendorLocked.value ? selectedVendorId.value : null;
    expenseType.value = forcedExpenseType;
    hasSelectedExpenseType.value = true;
    hasSelectedDate.value = false;
    selectedDate.value = DateTime.now();
    selectedCategoryId.value = null;
    selectedPaymentMethodId.value = null;
    selectedCustomerId.value = null;
    selectedVendorId.value = lockedVendorId;
    selectedBusinessId.value = lockedBusinessId;
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

  void _applyBusinessSelectionFromArgs(dynamic args) {
    int? businessId;
    String? businessName;
    bool lockBusiness = true;

    if (args is BusinessModel) {
      businessId = args.id;
      businessName = args.businessName;
    } else if (args is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(args as Map);
      businessId = _asInt(map['businessId'] ?? map['business_id']);
      businessName = map['businessName']?.toString();
      if (businessId == null && map['business'] is BusinessModel) {
        final BusinessModel business = map['business'] as BusinessModel;
        businessId = business.id;
        businessName ??= business.businessName;
      }
      if (map['lockBusiness'] is bool) {
        lockBusiness = map['lockBusiness'] as bool;
      }
    }

    if (businessName != null && businessName.trim().isNotEmpty) {
      lockedBusinessName.value = businessName.trim();
    }
    if (businessId != null) {
      selectedBusinessId.value = businessId;
      isBusinessLocked.value = lockBusiness;
      if (lockedBusinessName.value.isEmpty) {
        lockedBusinessName.value = _nameByIdFromModels(
              businesses
                  .map((e) => {'id': e.id, 'name': e.businessName})
                  .toList(),
              businessId,
            ) ??
            '';
      }
    }
  }

  void _applyVendorSelectionFromArgs(dynamic args) {
    int? vendorId;
    String? vendorName;
    bool lockVendor = true;

    if (args is VendorModel) {
      vendorId = args.id;
      vendorName = args.vendorName;
    } else if (args is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(args as Map);
      vendorId = _asInt(map['vendorId'] ?? map['vendor_id']);
      vendorName = map['vendorName']?.toString();
      if (vendorId == null && map['vendor'] is VendorModel) {
        final VendorModel vendor = map['vendor'] as VendorModel;
        vendorId = vendor.id;
        vendorName ??= vendor.vendorName;
      }
      if (map['lockVendor'] is bool) {
        lockVendor = map['lockVendor'] as bool;
      }
    }

    if (vendorName != null && vendorName.trim().isNotEmpty) {
      lockedVendorName.value = vendorName.trim();
    }
    if (vendorId != null) {
      selectedVendorId.value = vendorId;
      isVendorLocked.value = lockVendor;
      if (lockedVendorName.value.isEmpty) {
        lockedVendorName.value = _nameByIdFromModels(
              vendors.map((e) => {'id': e.id, 'name': e.vendorName}).toList(),
              vendorId,
            ) ??
            '';
      }
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  void setCategory(String c) {
    selectedCategory.value = c;
  }

  Future<void> fetchDropdowns() async {
    if (isDropdownsLoading.value) return;
    isDropdownsLoading.value = true;
    try {
      final List<Future<void>> requests = <Future<void>>[
        fetchCategories(),
        fetchPaymentMethods(),
        fetchCustomers(),
        fetchVendors(),
      ];
      if (!isBusinessLocked.value) {
        requests.add(fetchBusinesses());
      }
      await Future.wait(requests);
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
    final List<String> missing = <String>[];
    if (selectedCategoryId.value == null) missing.add('Category');
    if (!hasSelectedDate.value) missing.add('Expense Date');
    if (selectedPaymentMethodId.value == null) missing.add('Payment Method');
    if (selectedBusinessId.value == null) missing.add('Business');

    if (missing.isNotEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Required Fields",
        message: 'Please provide: ${missing.join(', ')}',
        actions: [AppDialogAction(label: "Ok")],
      );
      return false;
    }
    return true;
  }

  Future<void> submitExpenseFromForm() async {
    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final bool formOk = formKey.currentState?.validate() ?? false;
    if (!formOk) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstTextError();
      return;
    }
    if (!validateRequiredSelections()) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstSelectionError();
      return;
    }
    await createExpense();
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
      expenseType: forcedExpenseType,
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



    final bool isEdit = editingExpenseId.value != null;
    final int? editedId = editingExpenseId.value;
    final ApiResponse response = isEdit
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
    if (response.success && response.data is Map) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(response.data as Map);
      final dynamic nested = map['data'];
      if (nested is Map && nested['receipt'] != null) {
        expenseModel.receiptUrl = nested['receipt'].toString();
      } else if (map['receipt'] != null) {
        expenseModel.receiptUrl = map['receipt'].toString();
      }
    }
    if (response.success) {
      ExpenseModel? doneResult;
      if (isEdit) {
        if (Get.isRegistered<ExpensesListController>()) {
          await Get.find<ExpensesListController>().fetchExpenses();
        }
        doneResult = editedId == null ? null : await _fetchExpenseById(editedId);
      }

      isSubmitting.value = false;
      resetFormState();

      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: isEdit ? "Expense Updated!" : "Expense Added!",
        message: isEdit
            ? "Expense updated successfully."
            : "Expense created successfully.",
        actions: [
          if (!isEdit)
            AppDialogAction(
              label: "New Expense",
              onPressed: () {

              },
            ),
          AppDialogAction(
            label: "Done",
            onPressed: () {
              if (isEdit) {
                Get.back(result: doneResult ?? expenseModel);
                return;
              }
              if (Get.isRegistered<ExpensesListController>()) {
                Get.find<ExpensesListController>().fetchExpenses();
              }
              Get.back();
            },
          ),
        ],
      );
    } else {
      isSubmitting.value = false;
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  Future<void> _scrollToFirstTextError() async {
    final List<GlobalKey<FormFieldState<String>>> keysInOrder =
        <GlobalKey<FormFieldState<String>>>[
      titleFieldKey,
      amountFieldKey,
      projectNameFieldKey,
      referenceNumberFieldKey,
      taxAmountFieldKey,
      notesFieldKey,
    ];

    for (final GlobalKey<FormFieldState<String>> key in keysInOrder) {
      final FormFieldState<String>? state = key.currentState;
      final BuildContext? context = key.currentContext;
      if (state?.hasError == true && context != null) {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
        return;
      }
    }
  }

  Future<void> _scrollToFirstSelectionError() async {
    final List<({bool invalid, GlobalKey key})> checks = <({bool invalid, GlobalKey key})>[
      (invalid: selectedCategoryId.value == null, key: categoryFieldKey),
      (invalid: !hasSelectedExpenseType.value, key: expenseTypeFieldKey),
      (invalid: !hasSelectedDate.value, key: expenseDateFieldKey),
      (invalid: selectedPaymentMethodId.value == null, key: paymentMethodFieldKey),
      (invalid: selectedBusinessId.value == null, key: businessFieldKey),
    ];

    for (final ({bool invalid, GlobalKey key}) check in checks) {
      if (!check.invalid) continue;
      final BuildContext? context = check.key.currentContext;
      if (context == null) continue;
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }
  }

  Future<ExpenseModel?> _fetchExpenseById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.createExpense}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    return ExpenseModel.fromJson(payload);
  }

  void loadForEditFromModel(ExpenseModel model) {
    editingExpenseId.value = model.id;
    editingExpenseId.refresh();
    titleController.text = model.title ?? '';
    amountController.text = model.amount?.toString() ?? '';
    referenceNumberController.text = model.referenceNumber ?? '';
    taxAmountController.text = model.taxAmount?.toString() ?? '';
    projectNameController.text = model.projectName ?? '';
    notesController.text = model.notes ?? '';
    expenseType.value = forcedExpenseType;
    hasSelectedExpenseType.value = true;
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
