import 'dart:io';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/modules/profile/controllers/invoice_customization_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'invoice_preview_screen.dart';

class InvoiceCustomizationScreen extends StatelessWidget {
  InvoiceCustomizationScreen({super.key});

  final controller = Get.find<InvoiceCustomizationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.background,
      appBar:  CustomAppBar2(
          title: controller.business.value?.businessName.isNotEmpty == true
              ? "Invoice Customization - ${controller.business.value!.businessName}"
              : "Invoice Customization",

      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // 🔹 Invoice Header
            _buildSectionCard(
              title: "Invoice Header",
              children: [
                Obx(
                  () => _infoRow(
                    "Invoice Logo",
                    _invoiceLogoLabel(
                      controller.invoiceLogoFile.value,
                      controller.business.value?.invoiceLogoUrl,
                    ),
                    onTap: controller.pickInvoiceLogo,
                    isAction: true,
                  ),
                ),
                Obx(() => _infoRow("Business Name", controller.businessName.value, onTap: () => controller.editField("Business Name", controller.businessName))),
                Obx(() => _infoRow("Business Address", controller.businessAddress.value, onTap: () => controller.editField("Business Address", controller.businessAddress))),
                Obx(() => _infoRow("Email / Phone", controller.businessEmail.value, onTap: () => controller.editField("Email / Phone", controller.businessEmail))),
                Obx(() => _infoRow("Tax / Registration No.", controller.taxNo.value, onTap: null, showIcon: false)),
                //Obx(() => _infoRow("Tax / Registration No.", controller.taxNo.value, onTap: () => controller.editField("Tax No", controller.taxNo))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Invoice Numbering
            // _buildSectionCard(
            //   title: "Invoice Numbering",
            //   children: [
            //     Obx(() => _infoRow("Start Number", controller.startNumber.value, onTap: () => controller.editField("Start Number", controller.startNumber))),
            //     Obx(() => _infoRow("Prefix / Suffix", controller.prefix.value, onTap: () => controller.editField("Prefix", controller.prefix))),
            //     Obx(() => _infoRow("Auto Increment", controller.autoIncrement.value, onTap: () => controller.editField("Auto Increment", controller.autoIncrement))),
            //   ],
            // ),
            //
            // const SizedBox(height: 20),

            // 🔹 Customer Details
            _buildSectionCard(
              title: "Customer Details",
              children: [
                Obx(
                  () => _toggleRow(
                    "Show Email",
                    controller.showEmail.value,
                    (bool value) => controller.showEmail.value = value,
                  ),
                ),
                Obx(
                  () => _toggleRow(
                    "Show Phone",
                    controller.showPhone.value,
                    (bool value) => controller.showPhone.value = value,
                  ),
                ),
                //Obx(() => _infoRow("Show Notes Field", controller.showNotes.value, onTap: () => controller.editField("Show Notes", controller.showNotes))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Item & Table Settings
            _buildSectionCard(
              //title: "Item & Table Settings",
              title: "Currency Settings",
              children: [
                //Obx(() => _infoRow("Columns", controller.columns.value, onTap: () => controller.editField("Columns", controller.columns))),
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
                Obx(() => _infoRow("Terms & Conditions", controller.terms.value, onTap: () => controller.editField("Terms", controller.terms, maxLength: 120))),
                Obx(() => _infoRow("Additional Notes", controller.additionalNotes.value, onTap: () => controller.editField("Notes", controller.additionalNotes, maxLength: 100))),
                Obx(() => _infoRow("Thank You Message", controller.thankYouMsg.value, onTap: () => controller.editField("Thank You Message", controller.thankYouMsg))),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Colors & Theme
            // _buildSectionCard(
            //   title: "Colors & Theme",
            //   children: [
            //     Obx(() => _infoRow("Primary Color", controller.primaryColor.value, onTap: () => controller.editField("Primary Color", controller.primaryColor))),
            //     Obx(() => _infoRow("Background Color", controller.bgColor.value, onTap: () => controller.editField("Background Color", controller.bgColor))),
            //     Obx(() => _infoRow("Font Style / Size", controller.fontStyle.value, onTap: () => controller.editField("Font Style", controller.fontStyle))),
            //   ],
            // ),/

            const SizedBox(height: 30),

            // 🔹 Buttons

                ],
              ),
            ),
            if (controller.isLoading.value)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.45),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),

        // / 2. Buttons ko yahan BottomNavigationBar mein rakhein
    bottomNavigationBar: Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CustomButton(
                text: "Save Template",
                isLoading: controller.isSaving.value,
                onPressed: controller.isSaving.value
                    ? () {}
                    : controller.saveSettings,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: controller.isLoading.value ? null : () => _previewInvoice(),
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
      invoiceLogoFile: controller.invoiceLogoFile.value,
      invoiceLogoUrl: controller.business.value?.invoiceLogoUrl,
      businessLogoUrl: controller.business.value?.businessImageUrl,

      // 🔹 Invoice Metadata
      invoiceNumber: "${controller.prefix.value}${controller.startNumber.value}",
      invoiceDate: DateTime.now(),
      dueDate: controller.dueDate.value, // Added from controller

      // 🔹 Client Info (Placeholder for now, or use controller if available)
      clientName: "Lisa Smith",
      clientEmail: controller.showEmail.value ? "LisaSmith@gmail.com" : "",
      clientPhone:
          controller.showPhone.value ? "+92 300 9876543" : null, // Added

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
      termsAndConditions:
          controller.limitedText(controller.terms.value, 120),
      additionalNotes:
          controller.limitedText(controller.additionalNotes.value, 100),
    ));
  }

  String _invoiceLogoLabel(File? file, String? url) {
    if (file != null) {
      return "Selected: ${file.path.split('/').last}";
    }
    if ((url ?? '').trim().isNotEmpty) {
      return "Change uploaded logo";
    }
    return "Upload / Change";
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

  Widget _infoRow(String title, String value, {VoidCallback? onTap, bool isAction = false, bool showIcon = true}) {
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
            !showIcon ? SizedBox.shrink() : Icon(isAction ? Icons.file_upload_outlined : Icons.edit_outlined, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value ? 'Enabled' : 'Disabled',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
