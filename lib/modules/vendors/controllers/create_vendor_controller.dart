import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/vendors/controllers/vendors_controller.dart';
import 'package:bizly/utils/form_validations.dart';

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

  final GlobalKey<FormFieldState<String>> nameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> phoneFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> emailFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> companyFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> taxFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> addressFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> notesFieldKey =
      GlobalKey<FormFieldState<String>>();

  static const int vendorNameMax = 60;
  static const int companyNameMax = 80;
  static const int emailMax = 80;
  static const int taxMax = 30;
  static const int addressMax = 160;
  static const int notesMax = 300;
  static const int phoneTextMax = 15;

  bool get isEdit => editingVendor.value?.id != null;

  List<TextInputFormatter> get phoneInputFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]')),
        LengthLimitingTextInputFormatter(phoneTextMax),
      ];

  List<TextInputFormatter> get emailInputFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        LengthLimitingTextInputFormatter(emailMax),
      ];

  List<TextInputFormatter> get nameInputFormatters => <TextInputFormatter>[
        LengthLimitingTextInputFormatter(vendorNameMax),
      ];

  List<TextInputFormatter> get companyInputFormatters => <TextInputFormatter>[
        LengthLimitingTextInputFormatter(companyNameMax),
      ];

  List<TextInputFormatter> get taxInputFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-/]')),
        LengthLimitingTextInputFormatter(taxMax),
      ];

  List<TextInputFormatter> get addressInputFormatters => <TextInputFormatter>[
        LengthLimitingTextInputFormatter(addressMax),
      ];

  List<TextInputFormatter> get notesInputFormatters => <TextInputFormatter>[
        LengthLimitingTextInputFormatter(notesMax),
      ];

  FormFieldValidator<String> get vendorNameValidator => (String? value) {
        return FormValidations.validateCommonName(
          value ?? '',
          fieldName: "Vendor name",
          minLength: 3,
          maxLength: vendorNameMax,
        );
      };

  FormFieldValidator<String> get phoneValidator => (String? value) {
        return FormValidations.validateCommonPhoneNumber(
          value ?? '',
          fieldName: "Phone number",
          minDigits: 10,
          maxDigits: 15,
          required: true,
        );
      };

  FormFieldValidator<String> get optionalEmailValidator => (String? value) {
        return FormValidations.validateCommonEmail(
          value ?? '',
          required: false,
          maxLength: emailMax,
        );
      };

  FormFieldValidator<String> get companyNameValidator => (String? value) {
        return FormValidations.validateCommonName(
          value ?? '',
          fieldName: "Company name",
          minLength: 3,
          maxLength: companyNameMax,
        );
      };

  FormFieldValidator<String> get taxNumberValidator => (String? value) {
        return FormValidations.validateCommonTaxNumber(
          value ?? '',
          fieldName: "Tax Number (NTN / GST)",
          minLength: 3,
          maxLength: taxMax,
        );
      };

  FormFieldValidator<String> get addressValidator => (String? value) {
        return FormValidations.validateCommonAddress(
          value ?? '',
          fieldName: "Address",
          minLength: 3,
          maxLength: addressMax,
        );
      };

  FormFieldValidator<String> get notesValidator => (String? value) {
        return FormValidations.validateCommonNotes(
          value ?? '',
          fieldName: "Notes",
          maxLength: notesMax,
        );
      };

  void resetForm() {
    editingVendor.value = null;
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    companyController.clear();
    taxController.clear();
    notesController.clear();
    print("notesController : ${notesController.text}");
  }

  void clearFormAfterSuccess() {
    resetForm();
    formKey.currentState?.reset();
    final List<GlobalKey<FormFieldState<String>>> keys =
        <GlobalKey<FormFieldState<String>>>[
      nameFieldKey,
      phoneFieldKey,
      emailFieldKey,
      companyFieldKey,
      taxFieldKey,
      addressFieldKey,
      notesFieldKey,
    ];
    for (final GlobalKey<FormFieldState<String>> key in keys) {
      key.currentState?.didChange('');
      key.currentState?.reset();
    }
  }

  Future<void> submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final bool valid = formKey.currentState?.validate() ?? false;
    if (!valid) {
      await Future<void>.delayed(Duration.zero);
      await scrollToFirstError();
      return;
    }
    await createVendor();
  }

  Future<void> scrollToFirstError() async {
    final List<GlobalKey<FormFieldState<String>>> keysInOrder =
        <GlobalKey<FormFieldState<String>>>[
      nameFieldKey,
      phoneFieldKey,
      emailFieldKey,
      companyFieldKey,
      taxFieldKey,
      addressFieldKey,
    ];

    for (final GlobalKey<FormFieldState<String>> key in keysInOrder) {
      final FormFieldState<String>? state = key.currentState;
      final BuildContext? context = key.currentContext;
      if (state?.hasError == true && context != null) {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
        return;
      }
    }
  }

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
      final bool creatingNewVendor = !isEdit;
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

      if (creatingNewVendor) {
        clearFormAfterSuccess();
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
      return;
    }
    resetForm();
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
