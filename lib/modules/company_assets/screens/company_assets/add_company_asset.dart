import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/company_assets/controllers/company_assets_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/date_formats.dart';

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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Required Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Asset Name",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  fieldKey: controller.assetNameFieldKey,
                  hintText: "Enter asset name",
                  controller: controller.assetNameController,
                  inputFormatters: controller.assetNameInputFormatters,
                  verticalPadding: 15,
                  textInputAction: TextInputAction.next,
                  validator: controller.assetNameValidator,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Asset Type",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  fieldKey: controller.assetTypeFieldKey,
                  hintText: "Enter asset type",
                  controller: controller.assetTypeController,
                  inputFormatters: controller.assetTypeInputFormatters,
                  verticalPadding: 15,
                  textInputAction: TextInputAction.next,
                  validator: controller.assetTypeValidator,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Assigned To",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  key: controller.assignedToFieldKey,
                  child: Obx(() {
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
                          : "Select employee",
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
                ),
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
                const Text(
                  "Value (PKR)",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  fieldKey: controller.valueFieldKey,
                  hintText: "Enter asset value",
                  controller: controller.valueController,
                  inputFormatters: controller.assetValueInputFormatters,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  verticalPadding: 15,
                  textInputAction: TextInputAction.next,
                  validator: controller.assetValueValidator,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Purchase Date",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  key: controller.purchaseDateFieldKey,
                  onTap: () async {
                    final DateTime? date = await AppUtils.pickDate();
                    if (date == null) return;
                    controller.selectedPurchaseDate.value = date;
                    controller.purchaseDateController.text = DateFormats.yyyyMmDd(date);
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      hintText: "Select purchase date",
                      controller: controller.purchaseDateController,
                      verticalPadding: 15,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image.asset(
                          AppImages.calendar,
                          width: 15,
                          height: 15,
                        ),
                      ),
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
                Obx(() {
                  return CustomButton(
                    text: controller.isEdit ? "Update Asset" : "Add Asset",
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? () {}
                        : controller.submitAssetFromForm,
                  );
                }),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
