import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';

import 'package:bizly/modules/profile/controllers/tax_setting_controller.dart';

class TaxSettingsScreen extends StatelessWidget {
  TaxSettingsScreen({super.key});

  final controller = Get.find<TaxSettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:  CustomAppBar2(
          title: controller.business.value?.businessName.isNotEmpty == true
              ? "Tax Settings - ${controller.business.value!.businessName}"
              : "Tax Settings",),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
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
                        controller: controller.taxNameController,
                        hintText: "Enter tax name",
                      ),

                      const SizedBox(height: 20),

                      _buildTaxInputField(
                        label: "Tax Rate (%)",
                        controller: controller.taxRateController,
                        hintText: "Enter tax rate",
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),

                      const SizedBox(height: 20),

                      _buildTaxInputField(
                        label: "Tax Registration Number (NTN)",
                        controller: controller.taxIdController,
                        hintText: "Enter tax number",
                      ),
                    ],
                  ),
                ),
              ),
            )),

            const SizedBox(height: 40),

            Obx(
              () => CustomButton(
                text: "Save Tax Settings",
                isLoading: controller.isSaving.value,
                onPressed: controller.isSaving.value
                    ? () {}
                    : controller.saveSettings,
              ),
            ),
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
    );
  }

  /// 🔹 Tax Input UI Widget
  Widget _buildTaxInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
