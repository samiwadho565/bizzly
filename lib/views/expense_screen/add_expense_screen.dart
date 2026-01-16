import 'package:bizly/controllers/expense_screen_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/custom_button.dart';
import 'package:bizly/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_drop_down.dart';

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
                  // --- Main Fields ---
                  Obx(() => GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        controller.selectedDate.value = pickedDate;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.selectedDate.value != null
                                ? "${controller.selectedDate.value!.day}-${controller.selectedDate.value!.month}-${controller.selectedDate.value!.year}"
                                : "Expense Date",
                            style: TextStyle(
                              color: controller.selectedDate.value != null ? Colors.black : Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),

                  CustomTextField(hintText: "Expense Type", verticalPadding: 15),
                  const SizedBox(height: 12),

                  CustomTextField(hintText: "Amount", verticalPadding: 15),
                  const SizedBox(height: 12),

                  // Selection Rows (Category & Payment)
                  // _buildSelectionRow("Category", "IT Service"),
                  const SizedBox(height: 12),

                  _buildSelectionRow("Payment Method", "Bank Transfer"),
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
                    onPressed: () {},
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
    return SizedBox(
      width: Get.width/1.5,
      child: CustomSearchDropdown(
        height: 40,
        horizontalPadding: 12,
        verticalPadding: 20,
        iconSize: 25,
        textStyle: const TextStyle(fontSize: 13, color: Colors.black),
        enableSearch: true,
        hintText: "Select Payment method",
        items: const ["EasyPaisa", "JazzCash", "Bank transfer", "Cash"],
        onChanged: (value) {},
      ),
    );
  }

  // Upload Receipt Widget
  Widget _buildUploadRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.4),
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
        color: AppColors.background.withOpacity(0.4),
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