import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/invoice/controllers/create_invoice_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/utils/date_formats.dart';

import '../models/invoice_item_model.dart';
// import 'package:bizly/modules/invoice/controllers/create_invoice_controller.dart';

class CreateInvoiceScreen extends GetView<CreateInvoiceController> {
  const CreateInvoiceScreen({super.key});

  final TextStyle sectionTitleStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: controller.editingInvoiceId.value != null
            ? "Edit Invoice"
            : "Create Invoice",
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return const Center(child: FinancePulseLoader());
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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

                  /// 🔹 Client & Invoice Info
                  Text("Invoice Information", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  _buildCustomerDropdown(),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Invoice Number (Optional)",
                    controller: controller.invoiceNumberController,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      /// Invoice Date
                      Expanded(
                        child: Obx(
                              () => GestureDetector(

                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                final date = await AppUtils.pickDate();
                                if (date != null) {
                                  controller.invoiceDate .value = date;
                                }

                            },
                            child: Container(
                              height: 50,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.textField,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.invoiceDate.value == null
                                        ? "Invoice Date"
                                        : DateFormats.dMonY(controller.invoiceDate.value!),
                                    style: TextStyle(
                                      color:
                                      controller.invoiceDate.value == null
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
                      ),
                      const SizedBox(width: 15),

                      /// Status
                      Expanded(child: _buildStatusDropdown()),
                    ],
                  ),
                  Obx(
                    () => controller.editingInvoiceId.value == null &&
                            controller.isPartialPaidStatus
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: CustomTextField(
                              hintText: "Partial Paid Amount",
                              controller: controller.partialPaidAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (!controller.isPartialPaidStatus) return null;
                                final String value = (v ?? '').trim();
                                final String? base = FormValidations.validateRequiredNumber(
                                  value,
                                  fieldName: "Partial Paid Amount",
                                );
                                if (base != null) return base;
                                final num? entered = num.tryParse(value);
                                final double total = controller.invoiceItemsTotal;
                                if (entered != null && entered >= total) {
                                  return "Partial paid amount cannot be equal or exceed invoice total (${total.toStringAsFixed(2)})";
                                }
                                return null;
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 25),

                  /// 🔹 Item & Amount
                  Text("Item Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  Obx(
                    () => Column(
                      children: [
                        for (int i = 0; i < controller.items.length; i++) ...[
                          _itemRow(i),
                          const SizedBox(height: 12),
                        ],
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => _showAddItemSheet(context),
                            child: const Text(
                              "Add Item",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 🔹 Optional Details (Card Style)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Business & Payment", style: sectionTitleStyle),
                        const SizedBox(height: 12),

                        _buildBusinessDropdown(),
                        const SizedBox(height: 12),

                        Obx(
                          () => Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Apply Tax",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Switch(
                                value: controller.taxEnabled.value,
                                onChanged: (value) =>
                                    controller.taxEnabled.value = value,
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        CustomTextField(
                          hintText: "Notes",
                          maxLine: 3,
                          controller: controller.notesController,
                        ),
                        const SizedBox(height: 12),

                        _buildPaymentMethodDropdown(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Action Button
                  Obx(
                    () => CustomButton(
                      text: controller.editingInvoiceId.value != null
                          ? "Update Invoice"
                          : "Create Invoice",
                      isLoading: controller.isSubmitting.value,
                      onPressed: controller.isSubmitting.value
                          ? () {}
                          : controller.createOrUpdateInvoice,
                    ),
                  ),

                  const SizedBox(height: 20),
                    ],
                  ),
                  ),
                ),
                ),
              ),
            );
          },
        ),
      ),
      
    );
  }

  Widget _buildCustomerDropdown() {
    return Obx(() {
      final items = controller.customers
          .map((e) => e.customerName)
          .where((e) => e.isNotEmpty)
          .toList();
      final selectedId = controller.selectedCustomerId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.customers) {
          if (item.id == selectedId) {
            selectedName = item.customerName;
            break;
          }
        }
      }
      return CustomSearchDropdown(
        height: 50,
        horizontalPadding: 12,
        verticalPadding: 20,
        iconSize: 25,
        textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        hintText: "Customer",
        items: items,
        selectedItem: selectedName,
        onChanged: (value) {
          FocusManager.instance.primaryFocus?.unfocus();
          int? id;
          for (final item in controller.customers) {
            if (item.customerName == value) {
              id = item.id;
              break;
            }
          }
          controller.selectedCustomerId.value = id;
        },
      );
    });
  }

  Widget _buildBusinessDropdown() {
    return Obx(() {
      final items = controller.businesses
          .map((e) => e.businessName)
          .where((e) => e.isNotEmpty)
          .toList();
      final selectedId = controller.selectedBusinessId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.businesses) {
          if (item.id == selectedId) {
            selectedName = item.businessName;
            break;
          }
        }
      }
      return IgnorePointer(
        ignoring: controller.isBusinessLocked.value,
        child: Opacity(
          opacity: controller.isBusinessLocked.value ? 0.75 : 1,
          child: CustomSearchDropdown(
            height: 50,
            horizontalPadding: 12,
            verticalPadding: 20,
            iconSize: 25,
            textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            hintText: "Business",
            items: items,
            selectedItem: selectedName,
            onChanged: (value) {
              FocusManager.instance.primaryFocus?.unfocus();
              int? id;
              for (final item in controller.businesses) {
                if (item.businessName == value) {
                  id = item.id;
                  break;
                }
              }
              controller.selectedBusinessId.value = id;
            },
          ),
        ),
      );
    });
  }

  Widget _buildPaymentMethodDropdown() {
    return Obx(() {
      final items = controller.paymentMethods
          .map((e) => e['name']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      final selectedId = controller.selectedPaymentMethodId.value;
      String? selectedName;
      if (selectedId != null) {
        for (final item in controller.paymentMethods) {
          if (item['id'] == selectedId) {
            selectedName = item['name']?.toString();
            break;
          }
        }
      }
      return CustomSearchDropdown(
        height: 50,
        horizontalPadding: 12,
        verticalPadding: 20,
        iconSize: 25,
        textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        hintText: "Payment Method",
        items: items,
        selectedItem: selectedName,
        onChanged: (value) {
          FocusManager.instance.primaryFocus?.unfocus();
          int? id;
          for (final item in controller.paymentMethods) {
            if (item['name']?.toString() == value) {
              id = item['id'] as int?;
              break;
            }
          }
          controller.selectedPaymentMethodId.value = id;
        },
      );
    });
  }

  Widget _buildStatusDropdown() {
    const List<String> items = ["Paid", "Unpaid", "Partialy Paid"];
    return CustomSearchDropdown(
      height: 50,
      horizontalPadding: 12,
      verticalPadding: 20,
      iconSize: 25,
      textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
      hintText: "Status",
      items: items,
      selectedItem: _statusValueToLabel(controller.status.value),
      onChanged: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        if (value != null) {
          controller.status.value = _statusLabelToValue(value);
          if (!controller.isPartialPaidStatus) {
            controller.partialPaidAmountController.clear();
          }
        }
      },
    );
  }

  Widget _itemRow(int index) {
    final item = controller.items[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${_displayQty(item.qty)}  |  Unit: ${_displayMoney(item.unitPrice)}  |  Total: ${_displayMoney(_lineTotal(item))}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.removeItem(index),
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController qtyController = TextEditingController(text: '1');
    final TextEditingController unitPriceController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Item",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: nameController,
                  hintText: "Item Name",
                  validator: (v) => FormValidations.validateRequired(
                    v ?? '',
                    fieldName: "Item Name",
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  verticalPadding: 15,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: qtyController,
                  hintText: "Quantity",
                  keyboardType: TextInputType.number,
                  validator: (v) => FormValidations.validateRequiredNumber(
                    v ?? '',
                    fieldName: "Quantity",
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  verticalPadding: 15,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: unitPriceController,
                  hintText: "Unit Price",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => FormValidations.validateRequiredNumber(
                    v ?? '',
                    fieldName: "Unit Price",
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  verticalPadding: 15,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Add",
                        onPressed: () {
                          final bool ok =
                              formKey.currentState?.validate() ?? false;
                          if (!ok) return;
                          controller.items.add(
                            InvoiceItemModel(
                              itemName: nameController.text.trim(),
                              qty: qtyController.text.trim(),
                              unitPrice: unitPriceController.text.trim(),
                            ),
                          );
                          nameController.clear();
                          qtyController.text = '1';
                          unitPriceController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Done",
                        color: Colors.grey.shade700,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _cap(String v) {
    if (v.isEmpty) return v;
    return v[0].toUpperCase() + v.substring(1);
  }

  String _statusValueToLabel(String value) {
    switch (value) {
      case 'paid':
        return 'Paid';
      case 'partialy-paid':
        return 'Partialy Paid';
      case 'unpaid':
      default:
        return 'Unpaid';
    }
  }

  String _statusLabelToValue(String label) {
    switch (label.toLowerCase().trim()) {
      case 'paid':
        return 'paid';
      case 'partialy paid':
        return 'partialy-paid';
      case 'unpaid':
      default:
        return 'unpaid';
    }
  }

  String _displayQty(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }

  String _displayMoney(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }

  dynamic _lineTotal(InvoiceItemModel item) {
    if (item.totalAmount != null) return item.totalAmount;
    final num? qty = num.tryParse((item.qty ?? '').toString());
    final num? unit = num.tryParse((item.unitPrice ?? '').toString());
    if (qty != null && unit != null) return qty * unit;
    return null;
  }
}
