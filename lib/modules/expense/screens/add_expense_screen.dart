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
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_drop_down.dart';

class AddExpenseScreen extends GetView<ExpenseScreenController>{
  AddExpenseScreen({super.key});

  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Add Expense"),
      body: SafeArea(
        child: SingleChildScrollView(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Main Fields ---
                  // CustomTextField(
                  //   hintText: "Expense Date",
                  //
                  //   // suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                  //   verticalPadding: 15,
                  // ),

                  const SizedBox(height: 12),
                  const SizedBox(height: 12),

                  CustomTextField(hintText: "Expense Type", verticalPadding: 15),
                  const SizedBox(height: 12),

                  CustomTextField(hintText: "Amount", verticalPadding: 15),
                  const SizedBox(height: 12),

                  // Selection Rows (Category & Payment)
                  // _buildSelectionRow("Category", "IT Service"),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => GestureDetector(
                            onTap: () async {
                              final date = await AppUtils.pickDate();
                              if (date != null) {
                                controller.selectedDate.value = date;
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${controller.selectedDate.value.day}-${controller.selectedDate.value.month}-${controller.selectedDate.value.year}",
                                    style: TextStyle(
                                      color: controller.selectedDate.value != null
                                          ? Colors.black
                                          : Colors.grey.shade700,
                                      fontSize: 15,
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
                      Expanded(child: _buildSelectionRow("Payment Method", "Bank Transfer")),
                      // --- Main Fields ---
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- Optional Details Section ---
                  Text("Optional Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(hintText: "Vendor Name", verticalPadding: 15),
                  const SizedBox(height: 12),

                  CustomTextField(hintText: "Reference", verticalPadding: 15),
                  const SizedBox(height: 12),

                  CustomTextField(
                      maxLine: 4,
                      hintText: "Additional details about this expense", verticalPadding: 15),
                  const SizedBox(height: 12),

                  // Upload Receipt Row
                  _buildUploadRow(),
                  const SizedBox(height: 12),

                  CustomTextField(hintText: "Tax Amount", verticalPadding: 15),
                  const SizedBox(height: 12),
                  //
                  // _buildSelectionRow("Project Name", "Web Design"),
                  // const SizedBox(height: 12),
                  //
                  // _buildSelectionRow("Customer Name", "Smith"),
                  // const SizedBox(height: 12),

                  // Repeat Monthly Switch
                  _buildSwitchRow(),
                  const SizedBox(height: 30),

                  // Add Expense Button
                  CustomButton(
                    text: "Add Expense",
                    onPressed: () {
                      Get.toNamed(Routes.addExpenseScreen);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Selection Row Widget (Category, Project etc)
  Widget _buildSelectionRow(String label, String value) {
    return CustomSearchDropdown(
      height: 50,
      horizontalPadding: 12,
      verticalPadding: 20,
      iconSize: 25,
      textStyle: const TextStyle(fontSize: 13, color: Colors.black),
      // enableSearch: true,

      hintText: "Select Payment method",
      items: const ["EasyPaisa", "JazzCash", "Bank transfer", "Cash"],
      onChanged: (value) {},
    );
  }

  // Upload Receipt Widget
  Widget _buildUploadRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textField,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Upload Receipt", style: TextStyle(color: Colors.black87)),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Upload Receipt", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // Switch Row Widget
  Widget _buildSwitchRow() {
    return Container(
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
              value: true,
              onChanged: (val) {},
              activeColor: Colors.green
          ),
        ],
      ),
    );
  }

}
