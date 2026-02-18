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

import '../../home/controllers/home_controller.dart';

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
    final int? editedId = editingBusiness.value?.id;
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
    final BusinessModel? resultBusiness = _resolveResultBusiness(
      response: response,
      businessName: businessName,
      businessAddress: businessAddress,
      phoneNumber: phoneNumber,
      currency: currency,
      businessEmail: businessEmail,
      taxNtnNumber: taxNtnNumber,
      website: website,
      socialMediaLink: socialMediaLink,
      businessDescription: businessDescription,
      operatingHours: operatingHours,
      secondaryContact: secondaryContact,
    );

    BusinessModel? doneResult;
    if (response.success && isEdit) {
      if (Get.isRegistered<HomeScreenController>()) {
        await Get.find<HomeScreenController>().fetchBusinesses();
      }
      final int? targetId = editedId ?? resultBusiness?.id;
      doneResult = targetId == null ? null : await _fetchBusinessById(targetId);
      doneResult ??= resultBusiness;
    }

    isLoading.value = false;

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
              if (!isEdit)
                AppDialogAction(
                  label: "New Business",
                  onPressed: () {
                    _resetForm();
                    if (Get.isRegistered<HomeScreenController>()) {
                      Get.find<HomeScreenController>().fetchBusinesses();
                    }
                  },
                ),
              AppDialogAction(
                label: "Done",
                onPressed: () {
                  if (isEdit) {
                    Get.back(result: doneResult ?? resultBusiness);
                    return;
                  }
                  if (Get.isRegistered<HomeScreenController>()) {
                    Get.find<HomeScreenController>().fetchBusinesses();
                  }
                  Get.back(result: resultBusiness);
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
  }

  Future<BusinessModel?> _fetchBusinessById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllBusinesses}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    return BusinessModel.fromJson(payload);
  }

  BusinessModel? _resolveResultBusiness({
    required ApiResponse response,
    required String businessName,
    required String businessAddress,
    required String phoneNumber,
    required String currency,
    required String businessEmail,
    required String taxNtnNumber,
    required String website,
    required String socialMediaLink,
    required String businessDescription,
    required String operatingHours,
    required String secondaryContact,
  }) {
    if (response.data is Map) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(response.data as Map);
      final Map<String, dynamic> payload =
          map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
      return BusinessModel.fromJson(payload);
    }

    final BusinessModel? current = editingBusiness.value;
    return BusinessModel(
      id: current?.id,
      userId: current?.userId,
      businessName: businessName,
      businessAddress: businessAddress,
      phoneNumber: phoneNumber,
      currency: currency,
      businessEmail: businessEmail.isNotEmpty ? businessEmail : null,
      taxNtnNumber: taxNtnNumber.isNotEmpty ? taxNtnNumber : null,
      website: website.isNotEmpty ? website : null,
      socialMediaLink: socialMediaLink.isNotEmpty ? socialMediaLink : null,
      businessDescription: businessDescription.isNotEmpty ? businessDescription : null,
      operatingHours: operatingHours.isNotEmpty ? operatingHours : null,
      secondaryContact: secondaryContact.isNotEmpty ? secondaryContact : null,
      businessImageUrl: current?.businessImageUrl,
      businessCoverImageUrl: current?.businessCoverImageUrl,
      createdAt: current?.createdAt,
      updatedAt: DateTime.now().toString(),
    );
  }

  void _resetForm() {
    editingBusiness.value = null;
    businessNameController.clear();
    businessAddressController.clear();
    phoneNumberController.clear();
    currencyController.clear();
    businessEmailController.clear();
    taxNtnController.clear();
    websiteController.clear();
    socialMediaController.clear();
    businessDescriptionController.clear();
    operatingHoursController.clear();
    secondaryContactController.clear();
    businessImageFile.value = null;
    businessCoverImageFile.value = null;
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
