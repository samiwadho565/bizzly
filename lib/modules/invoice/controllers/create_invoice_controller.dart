import 'package:get/get.dart';
import 'package:flutter/material.dart';

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

class CreateInvoiceController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController invoiceNumberController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final Rxn<DateTime> invoiceDate = Rxn<DateTime>();
  final RxString status = 'pending'.obs;

  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxList<BusinessModel> businesses = <BusinessModel>[].obs;
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[].obs;

  final RxnInt selectedCustomerId = RxnInt();
  final RxnInt selectedBusinessId = RxnInt();
  final RxnInt selectedPaymentMethodId = RxnInt();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnInt editingInvoiceId = RxnInt();
  final Rxn<InvoiceModel> editingInvoice = Rxn<InvoiceModel>();

  final RxList<InvoiceItemModel> items = <InvoiceItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdowns();
    final dynamic args = Get.arguments;
    if (args is InvoiceModel) {
      loadForEdit(args);
    }
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  Future<void> fetchDropdowns() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchCustomers(),
        fetchBusinesses(),
        fetchPaymentMethods(),
      ]);
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

    isSubmitting.value = true;

    final InvoiceModel model = InvoiceModel(
      customerId: selectedCustomerId.value,
      businessId: selectedBusinessId.value,
      paymentMethodId: selectedPaymentMethodId.value,
      invoiceNumber: invoiceNumberController.text.trim(),
      invoiceDate: DateFormats.yyyyMmDd(invoiceDate.value!),
      status: status.value,
      notes: notesController.text.trim(),
      items: items.toList(),
    );

    final bool isEdit = editingInvoiceId.value != null;
    final int? editedId = editingInvoiceId.value;
    final ApiResponse response = isEdit
        ? await ApiService().post(
            '${AppUrls.updateInvoice}/${editingInvoiceId.value}',
            data: model.toJson(),
            isAuth: true,
          )
        : await ApiService().post(
            AppUrls.createInvoice,
            data: model.toJson(),
            isAuth: true,
          );

    if (response.success) {
      final InvoiceModel updatedInvoice = _buildUpdatedInvoice(
        requestModel: model,
        response: response,
      );
      InvoiceModel? doneResult;
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
    editingInvoiceId.value = null;
    invoiceNumberController.clear();
    notesController.clear();
    invoiceDate.value = null;
    status.value = 'pending';
    selectedCustomerId.value = null;
    selectedBusinessId.value = null;
    selectedPaymentMethodId.value = null;
    items.clear();
  }

  void loadForEdit(InvoiceModel model) {
    editingInvoice.value = model;
    editingInvoiceId.value = model.id;
    invoiceNumberController.text = model.invoiceNumber ?? '';
    notesController.text = model.notes ?? '';
    status.value = model.status ?? 'pending';
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

    final double calculatedTotal = _calculateItemsTotal(resolvedItems);
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
      final double? amount = _toDouble(line.amount);
      if (amount != null) total += amount;
    }
    return total;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  @override
  void onClose() {
    invoiceNumberController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
