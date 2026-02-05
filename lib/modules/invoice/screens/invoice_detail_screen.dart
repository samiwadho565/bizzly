import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/invoice/controllers/invoice_detail_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_button.dart';

class InvoiceDetailScreen extends StatelessWidget {
  InvoiceDetailScreen({super.key});

  final InvoiceDetailController controller = Get.find<InvoiceDetailController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(title: "Invoice Detail"),
      backgroundColor: AppColors.background,
      body: Obx(
            () => SafeArea(
              child:  Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                child: Column(
                          children: [
                            SizedBox(height: 20,),
                /// 🔹 Gradient Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.clientName.value,
                                      style: const TextStyle(
                                        // color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: controller.getStatusColor(),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      controller.status.value,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                /// 🔹 Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 100),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        _buildInfoCard(
                          icon: Icons.receipt_long,
                          title: "Invoice Number",
                          value: controller.invoiceNumber.value,
                        ),
                        if (controller.invoiceDate.value != null)
                          _buildInfoCard(
                            icon: Icons.calendar_today,
                            title: "Invoice Date",
                            value:
                            "${controller.invoiceDate.value!.day}-${controller.invoiceDate.value!.month}-${controller.invoiceDate.value!.year}",
                          ),
                        _buildInfoCard(
                          icon: Icons.business,
                          title: "Business Name",
                          value: controller.businessName.value,
                        ),
                        _buildInfoCard(
                          icon: Icons.shopping_bag,
                          title: "Item Name",
                          value: controller.itemName.value,
                        ),
                        _buildInfoCard(
                          icon: Icons.attach_money,
                          title: "Amount",
                          value: controller.amount.value,
                          valueColor: AppColors.primary,
                          valueFontSize: 18,
                          valueFontWeight: FontWeight.bold,
                        ),

                        if (controller.notes.value.isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.note,
                            title: "Notes",
                            value: controller.notes.value,
                          ),
                        if (controller.paymentMethod.value.isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.payment,
                            title: "Payment Method",
                            value: controller.paymentMethod.value,
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                /// 🔹 Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          color: AppColors.textPrimary,
                          text: "Edit Invoice",
                          onPressed: () {
                            // TODO: Navigate to edit screen
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: "Download PDF",
                          onPressed: () {
                            // TODO: Download invoice
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                          ],
                        ),
              ),
            ),
      ),
    );
  }

  /// 🔹 Info Card Builder
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = Colors.black87,
    double valueFontSize = 14,
    FontWeight valueFontWeight = FontWeight.w500,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: valueFontWeight,
                    color: valueColor,
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
