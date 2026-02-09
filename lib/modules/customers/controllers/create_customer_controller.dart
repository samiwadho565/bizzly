import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/customers/controllers/customers_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateCustomerController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController secondaryPhoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController socialController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxBool isLoading = false.obs;
  final Rxn<CustomerModel> editingCustomer = Rxn<CustomerModel>();
  bool get isEdit => editingCustomer.value?.id != null;
  final Rxn<File> profileImageFile = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is CustomerModel) {
      loadForEdit(args);
    }
  }

  void loadForEdit(CustomerModel customer) {
    editingCustomer.value = customer;
    nameController.text = customer.customerName;
    phoneController.text = customer.phoneNumber;
    emailController.text = customer.email ?? '';
    addressController.text = customer.address;
    secondaryPhoneController.text = customer.secondaryPhoneNumber ?? '';
    companyController.text = customer.companyName ?? '';
    taxController.text = customer.taxNtn ?? '';
    websiteController.text = customer.website ?? '';
    socialController.text = customer.socialLink ?? '';
    notesController.text = customer.notes ?? '';
  }

  Future<void> pickProfileImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      profileImageFile.value = await _compressImageFile(File(picked.path));
    }
  }

  Future<File> _compressImageFile(File file) async {
    final Directory dir = await getTemporaryDirectory();
    int quality = 85;
    File? compressed = file;

    while (compressed != null &&
        await compressed.length() > 2048 * 1024 &&
        quality >= 40) {
      final String targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (result == null) {
        break;
      }
      compressed = File(result.path);
      quality -= 10;
    }

    return compressed ?? file;
  }

  Future<void> createCustomer() async {
    if (isLoading.value) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;

    final Map<String, dynamic> payload = {
      'customer_name': nameController.text.trim(),
      'phone_number': phoneController.text.trim(),
      'email': emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : null,
      'address': addressController.text.trim(),
      'secondary_phone_number': secondaryPhoneController.text.trim().isNotEmpty
          ? secondaryPhoneController.text.trim()
          : null,
      'company_name': companyController.text.trim().isNotEmpty
          ? companyController.text.trim()
          : null,
      'tax_ntn': taxController.text.trim().isNotEmpty
          ? taxController.text.trim()
          : null,
      'website': websiteController.text.trim().isNotEmpty
          ? websiteController.text.trim()
          : null,
      'social_link': socialController.text.trim().isNotEmpty
          ? socialController.text.trim()
          : null,
      'notes': notesController.text.trim().isNotEmpty
          ? notesController.text.trim()
          : null,
      if (profileImageFile.value != null)
        'profile_image': profileImageFile.value,
    };

    final ApiResponse response = isEdit
        ? await ApiService().postMultipart(
            '${AppUrls.updateCustomer}/${editingCustomer.value!.id}',
            data: payload,
            isAuth: true,
          )
        : await ApiService().postMultipart(
            AppUrls.createCustomer,
            data: payload,
            isAuth: true,
          );

    if (response.success) {
      CustomerModel? created;
      if (response.data is Map) {
        final Map<String, dynamic> map =
            Map<String, dynamic>.from(response.data as Map);
        final Map<String, dynamic> payload = map['data'] is Map
            ? Map<String, dynamic>.from(map['data'] as Map)
            : map;
        created = CustomerModel.fromJson(payload);
      } else {
        final CustomerModel? current = editingCustomer.value;
        created = CustomerModel(
          id: current?.id,
          userId: current?.userId,
          customerName: nameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          address: addressController.text.trim(),
          email: emailController.text.trim().isNotEmpty
              ? emailController.text.trim()
              : null,
          secondaryPhoneNumber: secondaryPhoneController.text.trim().isNotEmpty
              ? secondaryPhoneController.text.trim()
              : null,
          companyName: companyController.text.trim().isNotEmpty
              ? companyController.text.trim()
              : null,
          taxNtn: taxController.text.trim().isNotEmpty
              ? taxController.text.trim()
              : null,
          website: websiteController.text.trim().isNotEmpty
              ? websiteController.text.trim()
              : null,
          socialLink: socialController.text.trim().isNotEmpty
              ? socialController.text.trim()
              : null,
          notes: notesController.text.trim().isNotEmpty
              ? notesController.text.trim()
              : null,
          profileImage: current?.profileImage,
          createdAt: current?.createdAt,
          updatedAt: DateTime.now().toString(),
        );
      }

      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: isEdit ? "Customer Updated!" : "Customer Added!",
        message: isEdit
            ? "Customer updated successfully."
            : "Customer created successfully.",
        actions: [
          if (!isEdit) AppDialogAction(label: "Create New Customer", onPressed: () {
            if (Get.isRegistered<CustomersController>()) {
              Get.find<CustomersController>().fetchCustomers();
            }
          }),
          AppDialogAction(label: "Done", onPressed: () {
            if (Get.isRegistered<CustomersController>()) {
              Get.find<CustomersController>().fetchCustomers();
            }
            Get.back(result: created);
          }),
        ],
      );
    } else {
      Get.snackbar(
        "Error",
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    secondaryPhoneController.dispose();
    companyController.dispose();
    taxController.dispose();
    websiteController.dispose();
    socialController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
