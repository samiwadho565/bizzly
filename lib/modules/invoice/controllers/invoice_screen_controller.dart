import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';

class InvoiceScreenController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  final RxnInt scopedBusinessId = RxnInt();
  final RxString scopedBusinessName = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get isBusinessScoped => scopedBusinessId.value != null;

  @override
  void onInit() {
    super.onInit();
    applyScopeFromArgs(Get.arguments);
    fetchInvoices();
    searchController.addListener(() {
      invoices.refresh();
    });
  }

  void applyScopeFromArgs(dynamic args) {
    final int? previousId = scopedBusinessId.value;
    final int? nextId = _extractBusinessId(args);
    final String nextName = _extractBusinessName(args);
    if (previousId == nextId && scopedBusinessName.value == nextName) return;

    scopedBusinessId.value = nextId;
    scopedBusinessName.value = nextName;

    if (isLoading.value) return;
    fetchInvoices();
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
      queryParameters: <String, dynamic>{
        if (scopedBusinessId.value != null)
          'business_id': scopedBusinessId.value.toString(),
      },
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

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _extractBusinessId(dynamic args) {
    if (args is BusinessModel) return args.id;
    if (args is Map) {
      return _toInt(args['businessId'] ?? args['business_id'] ?? args['id']);
    }
    return null;
  }

  String _extractBusinessName(dynamic args) {
    if (args is BusinessModel) return args.businessName;
    if (args is Map) {
      final dynamic raw = args['businessName'] ?? args['business_name'];
      return raw?.toString() ?? '';
    }
    return '';
  }
}
