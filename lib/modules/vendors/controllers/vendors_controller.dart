import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';

class VendorsController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<VendorModel> vendors = <VendorModel>[].obs;
  final RxList<VendorModel> filtered = <VendorModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.createVendor,
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
      vendors.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => VendorModel.fromJson(e))
            .toList(),
      );
      filtered.assignAll(vendors);
    } else {
      vendors.clear();
      filtered.clear();
      error.value = response.message;
    }

    isLoading.value = false;
  }

  void filter(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(vendors);
      return;
    }
    filtered.assignAll(
      vendors.where((v) {
        return v.vendorName.toLowerCase().contains(q) ||
            (v.email ?? '').toLowerCase().contains(q) ||
            v.phoneNumber.toLowerCase().contains(q);
      }).toList(),
    );
  }

  Future<void> deleteVendor(VendorModel vendor) async {
    if (vendor.id == null || isDeleting.value) return;
    isDeleting.value = true;
    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.updateVendor}/${vendor.id}',
      isAuth: true,
    );
    AppDialogs.closeDialog();
    isDeleting.value = false;

    if (response.success) {
      vendors.removeWhere((v) => v.id == vendor.id);
      filtered.removeWhere((v) => v.id == vendor.id);
      Get.back();
      Future.microtask(() {
        Get.snackbar(
          "Success",
          "Vendor deleted successfully",
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
