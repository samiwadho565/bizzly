import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/vendors/controllers/create_vendor_controller.dart';

class CreateVendorScreen extends GetView<CreateVendorController> {
  const CreateVendorScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: controller.isEdit ? "Edit Vendor" : "Add Vendor",
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
                      const Text(
                        "Vendor Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Vendor Name",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.nameFieldKey,
                        hintText: "Enter vendor name",
                        verticalPadding: 15,
                        controller: controller.nameController,
                        inputFormatters: controller.nameInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.vendorNameValidator,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.phoneFieldKey,
                        hintText: "Enter phone number",
                        verticalPadding: 15,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: controller.phoneInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.phoneValidator,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Email Address (Optional)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.emailFieldKey,
                        hintText: "Enter email address",
                        verticalPadding: 15,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: controller.emailInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.optionalEmailValidator,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Company Name",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.companyFieldKey,
                        hintText: "Enter company name",
                        verticalPadding: 15,
                        controller: controller.companyController,
                        inputFormatters: controller.companyInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.companyNameValidator,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Tax Number (NTN / GST)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.taxFieldKey,
                        hintText: "Enter tax number",
                        verticalPadding: 15,
                        controller: controller.taxController,
                        inputFormatters: controller.taxInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.taxNumberValidator,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Address Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Vendor Address",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.addressFieldKey,
                        hintText: "Enter vendor address",
                        verticalPadding: 15,
                        maxLine: 3,
                        controller: controller.addressController,
                        inputFormatters: controller.addressInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.addressValidator,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Optional Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Notes",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.notesFieldKey,
                        hintText: "Add notes (optional)",
                        verticalPadding: 15,
                        maxLine: 4,
                        controller: controller.notesController,
                        inputFormatters: controller.notesInputFormatters,
                        textInputAction: TextInputAction.done,
                        validator: controller.notesValidator,
                      ),
                      const SizedBox(height: 30),
                      Obx(
                        () => CustomButton(
                          text:
                              controller.isEdit ? "Update Vendor" : "Save Vendor",
                          isLoading: controller.isLoading.value,
                          onPressed: controller.submitForm,
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
