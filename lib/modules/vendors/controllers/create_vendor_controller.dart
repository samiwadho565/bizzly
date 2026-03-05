import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/vendors/controllers/vendors_controller.dart';

class CreateVendorController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxBool isLoading = false.obs;
  final Rxn<VendorModel> editingVendor = Rxn<VendorModel>();

  bool get isEdit => editingVendor.value?.id != null;

  Future<void> createVendor() async {

    if (isLoading.value) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    final VendorModel vendor = VendorModel(
      vendorName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      email: emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : null,
      address: addressController.text.trim(),
      companyName: companyController.text.trim().isNotEmpty
          ? companyController.text.trim()
          : null,
      taxNumber: taxController.text.trim().isNotEmpty
          ? taxController.text.trim()
          : null,
      notes: notesController.text.trim().isNotEmpty
          ? notesController.text.trim()
          : null,
    );

    final ApiResponse response = isEdit
        ? await ApiService().post(
            '${AppUrls.updateVendor}/${editingVendor.value!.id}',
            data: vendor.toJson(),
            isAuth: true,
          )
        : await ApiService().post(
            AppUrls.createVendor,
            data: vendor.toJson(),
            isAuth: true,
          );

    if (response.success) {
      final int? editedId = editingVendor.value?.id;
      VendorModel? created;
      VendorModel? doneResult;
      if (response.data is Map<String, dynamic>) {
        created = VendorModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      if (isEdit) {
        if (Get.isRegistered<VendorsController>()) {
          await Get.find<VendorsController>().fetchVendors();
        }
        final int? targetId = editedId ?? created?.id;
        doneResult = targetId == null ? null : await _fetchVendorById(targetId);
      }

      isLoading.value = false;

      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: isEdit ? "Vendor Updated!" : "Vendor Added!",
        message: isEdit
            ? "Vendor updated successfully."
            : "Vendor created successfully.",
        actions: [
          if (!isEdit)
            AppDialogAction(label: "Create New Vendor", onPressed: () {
              if (Get.isRegistered<VendorsController>()) {
                Get.find<VendorsController>().fetchVendors();
              }
            }),
          AppDialogAction(label: "Done", onPressed: () {
            if (isEdit) {
              Get.back(result: doneResult ?? created ?? vendor);
              return;
            }
            if (Get.isRegistered<VendorsController>()) {
              Get.find<VendorsController>().fetchVendors();
            }
            Get.back(result: created ?? vendor);
          }),
        ],
      );
    } else {
      isLoading.value = false;
      AppUtils.showAppSnackbar(
        "Error",
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.error,
      );
    }
  }

  Future<VendorModel?> _fetchVendorById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.createVendor}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    return VendorModel.fromJson(payload);
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    taxController.dispose();
    notesController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is VendorModel) {
      loadForEdit(args);
    }
  }

  void loadForEdit(VendorModel vendor) {
    editingVendor.value = vendor;
    nameController.text = vendor.vendorName;
    phoneController.text = vendor.phoneNumber;
    emailController.text = vendor.email ?? '';
    addressController.text = vendor.address ?? '';
    companyController.text = vendor.companyName ?? '';
    taxController.text = vendor.taxNumber ?? '';
    notesController.text = vendor.notes ?? '';
  }
}
