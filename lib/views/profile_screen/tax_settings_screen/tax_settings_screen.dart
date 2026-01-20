import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/custom_app_bar_2.dart';
import 'package:bizly/widgets/custom_button.dart';

import '../../../controllers/tax_setting_controller.dart';

class TaxSettingsScreen extends StatelessWidget {
  TaxSettingsScreen({super.key});

  final controller = Get.put(TaxSettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Tax Settings"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Enable/Disable Tax Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Apply Tax on Invoices",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Automatically add tax to total amount",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  Obx(() => Switch(
                    value: controller.isTaxEnabled.value,
                    onChanged: (val) => controller.toggleTax(val),
                    activeColor: AppColors.primary,
                  )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Tax Details Form (Only visible if tax is enabled)
            Obx(() => AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: controller.isTaxEnabled.value ? 1.0 : 0.4,
              child: AbsorbPointer(
                absorbing: !controller.isTaxEnabled.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tax Configuration",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(height: 30),

                      _buildTaxInputField(
                        label: "Tax Name (e.g. GST, VAT)",
                        value: controller.taxName.value,
                        onTap: () => _showEditDialog("Tax Name", controller.taxName),
                      ),

                      const SizedBox(height: 20),

                      _buildTaxInputField(
                        label: "Tax Rate (%)",
                        value: "${controller.taxRate.value}%",
                        onTap: () => _showEditDialog("Tax Rate", controller.taxRate, isNumber: true),
                      ),

                      const SizedBox(height: 20),

                      _buildTaxInputField(
                        label: "Tax Registration Number (NTN)",
                        value: controller.taxId.value,
                        onTap: () => _showEditDialog("Tax Number", controller.taxId),
                      ),
                    ],
                  ),
                ),
              ),
            )),

            const SizedBox(height: 40),

            CustomButton(
              text: "Save Tax Settings",
              onPressed: () {
                Get.back();
                Get.snackbar("Success", "Tax settings updated successfully",
                    snackPosition: SnackPosition.BOTTOM);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Tax Input UI Widget
  Widget _buildTaxInputField({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Quick Edit Dialog
  void _showEditDialog(String title, RxString val, {bool isNumber = false}) {
    TextEditingController editController = TextEditingController(text: val.value);
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: "Edit $title",
      content: TextField(
        controller: editController,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: "Enter $title"),
      ),
      confirm: TextButton(
        onPressed: () {
          val.value = editController.text;
          Get.back();
        },
        child: const Text("Update"),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
    );
  }
}