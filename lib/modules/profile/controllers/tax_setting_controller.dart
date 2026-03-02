import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/controllers/business_controller.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';

class TaxSettingsController extends GetxController {
  final RxBool isTaxEnabled = false.obs;
  final RxString taxName = ''.obs;
  final RxString taxRate = ''.obs;
  final RxString taxId = ''.obs;
  final TextEditingController taxNameController = TextEditingController();
  final TextEditingController taxRateController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();
  final Rxn<BusinessModel> business = Rxn<BusinessModel>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is BusinessModel) {
      business.value = args;
      _hydrateFromBusiness(args);
    } else if (Get.isRegistered<BusinessDetailController>()) {
      final BusinessModel? current =
          Get.find<BusinessDetailController>().business.value;
      if (current != null) {
        business.value = current;
        _hydrateFromBusiness(current);
      }
    }
    fetchBusiness();
  }

  void toggleTax(bool value) {
    isTaxEnabled.value = value;
  }

  Future<void> fetchBusiness() async {
    final int? id = business.value?.id;
    if (id == null || isLoading.value) return;
    isLoading.value = true;

    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllBusinesses}/$id',
      isAuth: true,
    );

    if (response.success && response.data is Map) {
      final BusinessModel updated =
          BusinessModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      business.value = updated;
      _hydrateFromBusiness(updated);
      _syncBusiness(updated);
    }

    isLoading.value = false;
  }

  Future<void> saveSettings() async {
    final int? id = business.value?.id;
    if (id == null || isSaving.value) return;
    isSaving.value = true;

    final Map<String, dynamic> data = <String, dynamic>{
      'invoice_tax_percentage':
          isTaxEnabled.value
              ? (num.tryParse(taxRateController.text.trim()) ?? 0)
              : 0,
      'invoice_tax_name': taxNameController.text.trim(),
      'invoice_tax_ntn': taxIdController.text.trim(),
    };

    final ApiResponse response = await ApiService().post(
      '${AppUrls.updateBusiness}/$id',
      data: data,
      isAuth: true,
    );

    if (response.success && response.data is Map) {
      final BusinessModel updated =
          BusinessModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      business.value = updated;
      _hydrateFromBusiness(updated);
      _syncBusiness(updated);
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: 'Success',
        message: 'Tax settings updated successfully',
        actions: [AppDialogAction(label: 'Ok')],
      );
    } else if (!response.success) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: 'Error!',
        message: response.message,
        actions: [AppDialogAction(label: 'Ok')],
      );
    }

    isSaving.value = false;
  }

  void _hydrateFromBusiness(BusinessModel model) {
    final num percentage = model.invoiceTaxPercentage ?? 0;
    isTaxEnabled.value = percentage > 0;
    taxName.value = model.invoiceTaxName ?? '';
    taxRate.value = percentage == 0 ? '' : _cleanNumber(percentage);
    taxId.value = model.invoiceTaxNtn ?? model.taxNtnNumber ?? '';
    taxNameController.text = taxName.value;
    taxRateController.text = taxRate.value;
    taxIdController.text = taxId.value;
  }

  void _syncBusiness(BusinessModel updated) {
    if (Get.isRegistered<BusinessDetailController>()) {
      Get.find<BusinessDetailController>().applyUpdatedBusiness(updated);
    }
    if (Get.isRegistered<HomeScreenController>()) {
      final HomeScreenController home = Get.find<HomeScreenController>();
      final int index = home.businesses.indexWhere((b) => b.id == updated.id);
      if (index >= 0) {
        home.businesses[index] = updated;
      }
    }
  }

  String _cleanNumber(num value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
  }

  @override
  void onClose() {
    taxNameController.dispose();
    taxRateController.dispose();
    taxIdController.dispose();
    super.onClose();
  }
}
