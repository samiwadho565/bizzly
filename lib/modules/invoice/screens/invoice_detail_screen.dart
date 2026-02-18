import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/invoice/controllers/invoice_detail_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';

class InvoiceDetailScreen extends GetView<InvoiceDetailController> {
  const InvoiceDetailScreen({super.key});

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
                                    controller.model.value?.customerName ?? '-',
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
                                      controller.model.value?.status ?? '-',
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
                          value: controller.model.value?.invoiceNumber ?? '',
                        ),
                        if ((controller.model.value?.invoiceDate ?? '').isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.calendar_today,
                            title: "Invoice Date",
                            value: controller.model.value?.invoiceDate ?? '',
                          ),
                        _buildInfoCard(
                          icon: Icons.business,
                          title: "Business Name",
                          value: controller.model.value?.businessName ?? '',
                        ),
                        if (controller.model.value != null)
                          _buildItems(controller.model.value!),
                        _buildInfoCard(
                          icon: Icons.attach_money,
                          title: "Total Amount",
                          value: controller.model.value?.totalAmount?.toString() ?? '',
                          valueColor: AppColors.primary,
                          valueFontSize: 18,
                          valueFontWeight: FontWeight.bold,
                        ),

                        if ((controller.model.value?.notes ?? '').isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.note,
                            title: "Notes",
                            value: controller.model.value?.notes ?? '',
                          ),
                        if ((controller.model.value?.paymentMethodName ?? '').isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.payment,
                            title: "Payment Method",
                            value: controller.model.value?.paymentMethodName ?? '',
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
                          onPressed: () async {
                            final dynamic result = await Get.toNamed(
                              Routes.createInvoiceScreen,
                              arguments: controller.model.value,
                            );
                            if (result is InvoiceModel) {
                              controller.model.value = result;
                            }
                            if (Get.isRegistered<InvoiceScreenController>()) {
                              Get.find<InvoiceScreenController>()
                                  .fetchInvoices();
                            }
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: CustomButton(
                    text: "Delete Invoice",
                    color: Colors.white,
                    textColor: Colors.red,
                    borderColor: Colors.red,
                    onPressed: controller.confirmDelete,
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

  Widget _buildItems(InvoiceModel model) {
    if (model.items.isEmpty) {
      return const SizedBox.shrink();
    }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Items",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in model.items) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  item.amount?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
