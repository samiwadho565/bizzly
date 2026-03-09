import 'package:bizly/modules/expense/controllers/expense_detail_screen_controller.dart';
import 'package:bizly/components/common/add_button.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/modules/customers/screens/customers_screen/customer_detail_screen.dart';
import 'package:bizly/modules/vendors/screens/vendors/vendor_detail_screen.dart';
import 'package:bizly/modules/expense/controllers/expenses_list_controller.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';

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
          child: Obx(() {
            final ExpenseModel? expense = controller.model.value;
            final num amount = _toNum(expense?.amount) ?? 0;
            final num taxAmount = _toNum(expense?.taxAmount) ?? 0;
            final num subtotal = amount - taxAmount;

            return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Get.toNamed(
                        Routes.addExpenseScreen,
                        arguments: controller.model.value,
                      );
                      if(result != null){
                        controller.model.value = result;
                      }
                      print("controller.model.value : ${controller.model.value?.toJson()}");

                      // if (result == true &&
                      //     Get.isRegistered<ExpensesListController>()) {
                      //   Get.find<ExpensesListController>().fetchExpenses();
                      // }


                    },
                    child: addButton(
                      "Edit expense",
                      icon: Icon(
                        Icons.edit,
                        color: Colors.black54,
                        size: 17,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                // Main Info Section
                _buildInfoCard(
                  icon: Icons.category,
                  title: "Category",
                  value: controller.model.value?.categoryName ?? '',
                ),
                _buildInfoCard(
                  icon: Icons.description,
                  title: "Title",
                  value: controller.model.value?.title ?? '',
                ),
                _buildInfoCard(
                  icon: Icons.attach_money,
                  title: "Amount",
                  value: "Rs. ${controller.model.value?.amount ?? ''}",
                  // valueColor: AppColors.textPrimary,
                  valueFontSize: 17,
                  valueFontWeight: FontWeight.bold,
                ),
                _buildInfoCard(
                  icon: Icons.summarize,
                  title: "Subtotal",
                  value: _money(subtotal < 0 ? 0 : subtotal),
                ),

                if (controller.model.value?.expenseDate != null &&
                    controller.model.value!.expenseDate!.isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: "Expense Date",
                    value: controller.model.value!.expenseDate!,
                  ),

                if ((controller.model.value?.paymentMethodName ?? '').isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.payment,
                    title: "Payment Method",
                    value: controller.model.value?.paymentMethodName ?? '',
                  ),
                if ((controller.model.value?.expenseType ?? '').isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.category_outlined,
                    title: "Expense Type",
                    value: controller.model.value?.expenseType ?? '',
                  ),
                if ((controller.model.value?.businessName ?? '').isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.apartment,
                    title: "Business",
                    value: controller.model.value?.businessName ?? '',
                    onTap: controller.model.value == null
                        ? null
                        : () {
                            final ExpenseModel m = controller.model.value!;
                            if (m.businessId == null || m.businessName == null) return;
                            Get.toNamed(
                              Routes.businessDetailScreen,
                              arguments: BusinessModel(
                                id: m.businessId,
                                businessName: m.businessName ?? '',
                                businessAddress: '',
                                phoneNumber: '',
                                currency: '',
                              ),
                            );
                          },
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
                  value: (controller.model.value?.vendorName ?? '').isEmpty
                      ? "Not Provided"
                      : controller.model.value?.vendorName ?? '',
                  onTap: controller.model.value == null
                      ? null
                      : () {
                          final ExpenseModel m = controller.model.value!;
                          if (m.vendorId == null || m.vendorName == null) return;
                          Get.to(
                            () => VendorDetailScreen(
                              vendor: VendorModel(
                                id: m.vendorId,
                                vendorName: m.vendorName ?? '',
                                phoneNumber: '',
                              ),
                            ),
                          );
                        },
                ),
                _buildInfoCard(
                  icon: Icons.receipt_long,
                  title: "Reference / Bill Number",
                  value: (controller.model.value?.referenceNumber ?? '').isEmpty
                      ? "N/A"
                      : controller.model.value?.referenceNumber ?? '',
                ),
                _buildInfoCard(
                  icon: Icons.percent,
                  title: "Tax Amount",
                  value: _money(taxAmount),
                ),
                _buildInfoCard(
                  icon: Icons.work,
                  title: "Project Name",
                  value: (controller.model.value?.projectName ?? '').isEmpty
                      ? "N/A"
                      : controller.model.value?.projectName ?? '',
                ),
                _buildInfoCard(
                  icon: Icons.person,
                  title: "Customer Name",
                  value: (controller.model.value?.customerName ?? '').isEmpty
                      ? "N/A"
                      : controller.model.value?.customerName ?? '',
                  onTap: controller.model.value == null
                      ? null
                      : () {
                          final ExpenseModel m = controller.model.value!;
                          if (m.customerId == null || m.customerName == null) return;
                          Get.to(
                            () => CustomerDetailScreen(
                              customer: CustomerModel(
                                id: m.customerId,
                                customerName: m.customerName ?? '',
                                phoneNumber: '',
                                address: '',
                              ),
                            ),
                          );
                        },
                ),
                if ((controller.model.value?.receiptUrl ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Receipt / Attachment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                            onTap: () => _showReceiptPreview(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: double.infinity,
                                height: 200,
                                child: CachedNetworkImage(
                                  imageUrl: controller.model.value?.receiptUrl ?? '',
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Colors.grey[200],
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (controller.model.value?.notes != null) const SizedBox(height: 10),
                
                if (controller.model.value?.notes != null)
                  _buildInfoCard(
                    icon: Icons.note,
                    title: "Notes",
                    value: controller.model.value?.notes ?? '',
                  ),

                const SizedBox(height: 10),

                // Repeat Monthly Switch
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(15),
                //     boxShadow: [
                //       BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                //     ],
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       const Row(
                //         children: [
                //           Icon(Icons.repeat, color: Colors.grey),
                //           SizedBox(width: 12),
                //           Text("Repeat Monthly", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                //         ],
                //       ),
                //       Switch(
                //         value: controller.model.value?.isRecurringMonthly == true,
                //         onChanged: (val) {}, // View only mode
                //         activeColor: AppColors.primary,
                //       ),
                //     ],
                //   ),
                // ),
                //const SizedBox(height: 16),
                if ((controller.model.value?.updatedAt ?? '').isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.update,
                    title: "Updated At",
                    value: controller.formattedUpdatedAt(),
                  ),
                Obx(
                  () => CustomButton(
                    text: "Download PDF",
                    isLoading: controller.isDownloadingPdf.value,
                    onPressed: controller.isDownloadingPdf.value
                        ? () {}
                        : controller.downloadPdf,
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: "Delete Expense",
                  color: Colors.white,
                  textColor: Colors.red,
                  borderColor: Colors.red,
                  onPressed: () {
                    controller.confirmDelete();
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
          }),
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
    VoidCallback? onTap,
  }) {
    final card = Container(
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
          if (onTap != null)
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: card,
    );
  }

  num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    final String raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return num.tryParse(raw);
  }

  String _money(num value) => 'Rs. ${value.toStringAsFixed(2)}';

  void _showReceiptPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 420,
                width: double.infinity,
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: controller.model.value?.receiptUrl ?? '',
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(color: Colors.black),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.image, color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Download",
                        onPressed: () {
                          Get.back();
                          controller.downloadReceipt();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: "Close",
                        color: Colors.grey.shade700,
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
