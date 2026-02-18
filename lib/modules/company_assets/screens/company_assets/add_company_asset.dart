import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/company_assets/controllers/company_assets_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/date_formats.dart';
import 'package:bizly/utils/form_validations.dart';

class AddAssetScreen extends GetView<CompanyAssetsController> {
  AddAssetScreen({super.key}) {
    controller.openAddAssetForm(Get.arguments);
  }

  TextStyle _errorTextStyle(BuildContext context) {
    final TextStyle base = Theme.of(context).inputDecorationTheme.errorStyle ??
        const TextStyle(fontSize: 12);
    return base.copyWith(color: Theme.of(context).colorScheme.error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
          title: controller.isEdit ? "Update Asset" : "Add Asset",

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: "Asset Name",
                  controller: controller.assetNameController,
                  verticalPadding: 15,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      FormValidations.validateRequiredMin3(v ?? '', fieldName: "Asset Name"),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "Asset Type",
                  controller: controller.assetTypeController,
                  verticalPadding: 15,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      FormValidations.validateRequiredMin3(v ?? '', fieldName: "Asset Type"),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final List<String> names = controller.employees
                      .map((EmployeeModel e) => e.fullName)
                      .where((String e) => e.isNotEmpty)
                      .toList();
                  String? selectedName;
                  if (controller.selectedEmployeeId.value != null) {
                    for (final EmployeeModel emp in controller.employees) {
                      if (emp.id == controller.selectedEmployeeId.value) {
                        selectedName = emp.fullName;
                        break;
                      }
                    }
                  }
                  return CustomSearchDropdown(
                    hintText: controller.isEmployeesLoading.value
                        ? "Loading employees..."
                        : "Assigned To",
                    items: names,
                    selectedItem: selectedName,
                    height: 50,
                    horizontalPadding: 12,
                    verticalPadding: 15,
                    iconSize: 22,
                    enableSearch: true,
                    onChanged: (String? value) {
                      int? id;
                      for (final EmployeeModel emp in controller.employees) {
                        if (emp.fullName == value) {
                          id = emp.id;
                          break;
                        }
                      }
                      controller.selectedEmployeeId.value = id;
                    },
                  );
                }),
                Obx(
                  () => controller.showFieldErrors.value && controller.selectedEmployeeId.value == null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            "Assigned To is required",
                            style: _errorTextStyle(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "Value (PKR)",
                  controller: controller.valueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  verticalPadding: 15,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      FormValidations.validateRequiredNumber(v ?? '', fieldName: "Value"),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final DateTime? date = await AppUtils.pickDate();
                    if (date == null) return;
                    controller.selectedPurchaseDate.value = date;
                    controller.purchaseDateController.text = DateFormats.yyyyMmDd(date);
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      hintText: "Purchase Date",
                      controller: controller.purchaseDateController,
                      verticalPadding: 15,
                    ),
                  ),
                ),
                Obx(
                  () => controller.showFieldErrors.value && controller.selectedPurchaseDate.value == null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            "Purchase Date is required",
                            style: _errorTextStyle(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 25),
                Obx(
                  () => CustomButton(
                    text: controller.isEdit ? "Update Asset" : "Add Asset",
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? () {}
                        : () async {
                            controller.showFieldErrors.value = true;
                            final bool formValid =
                                controller.formKey.currentState?.validate() ?? false;
                            if (!formValid) return;
                            if (controller.selectedEmployeeId.value == null ||
                                controller.selectedPurchaseDate.value == null) {
                              return;
                            }
                            await controller.submitAsset();
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
