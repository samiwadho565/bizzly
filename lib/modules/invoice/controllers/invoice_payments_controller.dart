import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/modules/invoice/models/invoice_payment_model.dart';
import 'package:bizly/routes/routes.dart';

class InvoicePaymentsController extends GetxController {
  final Rxn<InvoiceModel> invoice = Rxn<InvoiceModel>();
  final RxList<InvoicePaymentModel> payments = <InvoicePaymentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  int? get invoiceId => invoice.value?.id;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is InvoiceModel) {
      invoice.value = args;
    }
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    final int? id = invoiceId;
    if (id == null) {
      error.value = 'Invoice not found';
      payments.clear();
      return;
    }
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      '${AppUrls.createInvoice}/$id/payments',
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      payments.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map(InvoicePaymentModel.fromJson)
            .toList(),
      );
    } else {
      payments.clear();
      error.value = response.message;
    }

    isLoading.value = false;
  }

  Future<InvoiceModel?> fetchInvoiceById() async {
    final int? id = invoiceId;
    if (id == null) return null;
    final ApiResponse response = await ApiService().get(
      '${AppUrls.createInvoice}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    final InvoiceModel updated = InvoiceModel.fromJson(payload);
    invoice.value = updated;
    if (updated.payments.isNotEmpty) {
      payments.assignAll(updated.payments);
    }
    return updated;
  }

  Future<void> goToCreatePayment() async {
    if (invoice.value == null) return;
    final dynamic result = await Get.toNamed(
      Routes.createInvoicePaymentScreen,
      arguments: invoice.value,
    );
    if (result != null) {
      await fetchInvoiceById();
      if (payments.isEmpty) {
        await fetchPayments();
      }
    }
  }

  void closeWithResult() {
    Get.back(result: invoice.value);
  }
}
