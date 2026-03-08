import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/customers/controllers/create_customer_controller.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/assets/images.dart';

class _PhoneDigitLimitFormatter extends TextInputFormatter {
  _PhoneDigitLimitFormatter({this.maxDigits = 15});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int digitsCount = newValue.text.replaceAll(RegExp(r'\D'), '').length;
    if (digitsCount > maxDigits) {
      return oldValue;
    }
    return newValue;
  }
}

class CreateCustomerScreen extends GetView<CreateCustomerController> {
   CreateCustomerScreen({super.key});

  final TextStyle sectionTitleStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final TextStyle fieldLabelStyle = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final _PhoneDigitLimitFormatter _phoneDigitLimitFormatter =
      _PhoneDigitLimitFormatter(maxDigits: 15);
  final TextInputFormatter _nameLimitFormatter =
      LengthLimitingTextInputFormatter(60);
  final TextInputFormatter _emailLimitFormatter =
      LengthLimitingTextInputFormatter(80);
  final TextInputFormatter _addressLimitFormatter =
      LengthLimitingTextInputFormatter(160);
  final TextInputFormatter _companyLimitFormatter =
      LengthLimitingTextInputFormatter(80);
  final TextInputFormatter _taxLimitFormatter =
      LengthLimitingTextInputFormatter(30);
  final TextInputFormatter _urlLimitFormatter =
      LengthLimitingTextInputFormatter(120);
  final TextInputFormatter _notesLimitFormatter =
      LengthLimitingTextInputFormatter(300);
  final GlobalKey<FormFieldState<String>> _nameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _phoneFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _addressFieldKey =
      GlobalKey<FormFieldState<String>>();

  Future<void> _scrollToFirstError() async {
    final List<GlobalKey<FormFieldState<String>>> keysInOrder =
        <GlobalKey<FormFieldState<String>>>[
      _nameFieldKey,
      _phoneFieldKey,
      _addressFieldKey,
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

  Future<void> _submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final bool valid = controller.formKey.currentState?.validate() ?? false;
    if (!valid) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstError();
      return;
    }
    await controller.createCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: controller.isEdit ? "Edit Customer" : "Add Customer",
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Obx(
                      () {
                        final bool hasLocalImage =
                            controller.profileImageFile.value != null;
                        final String remoteImage =
                            controller.editingCustomer.value?.profileImage ?? '';
                        final bool hasRemoteImage = remoteImage.isNotEmpty;
                        final ImageProvider? imageProvider = hasLocalImage
                            ? FileImage(controller.profileImageFile.value!)
                            : (hasRemoteImage ? NetworkImage(remoteImage) : null);

                        return Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.textField,
                                backgroundImage: imageProvider,
                                child: imageProvider == null
                                    ? ClipOval(
                                        child: Image.asset(
                                          AppImages.profilePlaceholder,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: controller.pickProfileImage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text("Customer Information", style: sectionTitleStyle),
                    const SizedBox(height: 15),

                    Text("Customer Name", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      fieldKey: _nameFieldKey,
                      hintText: "Customer Name",
                      verticalPadding: 15,
                      controller: controller.nameController,
                      inputFormatters: <TextInputFormatter>[
                        _nameLimitFormatter,
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) => FormValidations.validateRequiredMin3(
                        v ?? '',
                        fieldName: "Customer name",
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text("Phone Number", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      fieldKey: _phoneFieldKey,
                      hintText: "Phone Number",
                      verticalPadding: 15,
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[\d+\-\s()]'),
                        ),
                        _phoneDigitLimitFormatter,
                        LengthLimitingTextInputFormatter(22),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Phone number is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Text("Email Address (Optional)", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Email (Optional)",
                      verticalPadding: 15,
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: <TextInputFormatter>[
                        _emailLimitFormatter,
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    Text("Secondary Phone (Optional)", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Secondary Phone (Optional)",
                      verticalPadding: 15,
                      controller: controller.secondaryPhoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[\d+\-\s()]'),
                        ),
                        _phoneDigitLimitFormatter,
                        LengthLimitingTextInputFormatter(22),
                      ],
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 25),

                    Text("Address Details", style: sectionTitleStyle),
                    const SizedBox(height: 15),

                    Text("Customer Address", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      fieldKey: _addressFieldKey,
                      hintText: "Customer Address",
                      verticalPadding: 15,
                      maxLine: 3,
                      controller: controller.addressController,
                      inputFormatters: <TextInputFormatter>[
                        _addressLimitFormatter,
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) => FormValidations.validateRequiredMin3(
                        v ?? '',
                        fieldName: "Address",
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text("Optional Details", style: sectionTitleStyle),
                    const SizedBox(height: 15),

                    Text("Company Name", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Company Name",
                      verticalPadding: 15,
                      controller: controller.companyController,
                      inputFormatters: <TextInputFormatter>[
                        _companyLimitFormatter,
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    Text("Tax NTN", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Tax NTN",
                      verticalPadding: 15,
                      controller: controller.taxController,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\-/]'),
                        ),
                        _taxLimitFormatter,
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    Text("Website", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Website",
                      verticalPadding: 15,
                      controller: controller.websiteController,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        _urlLimitFormatter,
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    Text("Social Link", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Social Link",
                      verticalPadding: 15,
                      controller: controller.socialController,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        _urlLimitFormatter,
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    Text("Notes", style: fieldLabelStyle),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Notes",
                      verticalPadding: 15,
                      maxLine: 4,
                      controller: controller.notesController,
                      inputFormatters: <TextInputFormatter>[
                        _notesLimitFormatter,
                      ],
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 30),

                    Obx(
                      () => CustomButton(
                        text: controller.isEdit
                            ? "Update Customer"
                            : "Save Customer",
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          _submitForm();
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
