import 'package:bizly/controllers/expense_detail_screen_controller.dart';
import 'package:bizly/widgets/add_button.dart';
import 'package:bizly/widgets/custom_app_bar_2.dart';
import 'package:bizly/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';

// Assuming you have a central color file, otherwise define it here


class ExpenseDetailScreen extends GetView<ExpenseDetailController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:CustomAppBar2(title: "Expense Detail"),
      body: Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          // padding: const EdgeInsets.all(16.0),
          child: Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child: addButton("Edit expense",icon: Icon(Icons.edit,  color: Colors.black54,
                    size: 17,
                  )),
                ),
                SizedBox(height: 20,),
                // Main Info Section
                _buildInfoCard(
                  icon: Icons.category,
                  title: "Category",
                  value: controller.category.value,
                ),
                _buildInfoCard(
                  icon: Icons.description,
                  title: "Title",
                  value: controller.title.value,
                ),
                _buildInfoCard(
                  icon: Icons.attach_money,
                  title: "Amount",
                  value: "Rs. ${controller.amount.value}",
                  // valueColor: AppColors.textPrimary,
                  valueFontSize: 17,
                  valueFontWeight: FontWeight.bold,
                ),

                if (controller.expenseDate.value != null)
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: "Expense Date",
                    value: "${controller.expenseDate.value!.day}-${controller.expenseDate.value!.month}-${controller.expenseDate.value!.year}",
                  ),

                if (controller.paymentMethod.value.isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.payment,
                    title: "Payment Method",
                    value: controller.paymentMethod.value,
                  ),
                //
                // const Padding(
                //   padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
                //   child: Text(
                //     "Optional Details",
                //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
                //   ),
                // ),

                // Optional Info Cards
                _buildInfoCard(
                  icon: Icons.store,
                  title: "Vendor / Supplier",
                  value: controller.vendorName.value.isEmpty ? "Not Provided" : controller.vendorName.value,
                ),
                _buildInfoCard(
                  icon: Icons.receipt_long,
                  title: "Reference / Bill Number",
                  value: controller.referenceNumber.value.isEmpty ? "N/A" : controller.referenceNumber.value,
                ),
                _buildInfoCard(
                  icon: Icons.percent,
                  title: "Tax Amount",
                  value: controller.taxAmount.value.toString(),
                ),
                _buildInfoCard(
                  icon: Icons.work,
                  title: "Project Name",
                  value: controller.projectName.value.isEmpty ? "N/A" : controller.projectName.value,
                ),
                _buildInfoCard(
                  icon: Icons.person,
                  title: "Customer Name",
                  value: controller.customerName.value.isEmpty ? "N/A" : controller.customerName.value,
                ),
                // --- Receipt Preview Section ---
                // if (controller.receiptPath.value.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 12.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         const Text("Receipt / Attachment",
                //             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                //         const SizedBox(height: 10),
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(15),
                //           child: Container(
                //             width: double.infinity,
                //             height: 200,
                //             color: Colors.grey[200],
                //             // Agar file path hai to Image.file use karein, warna placeholder
                //             child: Icon(Icons.image, size: 50, color: Colors.grey),
                //             // Image.file(File(controller.receiptPath.value), fit: BoxFit.cover),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),

                if (controller.notes.value.isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.note,
                    title: "Notes",
                    value: controller.notes.value,
                  ),

                const SizedBox(height: 10),

                // Repeat Monthly Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.repeat, color: Colors.grey),
                          SizedBox(width: 12),
                          Text("Repeat Monthly", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                      Switch(
                        value: controller.isRepeatMonthly.value,
                        onChanged: (val) {}, // View only mode
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                CustomButton(text: "Download PDF", onPressed: (){}),
                const SizedBox(height: 30),
              ],
            ),
          )),
        ),
      ),
    );
  }

  // Helper method to build consistent info rows
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = Colors.black87,
    double valueFontSize = 15,
    FontWeight valueFontWeight = FontWeight.w500,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:  EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greyCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary.withOpacity(0.8), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: valueFontSize,
                    fontWeight: valueFontWeight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}