import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/business_picker_bottom_sheet.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/team/controllers/team_controller.dart';
import 'package:bizly/utils/app_colors.dart';

class AddEmployeeScreen extends GetView<TeamController> {
  AddEmployeeScreen({super.key}) {
    controller.prepareCreateForm(Get.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDense,
      appBar: CustomAppBar2(
        title: controller.isEdit
            ? "Update Employee Account"
            : "Create Employee Account",
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
              child: Form(
                key: controller.createFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      const Text(
                        "Required Details",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Business",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final BusinessModel? selected =
                            controller.selectedBusiness.value;
                        final String error = controller.businessError.value;
                        return Column(
                          key: controller.businessFieldKey,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final businesses = controller.businesses;
                                if (businesses.isEmpty) return;
                                final BusinessModel? picked =
                                    await showBusinessPickerBottomSheet(
                                  context,
                                  businesses: businesses,
                                  selectedBusinessId: selected?.id,
                                  title: 'Select Business',
                                );
                                if (picked != null) {
                                  controller.selectedBusiness.value = picked;
                                  controller.businessError.value = '';
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: error.isNotEmpty
                                        ? Colors.red
                                        : Colors.grey.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  color: AppColors.textField,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selected?.businessName ??
                                            'Select a business',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selected == null
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down,
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            if (error.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  error,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 12),
                      const Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.nameFieldKey,
                        hintText: "Enter full name",
                        controller: controller.nameController,
                        inputFormatters: controller.employeeNameInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.employeeNameValidator,
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Email Address",
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
                        controller: controller.emailController,
                        inputFormatters: controller.employeeEmailInputFormatters,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.employeeEmailValidator,
                        verticalPadding: 15,
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
                        controller: controller.phoneController,
                        inputFormatters: controller.employeePhoneInputFormatters,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        validator: controller.employeePhoneValidator,
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.addressFieldKey,
                        hintText: "Enter address",
                        controller: controller.addressController,
                        inputFormatters: controller.employeeAddressInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.employeeAddressValidator,
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Role / Designation",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.roleFieldKey,
                        hintText: "Enter role / designation",
                        controller: controller.roleController,
                        inputFormatters: controller.employeeRoleInputFormatters,
                        textInputAction: TextInputAction.next,
                        validator: controller.employeeRoleValidator,
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Salary",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: controller.salaryFieldKey,
                        hintText: "Enter salary",
                        controller: controller.salaryController,
                        inputFormatters: controller.employeeSalaryInputFormatters,
                        textInputAction: TextInputAction.next,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: controller.employeeSalaryValidator,
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: CustomSearchDropdown(
                            height: 50,
                            horizontalPadding: 12,
                            verticalPadding: 15,
                            iconSize: 25,
                            hintText: "Select Status",
                            items: const ["Active", "Inactive"],
                            selectedItem:
                                controller.status.value == 'active' ? "Active" : "Inactive",
                            onChanged: (value) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.status.value =
                                  (value ?? "Active").toLowerCase();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Optional Details",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
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
                        controller: controller.notesController,
                        inputFormatters: controller.employeeNotesInputFormatters,
                        textInputAction: TextInputAction.done,
                        verticalPadding: 15,
                        maxLine: 3,
                        validator: controller.employeeNotesValidator,
                      ),
                      const SizedBox(height: 25),
                      Obx(
                        () => CustomButton(
                          text: controller.isEdit
                              ? "Update Employee"
                              : "Create Employee",
                          isLoading: controller.isSubmitting.value,
                          onPressed: controller.isSubmitting.value
                              ? () {}
                              : controller.submitEmployeeAndClose,
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
