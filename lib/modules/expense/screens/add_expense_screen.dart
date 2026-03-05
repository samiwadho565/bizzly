import 'package:bizly/modules/expense/controllers/expense_screen_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/loader/loader.dart';

class AddExpenseScreen extends GetView<AddExpenseScreenController>{
  AddExpenseScreen({super.key});

  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    if (!controller.didResetForm.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.resetFormState();
      });
    }
    final bool isEdit = controller.editingExpenseId.value != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(title: isEdit ? "Edit Expense" : "Add Expense"),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Obx(
            () => Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40),
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
                  // --- Required Fields ---
                  Text("Required Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),
                  _buildCategoryDropdown(context),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: controller.titleController,
                    hintText: "Title",
                    validator: (value) =>
                        FormValidations.validateRequired(value ?? '', fieldName: "Title"),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: controller.amountController,
                    hintText: "Amount",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => FormValidations.validateRequiredNumber(
                      value ?? '',
                      fieldName: "Amount",
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  _buildSelectionRow(
                    hintText: "Expense Type",
                    items: const ["Business", "Personal"],
                    selectedItem: controller.hasSelectedExpenseType.value
                        ? _displayExpenseType(controller.expenseType.value)
                        : null,
                    displayValue: controller.hasSelectedExpenseType.value
                        ? _displayExpenseType(controller.expenseType.value)
                        : '',
                    onChanged: (value) {
                      if (value != null) {
                        controller.expenseType.value = value.toLowerCase();
                        controller.hasSelectedExpenseType.value = true;
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final date = await AppUtils.pickDate();
                              if (date != null) {
                                controller.selectedDate.value = date;
                                controller.hasSelectedDate.value = true;
                              }
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppColors.textField,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.hasSelectedDate.value
                                          ? "${controller.selectedDate.value.day}-${controller.selectedDate.value.month}-${controller.selectedDate.value.year}"
                                          : "Expanse Date",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: controller.hasSelectedDate.value
                                            ? Colors.black
                                            : Colors.grey.shade700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: _buildPaymentMethodDropdown()),
                      // --- Main Fields ---
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildBusinessDropdown(),

                  const SizedBox(height: 20),

                  // --- Optional Details Section ---
                  Text("Optional Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  _buildCustomerDropdown(),
                  const SizedBox(height: 12),

                  _buildVendorDropdown(),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: controller.projectNameController,
                    hintText: "Project Name",
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: controller.referenceNumberController,
                    hintText: "Reference Number",
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: controller.taxAmountController,
                    hintText: "Tax Amount",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                      controller: controller.notesController,
                      maxLine: 4,
                      hintText: "Notes",
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      verticalPadding: 15),
                  const SizedBox(height: 12),

                  // Upload Receipt Row
                  _buildUploadRow(),
                  const SizedBox(height: 12),

                  // Repeat Monthly Switch
                  _buildSwitchRow(),
                  const SizedBox(height: 30),

                  // Add Expense Button
                  CustomButton(
                    text: isEdit ? "Update Expense" : "Add Expense",
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? () {}
                        : () {
                            controller.createExpense();
                          },
                  ),
                  const SizedBox(height: 20),
                      ],
                    ),
                    ),
                  ),
                ),
              ),
                if (controller.isDropdownsLoading.value)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.6),
                      child: const Center(
                        child: FinancePulseLoader(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayExpenseType(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  // Selection Row Widget (Category, Project etc)
  Widget _buildSelectionRow({
    required String hintText,
    required List<String> items,
    String? selectedItem,
    String? displayValue,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomSearchDropdown(
      height: 50,
      horizontalPadding: 12,
      verticalPadding: 20,
      iconSize: 25,
      textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
      // enableSearch: true,

      hintText: hintText,
      items: items,
      selectedItem: selectedItem,
      displayValue: displayValue,
      onChanged: (value) {
        FocusScope.of(Get.context!).unfocus();
        onChanged(value);
      },
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Obx(() {
      final items = controller.categories
          .map((e) => e['name']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      items.add("Add New Category");
      final selectedId = controller.selectedCategoryId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.categories) {
          if (item['id'] == selectedId) {
            selectedName = item['name']?.toString();
            break;
          }
        }
      }
      return _buildSelectionRow(
        hintText: controller.isCategoriesLoading.value
            ? "Loading categories..."
            : "Category",
        items: items,
        selectedItem: selectedName,
        onChanged: (value) {
          if (value == "Add New Category") {
            _showAddCategorySheet(context);
            return;
          }
          int? id;
          for (final item in controller.categories) {
            if (item['name']?.toString() == value) {
              id = item['id'] as int?;
              break;
            }
          }
          controller.selectedCategoryId.value = id;
        },
      );
    });
  }

  void _showAddCategorySheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Add New Category",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: nameController,
                  hintText: "Category Name",
                  validator: (v) =>
                      FormValidations.validateRequiredMin3(v ?? '', fieldName: "Category"),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  verticalPadding: 15,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => CustomButton(
                    text: "Submit",
                    isLoading: controller.isCategoryCreating.value,
                    onPressed: controller.isCategoryCreating.value
                        ? () {}
                        : () async {
                            final bool ok =
                                formKey.currentState?.validate() ?? false;
                            if (!ok) return;
                            final bool success = await controller
                                .createCategory(nameController.text.trim());
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Obx(() {
      final items = controller.paymentMethods
          .map((e) => e['name']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      final selectedId = controller.selectedPaymentMethodId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.paymentMethods) {
          if (item['id'] == selectedId) {
            selectedName = item['name']?.toString();
            break;
          }
        }
      }
      return _buildSelectionRow(
        hintText: "Payment Method",
        items: items,
        selectedItem: selectedName,
        onChanged: (value) {
          int? id;
          for (final item in controller.paymentMethods) {
            if (item['name']?.toString() == value) {
              id = item['id'] as int?;
              break;
            }
          }
          controller.selectedPaymentMethodId.value = id;
        },
      );
    });
  }

  Widget _buildBusinessDropdown() {
    return Obx(() {
      final items = controller.businesses
          .map((e) => e.businessName)
          .where((e) => e.isNotEmpty)
          .toList();
      final selectedId = controller.selectedBusinessId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.businesses) {
          if (item.id == selectedId) {
            selectedName = item.businessName;
            break;
          }
        }
      }
      return IgnorePointer(
        ignoring: controller.isBusinessLocked.value,
        child: Opacity(
          opacity: controller.isBusinessLocked.value ? 0.75 : 1,
          child: _buildSelectionRow(
            hintText: "Business",
            items: items,
            selectedItem: selectedName,
            onChanged: (value) {
              int? id;
              for (final item in controller.businesses) {
                if (item.businessName == value) {
                  id = item.id;
                  break;
                }
              }
              controller.selectedBusinessId.value = id;
            },
          ),
        ),
      );
    });
  }

  Widget _buildCustomerDropdown() {
    return Obx(() {
      final items = controller.customers
          .map((e) => e.customerName)
          .where((e) => e.isNotEmpty)
          .toList();
      final selectedId = controller.selectedCustomerId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.customers) {
          if (item.id == selectedId) {
            selectedName = item.customerName;
            break;
          }
        }
      }
      return _buildSelectionRow(
        hintText: "Customer",
        items: items,
        selectedItem: selectedName,
        onChanged: (value) {
          int? id;
          for (final item in controller.customers) {
            if (item.customerName == value) {
              id = item.id;
              break;
            }
          }
          controller.selectedCustomerId.value = id;
        },
      );
    });
  }

  Widget _buildVendorDropdown() {
    return Obx(() {
      final items = controller.vendors
          .map((e) => e.vendorName)
          .where((e) => e.isNotEmpty)
          .toList();
      final selectedId = controller.selectedVendorId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.vendors) {
          if (item.id == selectedId) {
            selectedName = item.vendorName;
            break;
          }
        }
      }
      return _buildSelectionRow(
        hintText: "Vendor",
        items: items,
        selectedItem: selectedName,
        onChanged: (value) {
          int? id;
          for (final item in controller.vendors) {
            if (item.vendorName == value) {
              id = item.id;
              break;
            }
          }
          controller.selectedVendorId.value = id;
        },
      );
    });
  }

  // Upload Receipt Widget
  Widget _buildUploadRow() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textField,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                controller.receiptFile.value != null
                    ? controller.receiptFile.value!.path.split('/').last
                    : (controller.receiptUrl.value.isNotEmpty
                        ? controller.receiptUrl.value.split('/').last
                        : "Receipt (File)"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(width: 10),
            if (controller.receiptFile.value != null ||
                controller.receiptUrl.value.isNotEmpty)
              TextButton(
                onPressed: controller.clearReceipt,
                child: const Text(
                  "Clear",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ElevatedButton(
              onPressed: controller.pickReceipt,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Upload", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // Switch Row Widget
  Widget _buildSwitchRow() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textField,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Repeat Monthly", style: TextStyle(color: Colors.black87)),
            Switch(
              value: controller.isRecurringMonthly.value,
              onChanged: (val) => controller.isRecurringMonthly.value = val,
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

}
