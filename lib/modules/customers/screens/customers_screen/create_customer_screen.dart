import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/customers/controllers/create_customer_controller.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/assets/images.dart';

class CreateCustomerScreen extends GetView<CreateCustomerController> {
  const CreateCustomerScreen({super.key});

  final TextStyle sectionTitleStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: controller.isEdit ? "Edit Customer" : "Add Customer",
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
                    Obx(
                      () => Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: controller.profileImageFile.value !=
                                      null
                                  ? FileImage(
                                      controller.profileImageFile.value!,
                                    )
                                  : (controller.editingCustomer.value?.profileImage !=
                                              null &&
                                          controller.editingCustomer.value!
                                              .profileImage!
                                              .isNotEmpty)
                                      ? NetworkImage(
                                          controller.editingCustomer.value!
                                              .profileImage!,
                                        )
                                      : const AssetImage(
                                              AppImages.profilePlaceholder)
                                          as ImageProvider,
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Customer Information", style: sectionTitleStyle),
                    const SizedBox(height: 15),

                    CustomTextField(
                      hintText: "Customer Name",
                      verticalPadding: 15,
                      controller: controller.nameController,
                      textInputAction: TextInputAction.next,
                      validator: (v) => FormValidations.validateRequiredMin3(
                        v ?? '',
                        fieldName: "Customer name",
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
                      hintText: "Secondary Phone (Optional)",
                      verticalPadding: 15,
                      controller: controller.secondaryPhoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 25),

                    Text("Address Details", style: sectionTitleStyle),
                    const SizedBox(height: 15),

                    CustomTextField(
                      hintText: "Customer Address",
                      verticalPadding: 15,
                      maxLine: 3,
                      controller: controller.addressController,
                      textInputAction: TextInputAction.next,
                      validator: (v) => FormValidations.validateRequiredMin3(
                        v ?? '',
                        fieldName: "Address",
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text("Optional Details", style: sectionTitleStyle),
                    const SizedBox(height: 15),

                    CustomTextField(
                      hintText: "Company Name",
                      verticalPadding: 15,
                      controller: controller.companyController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: "Tax NTN",
                      verticalPadding: 15,
                      controller: controller.taxController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: "Website",
                      verticalPadding: 15,
                      controller: controller.websiteController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: "Social Link",
                      verticalPadding: 15,
                      controller: controller.socialController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: "Notes",
                      verticalPadding: 15,
                      maxLine: 4,
                      controller: controller.notesController,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 30),

                    Obx(
                      () => CustomButton(
                        text: controller.isEdit
                            ? "Update Customer"
                            : "Save Customer",
                        isLoading: controller.isLoading.value,
                        onPressed: controller.createCustomer,
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
