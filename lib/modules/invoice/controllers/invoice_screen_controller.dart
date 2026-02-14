import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';

class InvoiceScreenController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
    searchController.addListener(() {
      invoices.refresh();
    });
  }

  List<InvoiceModel> get filteredInvoices {
    final String q = searchController.text.toLowerCase().trim();
    if (q.isEmpty) return invoices;
    return invoices.where((i) {
      final combined =
          '${i.customerName ?? ''} ${i.invoiceNumber ?? ''} ${i.status ?? ''}'
              .toLowerCase();
      return combined.contains(q);
    }).toList();
  }

  Future<void> fetchInvoices() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.createInvoice,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      invoices.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => InvoiceModel.fromJson(e))
            .toList(),
      );
    } else {
      invoices.clear();
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
