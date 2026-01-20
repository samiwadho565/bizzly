import 'package:bizly/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/invoice_customization_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_app_bar_2.dart';
import 'invoice_preview_screen.dart';


// 🔹 2. Main Screen UI
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_app_bar_2.dart';
import '../../../widgets/custom_button.dart';
import 'invoice_preview_screen.dart';

class InvoiceCustomizationScreen extends StatelessWidget {
  InvoiceCustomizationScreen({super.key});

  final controller = Get.put(InvoiceCustomizationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Invoice Customization"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Invoice Header
            _buildSectionCard(
              title: "Invoice Header",
              children: [
                _infoRow("Business Logo", "Upload / Change", isAction: true),
                Obx(() => _infoRow("Business Name", controller.businessName.value, onTap: () => controller.editField("Business Name", controller.businessName))),
                Obx(() => _infoRow("Business Address", controller.businessAddress.value, onTap: () => controller.editField("Business Address", controller.businessAddress))),
                Obx(() => _infoRow("Email / Phone", controller.businessEmail.value, onTap: () => controller.editField("Email / Phone", controller.businessEmail))),
                Obx(() => _infoRow("Tax / Registration No.", controller.taxNo.value, onTap: () => controller.editField("Tax No", controller.taxNo))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Invoice Numbering
            _buildSectionCard(
              title: "Invoice Numbering",
              children: [
                Obx(() => _infoRow("Start Number", controller.startNumber.value, onTap: () => controller.editField("Start Number", controller.startNumber))),
                Obx(() => _infoRow("Prefix / Suffix", controller.prefix.value, onTap: () => controller.editField("Prefix", controller.prefix))),
                Obx(() => _infoRow("Auto Increment", controller.autoIncrement.value, onTap: () => controller.editField("Auto Increment", controller.autoIncrement))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Customer Details
            _buildSectionCard(
              title: "Customer Details",
              children: [
                Obx(() => _infoRow("Show Email", controller.showEmail.value, onTap: () => controller.editField("Show Email", controller.showEmail))),
                Obx(() => _infoRow("Show Phone", controller.showPhone.value, onTap: () => controller.editField("Show Phone", controller.showPhone))),
                Obx(() => _infoRow("Show Notes Field", controller.showNotes.value, onTap: () => controller.editField("Show Notes", controller.showNotes))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Item & Table Settings
            _buildSectionCard(
              title: "Item & Table Settings",
              children: [
                Obx(() => _infoRow("Columns", controller.columns.value, onTap: () => controller.editField("Columns", controller.columns))),
                Obx(() => _infoRow("Currency", controller.currency.value, onTap: () => controller.editField("Currency", controller.currency))),
                Obx(() => _infoRow("Decimal Precision", controller.precision.value, onTap: () => controller.editField("Precision", controller.precision))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Payment Terms
            _buildSectionCard(
              title: "Payment Terms",
              children: [
                Obx(() => _infoRow("Due Date", controller.dueDate.value, onTap: () => controller.editField("Due Date", controller.dueDate))),
                Obx(() => _infoRow("Late Fee", controller.lateFee.value, onTap: () => controller.editField("Late Fee", controller.lateFee))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Footer Notes
            _buildSectionCard(
              title: "Footer Notes",
              children: [
                Obx(() => _infoRow("Terms & Conditions", controller.terms.value, onTap: () => controller.editField("Terms", controller.terms))),
                Obx(() => _infoRow("Additional Notes", controller.additionalNotes.value, onTap: () => controller.editField("Notes", controller.additionalNotes))),
                Obx(() => _infoRow("Thank You Message", controller.thankYouMsg.value, onTap: () => controller.editField("Thank You Message", controller.thankYouMsg))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Colors & Theme
            _buildSectionCard(
              title: "Colors & Theme",
              children: [
                Obx(() => _infoRow("Primary Color", controller.primaryColor.value, onTap: () => controller.editField("Primary Color", controller.primaryColor))),
                Obx(() => _infoRow("Background Color", controller.bgColor.value, onTap: () => controller.editField("Background Color", controller.bgColor))),
                Obx(() => _infoRow("Font Style / Size", controller.fontStyle.value, onTap: () => controller.editField("Font Style", controller.fontStyle))),
              ],
            ),

            const SizedBox(height: 30),

            // 🔹 Buttons

          ],
        ),
      ),

        // / 2. Buttons ko yahan BottomNavigationBar mein rakhein
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      Expanded(
      child: CustomButton(
      text: "Save Template",
      onPressed: () => Get.back()
      )
      ),
      const SizedBox(width: 12),
      Expanded(
      child: OutlinedButton(
      onPressed: () => _previewInvoice(),
      style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: AppColors.primary),
      ),
      child: const Text("Preview", style: TextStyle(color: AppColors.primary)),
      ),
      ),
      ],
      ),
    ),
    );
  }

  void _previewInvoice() {
    Get.to(() => InvoicePreviewScreen(
      // 🔹 Business Info
      businessName: controller.businessName.value,
      businessAddress: controller.businessAddress.value,
      businessEmail: controller.businessEmail.value,
      taxRegistrationNo: controller.taxNo.value, // Added

      // 🔹 Invoice Metadata
      invoiceNumber: "${controller.prefix.value}${controller.startNumber.value}",
      invoiceDate: DateTime.now(),
      dueDate: controller.dueDate.value, // Added from controller

      // 🔹 Client Info (Placeholder for now, or use controller if available)
      clientName: "Lisa Smith",
      clientEmail: "LisaSmith@gmail.com",
      clientPhone: "+92 300 9876543", // Added

      // 🔹 Items & Pricing
      items: const [
        {"name": "Website Design", "qty": 1, "price": 50000, "total": 50000},
        {"name": "Digital Marketing", "qty": 2, "price": 30000, "total": 60000},
        {"name": "Website SEO", "qty": 1, "price": 2000, "total": 2000},
      ],
      totalAmount: 50000.0,
      currency: controller.currency.value, // Added

      // 🔹 Extra Terms & Notes
      paymentTerms: "Due within ${controller.dueDate.value}",
      lateFee: controller.lateFee.value, // Added
      footerNote: "${controller.terms.value}\n${controller.additionalNotes.value}", // Combined terms and notes
    ));
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 25, thickness: 0.8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, {VoidCallback? onTap, bool isAction = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(isAction ? Icons.file_upload_outlined : Icons.edit_outlined, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}