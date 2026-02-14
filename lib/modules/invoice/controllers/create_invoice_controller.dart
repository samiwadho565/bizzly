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
    if (selectedCustomerId.value == null ||
        selectedBusinessId.value == null ||
        selectedPaymentMethodId.value == null ||
        invoiceDate.value == null) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Required Fields",
        message: "Please fill all required fields.",
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

    final ApiResponse response = editingInvoiceId.value != null
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

    isSubmitting.value = false;

    if (response.success) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: editingInvoiceId.value != null
            ? "Invoice Updated!"
            : "Invoice Added!",
        message: response.message,
        actions: [
          AppDialogAction(
            label: "Done",
            onPressed: () {
              if (Get.isRegistered<InvoiceScreenController>()) {
                Get.find<InvoiceScreenController>().fetchInvoices();
              }
              Get.back(result: true);
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

  void loadForEdit(InvoiceModel model) {
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

  @override
  void onClose() {
    invoiceNumberController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
