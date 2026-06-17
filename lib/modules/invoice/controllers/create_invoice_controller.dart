import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:bizly/utils/date_formats.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/modules/invoice/models/invoice_item_model.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/form_validations.dart';

class CreateInvoiceController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> partialPaidFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> notesFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey customerFieldKey = GlobalKey();
  final GlobalKey invoiceDateFieldKey = GlobalKey();
  final GlobalKey statusFieldKey = GlobalKey();
  final GlobalKey businessFieldKey = GlobalKey();
  final GlobalKey paymentMethodFieldKey = GlobalKey();

  final TextEditingController notesController = TextEditingController();
  final TextEditingController partialPaidAmountController = TextEditingController();
  final Rxn<DateTime> invoiceDate = Rxn<DateTime>();
  final RxString status = 'unpaid'.obs;
  final RxBool taxEnabled = false.obs;

  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxList<BusinessModel> businesses = <BusinessModel>[].obs;
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[].obs;

  final RxnInt selectedCustomerId = RxnInt();
  final RxnInt selectedBusinessId = RxnInt();
  final RxnInt selectedPaymentMethodId = RxnInt();
  final RxBool isCustomerLocked = false.obs;
  final RxString lockedCustomerName = ''.obs;
  final RxBool isBusinessLocked = false.obs;
  final RxString lockedBusinessName = ''.obs;
  final Rxn<BusinessModel> selectedBusinessDetails = Rxn<BusinessModel>();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool showSelectionErrors = false.obs;
  final RxnInt editingInvoiceId = RxnInt();
  final Rxn<InvoiceModel> editingInvoice = Rxn<InvoiceModel>();

  final RxList<InvoiceItemModel> items = <InvoiceItemModel>[].obs;

  static const int invoiceNotesMax = 300;
  static const int partialPaidAmountMax = 15;
  static const int itemNameMax = 80;
  static const int itemQtyMax = 7;
  static const int itemUnitPriceMax = 15;

  bool get isPaidStatus => status.value == 'paid';
  bool get isPartialPaidStatus =>
      _normalizeStatusValue(status.value) == 'partially-paid';
  double get invoiceItemsTotal => _calculateItemsTotal(items);
  double get invoiceSubtotal => invoiceItemsTotal;
  double get invoiceTaxPercent {
    final double? fromDetail =
        _toDouble(selectedBusinessDetails.value?.invoiceTaxPercentage);
    if (fromDetail != null) return fromDetail;
    final int? id = selectedBusinessId.value;
    if (id == null) return 0;
    for (final BusinessModel business in businesses) {
      if (business.id == id) {
        return _toDouble(business.invoiceTaxPercentage) ?? 0;
      }
    }
    return 0;
  }
  double get invoiceTaxAmount {
    if (!taxEnabled.value) return 0;
    if (invoiceTaxPercent <= 0) return 0;
    return (invoiceSubtotal * invoiceTaxPercent) / 100;
  }
  double get invoiceGrandTotal => invoiceSubtotal + invoiceTaxAmount;
  String get invoiceCurrencyCode {
    final String fromDetails =
        (selectedBusinessDetails.value?.currency ?? '').trim();
    if (fromDetails.isNotEmpty) return fromDetails;
    final int? id = selectedBusinessId.value;
    if (id != null) {
      for (final BusinessModel business in businesses) {
        if (business.id == id) {
          final String code = business.currency.trim();
          if (code.isNotEmpty) return code;
        }
      }
    }
    return 'PKR';
  }

  List<TextInputFormatter> get notesInputFormatters => <TextInputFormatter>[
        LengthLimitingTextInputFormatter(invoiceNotesMax),
      ];

  List<TextInputFormatter> get partialPaidInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(partialPaidAmountMax),
      ];

  List<TextInputFormatter> get itemNameInputFormatters => <TextInputFormatter>[
        LengthLimitingTextInputFormatter(itemNameMax),
      ];

  List<TextInputFormatter> get itemQtyInputFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(itemQtyMax),
      ];

  List<TextInputFormatter> get itemUnitPriceInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(itemUnitPriceMax),
      ];

  FormFieldValidator<String> get notesValidator => (String? value) {
        return FormValidations.validateCommonNotes(
          value ?? '',
          fieldName: "Notes",
          maxLength: invoiceNotesMax,
        );
      };

  FormFieldValidator<String> get partialPaidAmountValidator => (String? value) {
        if (!isPartialPaidStatus) return null;
        final String? base = FormValidations.validateCommonAmount(
          value ?? '',
          fieldName: "Partial Paid Amount",
          maxChars: partialPaidAmountMax,
          required: true,
          allowZero: false,
        );
        if (base != null) return base;
        final num? entered = num.tryParse((value ?? '').trim());
        final double total = invoiceGrandTotal;
        if (entered != null && entered >= total) {
          return "Partial paid amount cannot be equal or exceed invoice total (${total.toStringAsFixed(2)})";
        }
        return null;
      };

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is InvoiceModel) {
      isCustomerLocked.value = false;
      isBusinessLocked.value = false;
      loadForEdit(args);
    } else {
      _applyPreselectedSelectionsFromArgs(args);
    }
    fetchDropdowns();
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  Future<void> fetchDropdowns() async {
    isLoading.value = true;
    try {
      final List<Future<void>> requests = <Future<void>>[
        fetchPaymentMethods(),
      ];
      if (!isBusinessLocked.value) {
        requests.insert(0, fetchBusinesses());
      }
      if (!isCustomerLocked.value) {
        requests.insert(0, fetchCustomers());
      }
      await Future.wait(requests);
    } finally {
      isLoading.value = false;
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
    }
  }

  Future<void> _ensureSelectedBusinessDetails() async {
    final int? id = selectedBusinessId.value;
    if (id == null) {
      selectedBusinessDetails.value = null;
      return;
    }
    if (selectedBusinessDetails.value?.id == id) return;
    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllBusinesses}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    selectedBusinessDetails.value = BusinessModel.fromJson(payload);
  }

  Future<void> onBusinessChanged(int? businessId) async {
    selectedBusinessId.value = businessId;
    if (businessId == null) {
      selectedBusinessDetails.value = null;
      taxEnabled.value = false;
      return;
    }
    await _ensureSelectedBusinessDetails();
  }

  Future<void> onTaxToggle(bool enabled, {BuildContext? context}) async {
    if (!enabled) {
      taxEnabled.value = false;
      return;
    }
    if (selectedBusinessId.value == null) {
      AppUtils.showTopToast(
        "Please select business first",
        context: context,
        atBottom: true,
      );
      return;
    }
    await _ensureSelectedBusinessDetails();
    taxEnabled.value = true;
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
    }
  }

  Future<void> createOrUpdateInvoice() async {
    if (isSubmitting.value) return;
    final bool isEdit = editingInvoiceId.value != null;
    final bool ok = formKey.currentState?.validate() ?? false;
    if (!ok) return;
    final List<String> missing = <String>[];
    if (selectedCustomerId.value == null) missing.add('Customer');
    if (selectedBusinessId.value == null) missing.add('Business');
    if (selectedPaymentMethodId.value == null) missing.add('Payment Method');
    if (invoiceDate.value == null) missing.add('Invoice Date');

    if (missing.isNotEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Required Fields",
        message: 'Please provide: ${missing.join(', ')}',
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    if (items.isEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Required Fields",
        message: "Please add at least one item.",
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    final double totalAmount = invoiceGrandTotal;
    if (!isEdit && isPartialPaidStatus) {
      final double? partialAmount = _toDouble(partialPaidAmountController.text);
      if (partialAmount == null || partialAmount <= 0) {
        AppDialogs.showActionDialog(
          iconPath: AppImages.dialogWarning,
          title: "Required Fields",
          message: "Please enter a valid partial payment amount.",
          actions: [AppDialogAction(label: "Ok")],
        );
        return;
      }
      if (partialAmount > totalAmount) {
        AppDialogs.showActionDialog(
          iconPath: AppImages.dialogWarning,
          title: "Invalid Amount",
          message: "Partial payment amount cannot be greater than invoice total amount.",
          actions: [AppDialogAction(label: "Ok")],
        );
        return;
      }
    }

    isSubmitting.value = true;

    final InvoiceModel model = InvoiceModel(
      customerId: selectedCustomerId.value,
      businessId: selectedBusinessId.value,
      paymentMethodId: selectedPaymentMethodId.value,
      invoiceDate: DateFormats.yyyyMmDd(invoiceDate.value!),
      status: _apiStatusValue(status.value),
      notes: notesController.text.trim(),
      taxEnabled: taxEnabled.value,
      items: items.toList(),
    );
    final Map<String, dynamic> requestPayload = model.toJson();
    if (isEdit) {
      _removeServerManagedFieldsForUpdate(requestPayload);
    } else {
      _removeServerManagedFieldsForCreate(requestPayload);
    }
    debugPrint(
      '[Invoice ${isEdit ? "Update" : "Create"}] '
      'URL=${isEdit ? "${AppUrls.updateInvoice}/${editingInvoiceId.value}" : AppUrls.createInvoice}',
    );
    debugPrint('[Invoice ${isEdit ? "Update" : "Create"}] Payload=${jsonEncode(requestPayload)}');

    final int? editedId = editingInvoiceId.value;
    final ApiResponse response = isEdit
        ? await ApiService().post(
            '${AppUrls.updateInvoice}/${editingInvoiceId.value}',
            data: requestPayload,
            isAuth: true,
          )
        : await ApiService().post(
            AppUrls.createInvoice,
            data: requestPayload,
            isAuth: true,
          );
    debugPrint(
      '[Invoice ${isEdit ? "Update" : "Create"}] '
      'Response success=${response.success}, '
      'successCode=${response.success ? 1 : 0}, '
      'statusCode=${response.statusCode}, '
      'message=${response.message}',
    );
    debugPrint(
      '[Invoice ${isEdit ? "Update" : "Create"}] '
      'Response errors=${jsonEncode(response.errors)}',
    );
    debugPrint(
      '[Invoice ${isEdit ? "Update" : "Create"}] '
      'Response data=${jsonEncode(response.data)}',
    );

    if (response.success) {
      InvoiceModel updatedInvoice = _buildUpdatedInvoice(
        requestModel: model,
        response: response,
      );
      InvoiceModel? doneResult;
      final int? createdInvoiceId = updatedInvoice.id;

      if (!isEdit && (isPaidStatus || isPartialPaidStatus)) {
        final double? paymentAmount = isPaidStatus
            ? _toDouble(updatedInvoice.totalAmount) ?? invoiceGrandTotal
            : _toDouble(partialPaidAmountController.text.trim());
        if (createdInvoiceId != null && paymentAmount != null && paymentAmount > 0) {
          final ApiResponse paymentResponse = await _createInvoicePayment(
            invoiceId: createdInvoiceId,
            paymentAmount: paymentAmount,
          );
          if (!paymentResponse.success) {
            isSubmitting.value = false;
            AppDialogs.showActionDialog(
              iconPath: AppImages.dialogWarning,
              title: "Payment Failed",
              message:
                  'Invoice created but payment could not be recorded. ${paymentResponse.message}',
              actions: [AppDialogAction(label: "Ok")],
            );
            return;
          }
          final InvoiceModel? refreshed = await _fetchInvoiceById(createdInvoiceId);
          if (refreshed != null) {
            updatedInvoice = refreshed;
          }
        }
      }

      if (isEdit) {
        if (Get.isRegistered<InvoiceScreenController>()) {
          await Get.find<InvoiceScreenController>().fetchInvoices();
        }
        doneResult = editedId == null ? null : await _fetchInvoiceById(editedId);
      }

      isSubmitting.value = false;

      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: isEdit
            ? "Invoice Updated!"
            : "Invoice Added!",
        message: response.message,
        actions: isEdit
            ? [
                AppDialogAction(
                  label: "Done",
                  onPressed: () {
                    Get.back(result: doneResult ?? updatedInvoice);
                  },
                ),
              ]
            : [
                AppDialogAction(
                  label: "Add New Invoice",
                  onPressed: () {
                    _resetFormForNewInvoice();
                    if (Get.isRegistered<InvoiceScreenController>()) {
                      Get.find<InvoiceScreenController>().fetchInvoices();
                    }
                  },
                ),
                AppDialogAction(
                  label: "Done",
                  onPressed: () {
                    if (Get.isRegistered<InvoiceScreenController>()) {
                      Get.find<InvoiceScreenController>().fetchInvoices();
                    }
                    Get.back(result: updatedInvoice);
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

  void _removeServerManagedFieldsForCreate(Map<String, dynamic> payload) {
    payload.remove('id');
    payload.remove('user_id');
    payload.remove('invoice_number');
    payload.remove('paid_amount');
    payload.remove('remaining_amount');
    payload.remove('created_at');
    payload.remove('updated_at');
  }

  void _removeServerManagedFieldsForUpdate(Map<String, dynamic> payload) {
    payload.remove('id');
    payload.remove('user_id');
    payload.remove('created_at');
    payload.remove('updated_at');
  }

  Future<void> submitInvoiceFromForm() async {
    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();
    showSelectionErrors.value = true;
    final bool formOk = formKey.currentState?.validate() ?? false;
    if (!formOk) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstTextError();
      return;
    }
    if (!_hasRequiredSelections()) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstSelectionError();
      return;
    }
    await createOrUpdateInvoice();
  }

  bool _hasRequiredSelections() {
    return selectedCustomerId.value != null &&
        selectedBusinessId.value != null &&
        selectedPaymentMethodId.value != null &&
        invoiceDate.value != null;
  }

  String? get customerSelectionError {
    if (!showSelectionErrors.value || selectedCustomerId.value != null) return null;
    return "Customer is required";
  }

  String? get invoiceDateSelectionError {
    if (!showSelectionErrors.value || invoiceDate.value != null) return null;
    return "Invoice Date is required";
  }

  String? get statusSelectionError {
    if (!showSelectionErrors.value || status.value.trim().isNotEmpty) return null;
    return "Status is required";
  }

  String? get businessSelectionError {
    if (!showSelectionErrors.value || selectedBusinessId.value != null) return null;
    return "Business is required";
  }

  String? get paymentMethodSelectionError {
    if (!showSelectionErrors.value || selectedPaymentMethodId.value != null) return null;
    return "Payment Method is required";
  }

  Future<void> _scrollToFirstTextError() async {
    final List<GlobalKey<FormFieldState<String>>> keysInOrder =
        <GlobalKey<FormFieldState<String>>>[
      partialPaidFieldKey,
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
      (invalid: selectedCustomerId.value == null, key: customerFieldKey),
      (invalid: invoiceDate.value == null, key: invoiceDateFieldKey),
      (invalid: status.value.trim().isEmpty, key: statusFieldKey),
      (invalid: selectedBusinessId.value == null, key: businessFieldKey),
      (invalid: selectedPaymentMethodId.value == null, key: paymentMethodFieldKey),
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

  Future<InvoiceModel?> _fetchInvoiceById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.createInvoice}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    return InvoiceModel.fromJson(payload);
  }

  void _resetFormForNewInvoice() {
    final int? lockedCustomerId =
        isCustomerLocked.value ? selectedCustomerId.value : null;
    final int? lockedBusinessId =
        isBusinessLocked.value ? selectedBusinessId.value : null;
    editingInvoiceId.value = null;
    notesController.clear();
    invoiceDate.value = null;
    partialPaidAmountController.clear();
    status.value = 'unpaid';
    taxEnabled.value = false;
    selectedCustomerId.value = lockedCustomerId;
    selectedBusinessId.value = lockedBusinessId;
    selectedPaymentMethodId.value = null;
    items.clear();
    showSelectionErrors.value = false;
    selectedBusinessDetails.value = null;
  }

  void _applyPreselectedSelectionsFromArgs(dynamic args) {
    int? customerId;
    String? customerName;
    bool lockCustomer = true;
    int? businessId;
    String? businessName;
    bool lockBusiness = true;

    if (args is CustomerModel) {
      customerId = args.id;
      customerName = args.customerName;
    } else if (args is BusinessModel) {
      businessId = args.id;
      businessName = args.businessName;
    } else if (args is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(args as Map);
      customerId = _toInt(map['customerId'] ?? map['customer_id']);
      customerName = map['customerName']?.toString();
      if (customerId == null && map['customer'] is CustomerModel) {
        final CustomerModel customer = map['customer'] as CustomerModel;
        customerId = customer.id;
        customerName ??= customer.customerName;
      }
      if (map['lockCustomer'] is bool) {
        lockCustomer = map['lockCustomer'] as bool;
      }
      businessId = _toInt(map['businessId'] ?? map['business_id']);
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

    if (customerName != null && customerName.trim().isNotEmpty) {
      lockedCustomerName.value = customerName.trim();
    }
    if (customerId != null) {
      selectedCustomerId.value = customerId;
      isCustomerLocked.value = lockCustomer;
      if (lockedCustomerName.value.isEmpty) {
        lockedCustomerName.value = customerName ?? '';
      }
    }
    if (businessId != null) {
      selectedBusinessId.value = businessId;
      isBusinessLocked.value = lockBusiness;
      lockedBusinessName.value = (businessName ?? '').trim();
      if (lockedBusinessName.value.isEmpty) {
        lockedBusinessName.value = _businessNameById(businessId) ?? '';
      }
      _ensureSelectedBusinessDetails();
    } else if (businessName != null && businessName.trim().isNotEmpty) {
      lockedBusinessName.value = businessName.trim();
    }
  }

  void loadForEdit(InvoiceModel model) {
    editingInvoice.value = model;
    editingInvoiceId.value = model.id;
    notesController.text = model.notes ?? '';
    status.value = _resolveEditStatus(model);
    taxEnabled.value = model.taxEnabled ?? false;
    if (isPartialPaidStatus) {
      final double? paid = _toDouble(model.paidAmount);
      if (paid != null && paid > 0) {
        partialPaidAmountController.text = _formatAmountForInput(paid);
      } else {
        partialPaidAmountController.clear();
      }
    } else {
      partialPaidAmountController.clear();
    }
    if (model.invoiceDate != null && model.invoiceDate!.isNotEmpty) {
      invoiceDate.value = DateTime.tryParse(model.invoiceDate!);
    }
    selectedCustomerId.value = model.customerId;
    selectedBusinessId.value = model.businessId;
    selectedPaymentMethodId.value = model.paymentMethodId;
    items.clear();
    if (model.items.isNotEmpty) {
      items.addAll(model.items);
    }
    _ensureSelectedBusinessDetails();
    showSelectionErrors.value = false;
  }

  InvoiceModel _buildUpdatedInvoice({
    required InvoiceModel requestModel,
    required ApiResponse response,
  }) {
    InvoiceModel? apiInvoice;
    if (response.data is Map) {
      apiInvoice = InvoiceModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    final InvoiceModel? previous = editingInvoice.value;
    final int? customerId =
        apiInvoice?.customerId ?? requestModel.customerId ?? previous?.customerId;
    final int? businessId =
        apiInvoice?.businessId ?? requestModel.businessId ?? previous?.businessId;
    final int? paymentMethodId = apiInvoice?.paymentMethodId ??
        requestModel.paymentMethodId ??
        previous?.paymentMethodId;

    final List<InvoiceItemModel> resolvedItems =
        (apiInvoice?.items.isNotEmpty == true)
            ? apiInvoice!.items
            : requestModel.items;

    final double calculatedSubtotal = _calculateItemsTotal(resolvedItems);
    final bool resolvedTaxEnabled =
        apiInvoice?.taxEnabled ?? requestModel.taxEnabled ?? previous?.taxEnabled ?? false;
    final double taxPercent = invoiceTaxPercent;
    final double calculatedTax =
        resolvedTaxEnabled ? (calculatedSubtotal * taxPercent) / 100 : 0;
    final double calculatedTotal = calculatedSubtotal + calculatedTax;
    final dynamic totalAmount =
        apiInvoice?.totalAmount ?? previous?.totalAmount ?? calculatedTotal;
    final dynamic paidAmount = apiInvoice?.paidAmount ?? previous?.paidAmount ?? 0;
    final dynamic remainingAmount =
        apiInvoice?.remainingAmount ?? previous?.remainingAmount ?? totalAmount;

    return InvoiceModel(
      id: apiInvoice?.id ?? editingInvoiceId.value ?? previous?.id,
      userId: apiInvoice?.userId ?? previous?.userId,
      customerId: customerId,
      customerName:
          apiInvoice?.customerName ?? previous?.customerName ?? _customerNameById(customerId),
      businessId: businessId,
      businessName:
          apiInvoice?.businessName ?? previous?.businessName ?? _businessNameById(businessId),
      paymentMethodId: paymentMethodId,
      paymentMethodName: apiInvoice?.paymentMethodName ??
          previous?.paymentMethodName ??
          _paymentMethodNameById(paymentMethodId),
      invoiceNumber:
          apiInvoice?.invoiceNumber ?? requestModel.invoiceNumber ?? previous?.invoiceNumber,
      invoiceDate:
          apiInvoice?.invoiceDate ?? requestModel.invoiceDate ?? previous?.invoiceDate,
      status: apiInvoice?.status ?? requestModel.status ?? previous?.status,
      notes: apiInvoice?.notes ?? requestModel.notes ?? previous?.notes,
      taxEnabled: resolvedTaxEnabled,
      subtotalAmount:
          apiInvoice?.subtotalAmount ?? previous?.subtotalAmount ?? calculatedSubtotal,
      taxAmount: apiInvoice?.taxAmount ?? previous?.taxAmount ?? calculatedTax,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      paymentStatus:
          apiInvoice?.paymentStatus ?? previous?.paymentStatus ?? 'unpaid',
      items: resolvedItems,
      createdAt: apiInvoice?.createdAt ?? previous?.createdAt,
      updatedAt: apiInvoice?.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  String? _customerNameById(int? id) {
    if (id == null) return null;
    for (final customer in customers) {
      if (customer.id == id) return customer.customerName;
    }
    return null;
  }

  String? _businessNameById(int? id) {
    if (id == null) return null;
    for (final business in businesses) {
      if (business.id == id) return business.businessName;
    }
    return null;
  }

  String? _paymentMethodNameById(int? id) {
    if (id == null) return null;
    for (final method in paymentMethods) {
      final int? methodId = method['id'] is int
          ? method['id'] as int
          : int.tryParse(method['id']?.toString() ?? '');
      if (methodId == id) return method['name']?.toString();
    }
    return null;
  }

  double _calculateItemsTotal(List<InvoiceItemModel> lineItems) {
    double total = 0;
    for (final line in lineItems) {
      final double? unitPrice = _toDouble(line.unitPrice);
      final int qty = _toInt(line.qty) ?? 0;
      if (unitPrice != null && qty > 0) {
        total += unitPrice * qty;
      } else if (line.totalAmount != null) {
        final double? lineTotal = _toDouble(line.totalAmount);
        if (lineTotal != null) total += lineTotal;
      }
    }
    return total;
  }

  Future<ApiResponse> _createInvoicePayment({
    required int invoiceId,
    required double paymentAmount,
  }) {
    return ApiService().post(
      '${AppUrls.createInvoice}/$invoiceId/payments',
      isAuth: true,
      data: {
        'payment_amount': paymentAmount.toStringAsFixed(2),
        'payment_date': DateFormats.yyyyMmDd(invoiceDate.value!),
        'payment_method_id': selectedPaymentMethodId.value?.toString(),
        'reference_number': null,
        'notes': notesController.text.trim().isNotEmpty
            ? 'Auto payment on invoice create'
            : null,
      },
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  String _normalizeStatusValue(String? raw) {
    final String normalized = (raw ?? '').trim().toLowerCase();
    if (normalized == 'paid') return 'paid';
    if (normalized == 'pending' || normalized == 'unpaid') return 'unpaid';
    if (normalized == 'partialy-paid' ||
        normalized == 'partially-paid' ||
        normalized == 'partially paid' ||
        normalized == 'partialy paid' ||
        normalized == 'partially_paid' ||
        normalized == 'partialy_paid' ||
        normalized == 'partial paid') {
      return 'partially-paid';
    }
    return 'unpaid';
  }

  String _resolveEditStatus(InvoiceModel model) {
    final String normalizedStatus = _normalizeStatusValue(model.status);
    final String normalizedPayment = _normalizeStatusValue(model.paymentStatus);
    if (normalizedStatus == 'partially-paid' || normalizedStatus == 'paid') {
      return normalizedStatus;
    }
    if (normalizedPayment == 'partially-paid' || normalizedPayment == 'paid') {
      return normalizedPayment;
    }
    return normalizedStatus;
  }

  String _formatAmountForInput(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  String _apiStatusValue(String raw) {
    final String normalized = _normalizeStatusValue(raw);
    if (normalized == 'partially-paid') {
      return 'partially_paid';
    }
    return normalized;
  }

  @override
  void onClose() {
    notesController.dispose();
    partialPaidAmountController.dispose();
    super.onClose();
  }
}
