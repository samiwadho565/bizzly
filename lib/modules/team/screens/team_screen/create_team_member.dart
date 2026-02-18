import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/team/controllers/team_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/form_validations.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  late final TeamController controller;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _roleFocus = FocusNode();
  final FocusNode _salaryFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeamController>();
    final dynamic args = Get.arguments;
    if (args is EmployeeModel) {
      controller.loadForEdit(args);
    } else {
      controller.resetCreateForm();
    }
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
                      CustomTextField(
                        hintText: "Full Name",
                        controller: controller.nameController,
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                        validator: (v) => FormValidations.validateRequiredMin3(
                          v ?? '',
                          fieldName: "Full Name",
                        ),
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: "Email",
                        controller: controller.emailController,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_phoneFocus),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => FormValidations.validateEmail(v ?? ''),
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: "Phone Number",
                        controller: controller.phoneController,
                        focusNode: _phoneFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_addressFocus),
                        keyboardType: TextInputType.phone,
                        validator: (v) => FormValidations.validateRequired(
                          v ?? '',
                          fieldName: "Phone Number",
                        ),
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: "Address",
                        controller: controller.addressController,
                        focusNode: _addressFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_roleFocus),
                        validator: (v) => FormValidations.validateRequired(
                          v ?? '',
                          fieldName: "Address",
                        ),
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: "Role / Designation",
                        controller: controller.roleController,
                        focusNode: _roleFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_salaryFocus),
                        validator: (v) => FormValidations.validateRequired(
                          v ?? '',
                          fieldName: "Role",
                        ),
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: "Salary",
                        controller: controller.salaryController,
                        focusNode: _salaryFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_notesFocus),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) => FormValidations.validateRequiredNumber(
                          v ?? '',
                          fieldName: "Salary",
                        ),
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
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: "Notes (optional)",
                        controller: controller.notesController,
                        focusNode: _notesFocus,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        verticalPadding: 15,
                        maxLine: 3,
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
                              : () async {
                                  final EmployeeModel? saved =
                                      await controller.submitEmployee();
                                  if (saved == null) return;
                                  controller.resetCreateForm();
                                  Get.back(result: saved);
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

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _roleFocus.dispose();
    _salaryFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }
}
