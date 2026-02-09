import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';

class CustomersController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxList<CustomerModel> filtered = <CustomerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.createCustomer,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      List<dynamic> items = [];
      if (raw is List) {
        items = raw;
      } else if (raw is Map && raw['data'] is List) {
        items = raw['data'] as List<dynamic>;
      }
      customers.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => CustomerModel.fromJson(e))
            .toList(),
      );
      filtered.assignAll(customers);
    } else {
      customers.clear();
      filtered.clear();
      error.value = response.message;
    }

    isLoading.value = false;
  }

  void filter(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(customers);
      return;
    }
    filtered.assignAll(
      customers.where((c) {
        return c.customerName.toLowerCase().contains(q) ||
            (c.email ?? '').toLowerCase().contains(q) ||
            c.phoneNumber.toLowerCase().contains(q);
      }).toList(),
    );
  }

  Future<void> deleteCustomer(CustomerModel customer) async {
    if (customer.id == null || isDeleting.value) return;
    isDeleting.value = true;
    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.updateCustomer}/${customer.id}',
      isAuth: true,
    );
    AppDialogs.closeDialog();
    isDeleting.value = false;

    if (response.success) {
      customers.removeWhere((c) => c.id == customer.id);
      filtered.removeWhere((c) => c.id == customer.id);
      Get.back();
      Future.microtask(() {
        Get.snackbar(
          "Success",
          "Customer deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
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

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
