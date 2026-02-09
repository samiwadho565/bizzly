import 'dart:io';

import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/services/api_service.dart';

class CreateBusinessController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Rxn<BusinessModel> editingBusiness = Rxn<BusinessModel>();

  // Required
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final Rxn<File> businessImageFile = Rxn<File>();

  // Optional
  final TextEditingController businessEmailController = TextEditingController();
  final TextEditingController taxNtnController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController socialMediaController = TextEditingController();
  final TextEditingController businessDescriptionController =
      TextEditingController();
  final TextEditingController operatingHoursController = TextEditingController();
  final TextEditingController secondaryContactController =
      TextEditingController();
  final Rxn<File> businessCoverImageFile = Rxn<File>();

  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  bool get isEdit => editingBusiness.value?.id != null;

  Future<void> pickBusinessImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      businessImageFile.value =
          await _compressImageFile(File(picked.path));
    }
  }

  Future<void> pickBusinessCoverImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      businessCoverImageFile.value =
          await _compressImageFile(File(picked.path));
    }
  }

  Future<File> _compressImageFile(File file) async {
    final Directory dir = await getTemporaryDirectory();
    int quality = 85;
    File? compressed = file;

    while (compressed != null && await compressed.length() > 2048 * 1024 && quality >= 40) {
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

  Future<void> createBusiness() async {
    if (isLoading.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final String businessName = businessNameController.text.trim();
    final String businessAddress = businessAddressController.text.trim();
    final String phoneNumber = phoneNumberController.text.trim();
    final String currency = currencyController.text.trim();

    final List<String> missing = [];
    if (businessName.isEmpty) missing.add('Business Name');
    if (businessAddress.isEmpty) missing.add('Business Address');
    if (phoneNumber.isEmpty) missing.add('Phone Number');
    if (currency.isEmpty) missing.add('Currency');
    final bool hasExistingImage =
        (editingBusiness.value?.businessImageUrl ?? '').isNotEmpty;
    if (businessImageFile.value == null && !hasExistingImage) {
      missing.add('Business Image');
    }

    if (missing.isNotEmpty) {
      Get.snackbar(
        'Required Fields',
        'Please fill: ${missing.join(', ')}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withAlpha(200),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final String businessEmail = businessEmailController.text.trim();
    final String taxNtnNumber = taxNtnController.text.trim();
    final String website = websiteController.text.trim();
    final String socialMediaLink = socialMediaController.text.trim();
    final String businessDescription = businessDescriptionController.text.trim();
    final String operatingHours = operatingHoursController.text.trim();
    final String secondaryContact = secondaryContactController.text.trim();

    final BusinessModel business = BusinessModel(
      businessName: businessName,
      businessAddress: businessAddress,
      phoneNumber: phoneNumber,
      currency: currency,
      businessImage: businessImageFile.value,
      businessCoverImage: businessCoverImageFile.value,
      businessEmail: businessEmail.isNotEmpty ? businessEmail : null,
      taxNtnNumber: taxNtnNumber.isNotEmpty ? taxNtnNumber : null,
      website: website.isNotEmpty ? website : null,
      socialMediaLink: socialMediaLink.isNotEmpty ? socialMediaLink : null,
      businessDescription:
          businessDescription.isNotEmpty ? businessDescription : null,
      operatingHours: operatingHours.isNotEmpty ? operatingHours : null,
      secondaryContact: secondaryContact.isNotEmpty ? secondaryContact : null,
    );

    ApiResponse response;
    if (isEdit) {
      final int? id = editingBusiness.value?.id;
      response = await ApiService().postMultipart(
        '${AppUrls.updateBusiness}/$id',
        data: business.toJson(),
        isAuth: true,
      );
    } else {
      response = await ApiService().postMultipart(
        AppUrls.createBusiness,
        data: business.toJson(),
        isAuth: true,
      );
    }
      print("response.message, : ${response.message}");
    AppDialogs.showActionDialog(
      iconPath:
          response.success ? AppImages.dialogSuccess : AppImages.dialogWarning,
      title: response.success
          ? (isEdit ? "Business Updated!" : "Business Added!")
          : "Error!",
      message: response.success
          ? (isEdit
              ? "Business has been updated successfully."
              : "Business has been added successfully.")
          : response.message,
      actions: response.success
          ? [
              if (!isEdit) AppDialogAction(label: "New Business"),
              AppDialogAction(
                label: "Done",
                onPressed: () {
                  if (isEdit) {
                    BusinessModel? updated;
                    if (response.data is Map<String, dynamic>) {
                      updated = BusinessModel.fromJson(
                        response.data as Map<String, dynamic>,
                      );
                    } else {
                      final BusinessModel? current = editingBusiness.value;
                      updated = BusinessModel(
                        id: current?.id,
                        userId: current?.userId,
                        businessName: businessName,
                        businessAddress: businessAddress,
                        phoneNumber: phoneNumber,
                        currency: currency,
                        businessEmail:
                            businessEmail.isNotEmpty ? businessEmail : null,
                        taxNtnNumber:
                            taxNtnNumber.isNotEmpty ? taxNtnNumber : null,
                        website: website.isNotEmpty ? website : null,
                        socialMediaLink:
                            socialMediaLink.isNotEmpty ? socialMediaLink : null,
                        businessDescription: businessDescription.isNotEmpty
                            ? businessDescription
                            : null,
                        operatingHours:
                            operatingHours.isNotEmpty ? operatingHours : null,
                        secondaryContact: secondaryContact.isNotEmpty
                            ? secondaryContact
                            : null,
                        businessImageUrl: current?.businessImageUrl,
                        businessCoverImageUrl: current?.businessCoverImageUrl,
                        createdAt: current?.createdAt,
                        updatedAt: DateTime.now().toString(),
                      );
                    }
                    Get.back(result: updated);
                  }
                },
              ),
            ]
          : [
              AppDialogAction(
                label: "Ok",
                onPressed: () {
                  Get.back();
                },
              ),
            ],
    );


    // Get.snackbar(
    //   response.success ? 'Success' : 'Error',
    //   response.message,
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: response.success ? Colors.green : Colors.red,
    //   colorText: Colors.white,
    // );

    isLoading.value = false;
  }

  void loadForEdit(BusinessModel business) {
    editingBusiness.value = business;
    businessNameController.text = business.businessName;
    businessAddressController.text = business.businessAddress;
    phoneNumberController.text = business.phoneNumber;
    currencyController.text = business.currency;
    businessEmailController.text = business.businessEmail ?? '';
    taxNtnController.text = business.taxNtnNumber ?? '';
    websiteController.text = business.website ?? '';
    socialMediaController.text = business.socialMediaLink ?? '';
    businessDescriptionController.text = business.businessDescription ?? '';
    operatingHoursController.text = business.operatingHours ?? '';
    secondaryContactController.text = business.secondaryContact ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is BusinessModel) {
      loadForEdit(args);
    }
  }

  @override
  void onClose() {
    businessNameController.dispose();
    businessAddressController.dispose();
    phoneNumberController.dispose();
    currencyController.dispose();

    businessEmailController.dispose();
    taxNtnController.dispose();
    websiteController.dispose();
    socialMediaController.dispose();
    businessDescriptionController.dispose();
    operatingHoursController.dispose();
    secondaryContactController.dispose();

    super.onClose();
  }
}
