import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/vendors/controllers/create_vendor_controller.dart';
import 'package:bizly/utils/form_validations.dart';

class CreateVendorScreen extends GetView<CreateVendorController> {
  CreateVendorScreen({super.key});

  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: controller.isEdit ? "Edit Vendor" : "Add Vendor",
      ),

      body: SafeArea(
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

                  /// 🔹 Vendor Basic Info
                  Text("Vendor Information", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(
                    hintText: "Vendor Name",
                    verticalPadding: 15,
                    controller: controller.nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        FormValidations.validateRequiredMin3(
                          v ?? '',
                          fieldName: "Vendor name",
                        ),
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Phone Number",
                    verticalPadding: 15,
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Phone number is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Email (Optional)",
                    verticalPadding: 15,
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: "Company Name",
                      verticalPadding: 15,
                      controller: controller.companyController,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          FormValidations.validateRequiredMin3(
                            v ?? '',
                            fieldName: "Company name",
                          ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: "Tax Number (NTN / GST)",
                      verticalPadding: 15,
                      controller: controller.taxController,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          FormValidations.validateRequiredMin3(
                            v ?? '',
                            fieldName: "Tax Number (NTN / GST)",
                          ),
                    ),



                    const SizedBox(height: 25),

                  /// 🔹 Address
                  Text("Address Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(
                    hintText: "Vendor Address",
                    verticalPadding: 15,
                    maxLine: 3,
                    controller: controller.addressController,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        FormValidations.validateRequiredMin3(
                          v ?? '',
                          fieldName: "Address",
                        ),
                  ),

                  const SizedBox(height: 25),

                  /// 🔹 Optional Info
                  Text("Optional Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),


                  CustomTextField(
                    hintText: "Notes",
                    verticalPadding: 15,
                    maxLine: 4,
                    controller: controller.notesController,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Save Button
                  Obx(
                    () => CustomButton(
                      text: controller.isEdit ? "Update Vendor" : "Save Vendor",
                      isLoading: controller.isLoading.value,
                      onPressed: controller.createVendor,
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
    );
  }
}
