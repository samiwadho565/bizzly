import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/invoice/controllers/create_invoice_payment_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/date_formats.dart';
import 'package:bizly/utils/form_validations.dart';

class CreateInvoicePaymentScreen extends GetView<CreateInvoicePaymentController> {
  const CreateInvoicePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(title: 'Add Invoice Payment'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        'Invoice #${controller.invoice.value?.invoiceNumber ?? '-'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      hintText: 'Payment Amount',
                      controller: controller.paymentAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => FormValidations.validateRequiredNumber(
                        v ?? '',
                        fieldName: 'Payment Amount',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final date = await AppUtils.pickDate();
                          if (date != null) controller.paymentDate.value = date;
                        },
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.textField,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.paymentDate.value == null
                                    ? 'Payment Date'
                                    : DateFormats.dMonY(controller.paymentDate.value!),
                                style: TextStyle(
                                  color: controller.paymentDate.value == null
                                      ? Colors.grey.shade600
                                      : Colors.black,
                                ),
                              ),
                              const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethodDropdown(),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Reference Number (Optional)',
                      controller: controller.referenceController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Notes (Optional)',
                      controller: controller.notesController,
                      maxLine: 3,
                    ),
                    const SizedBox(height: 28),
                    Obx(
                      () => CustomButton(
                        text: 'Record Payment',
                        isLoading: controller.isSubmitting.value,
                        onPressed: controller.isSubmitting.value
                            ? () {}
                            : controller.submitPayment,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Obx(() {
      final items = controller.paymentMethods
          .map((e) => e['name']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();

      String? selectedName;
      final selectedId = controller.selectedPaymentMethodId.value;
      if (selectedId != null) {
        for (final item in controller.paymentMethods) {
          final int? id = item['id'] is int
              ? item['id'] as int
              : int.tryParse(item['id']?.toString() ?? '');
          if (id == selectedId) {
            selectedName = item['name']?.toString();
            break;
          }
        }
      }

      return CustomSearchDropdown(
        hintText: 'Payment Method',
        items: items,
        selectedItem: selectedName,
        height: 50,
        horizontalPadding: 12,
        verticalPadding: 20,
        iconSize: 25,
        textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        onChanged: (value) {
          FocusManager.instance.primaryFocus?.unfocus();
          int? id;
          for (final item in controller.paymentMethods) {
            if (item['name']?.toString() == value) {
              id = item['id'] is int
                  ? item['id'] as int
                  : int.tryParse(item['id']?.toString() ?? '');
              break;
            }
          }
          controller.selectedPaymentMethodId.value = id;
        },
      );
    });
  }
}
