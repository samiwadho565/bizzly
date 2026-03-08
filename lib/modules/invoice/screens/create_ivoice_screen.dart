import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/invoice/controllers/create_invoice_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/assets/images.dart';
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

                  _fieldLabel("Customer"),
                  _buildCustomerDropdown(),
                  _selectionErrorText(controller.customerSelectionError),
                  const SizedBox(height: 12),

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
                        const SizedBox(height: 2),
                        InkWell(
                          onTap: () => _showAddItemSheet(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.35),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Add Item",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _invoiceTotalsCard(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

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
                                controller.invoiceDate.value = date;
                              }
                            },
                            child: Column(
                              key: controller.invoiceDateFieldKey,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("Invoice Date"),
                                Container(
                                  height: 50,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.textField,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          controller.invoiceDate.value == null
                                              ? "Select Invoice Date"
                                              : DateFormats.dMonY(
                                                  controller.invoiceDate.value!,
                                                ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: controller.invoiceDate.value ==
                                                    null
                                                ? Colors.grey.shade600
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Image.asset(
                                        AppImages.calendar,
                                        width: 15,
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                _selectionErrorText(
                                  controller.invoiceDateSelectionError,
                                  reserveSpace: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      /// Status
                      Expanded(
                        child: Column(
                          key: controller.statusFieldKey,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Status"),
                            _buildStatusDropdown(),
                            _selectionErrorText(
                              controller.statusSelectionError,
                              reserveSpace: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => controller.editingInvoiceId.value == null &&
                            controller.isPartialPaidStatus
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("Partial Paid Amount"),
                                CustomTextField(
                                  fieldKey: controller.partialPaidFieldKey,
                                  hintText: "Partial Paid Amount",
                                  controller: controller.partialPaidAmountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(decimal: true),
                                  validator: controller.partialPaidAmountValidator,
                                  inputFormatters: controller.partialPaidInputFormatters,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
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

                        _fieldLabel("Business"),
                        _buildBusinessDropdown(),
                        _selectionErrorText(controller.businessSelectionError),
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
                                onChanged: (value) {
                                  controller.onTaxToggle(
                                    value,
                                    context: context,
                                  );
                                },
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        _fieldLabel("Payment Method"),
                        _buildPaymentMethodDropdown(),
                        _selectionErrorText(
                          controller.paymentMethodSelectionError,
                        ),
                        const SizedBox(height: 12),
                        _fieldLabel("Notes"),
                        CustomTextField(
                          fieldKey: controller.notesFieldKey,
                          hintText: "Notes",
                          maxLine: 3,
                          controller: controller.notesController,
                          validator: controller.notesValidator,
                          inputFormatters: controller.notesInputFormatters,
                        ),



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
                          : controller.submitInvoiceFromForm,
                    ),
                  ),

                  const SizedBox(height: 20),

                 ] ),
                  ),
                ),
                ),
            ));
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
      if ((selectedName == null || selectedName.isEmpty) &&
          controller.isCustomerLocked.value &&
          controller.lockedCustomerName.value.isNotEmpty) {
        selectedName = controller.lockedCustomerName.value;
      }
      return Container(
        key: controller.customerFieldKey,
        child: IgnorePointer(
          ignoring: controller.isCustomerLocked.value,
          child: Opacity(
            opacity: controller.isCustomerLocked.value ? 0.75 : 1,
            child: CustomSearchDropdown(
              height: 50,
              horizontalPadding: 12,
              verticalPadding: 20,
              iconSize: 25,
              textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              hintText: "Select Customer",
              items: items,
              selectedItem: selectedName,
              showDropdownIcon: !controller.isCustomerLocked.value,
              displayValue: controller.isCustomerLocked.value
                  ? (controller.lockedCustomerName.value.isNotEmpty
                      ? controller.lockedCustomerName.value
                      : selectedName)
                  : selectedName,
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
            ),
          ),
        ),
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
      if ((selectedName == null || selectedName.isEmpty) &&
          controller.isBusinessLocked.value &&
          controller.lockedBusinessName.value.isNotEmpty) {
        selectedName = controller.lockedBusinessName.value;
      }
      return Container(
        key: controller.businessFieldKey,
        child: IgnorePointer(
          ignoring: controller.isBusinessLocked.value,
          child: Opacity(
            opacity: controller.isBusinessLocked.value ? 0.75 : 1,
            child: CustomSearchDropdown(
              height: 50,
              horizontalPadding: 12,
              verticalPadding: 20,
              iconSize: 25,
              textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              hintText: "Select Business",
              items: items,
              selectedItem: selectedName,
              showDropdownIcon: !controller.isBusinessLocked.value,
              displayValue: controller.isBusinessLocked.value
                  ? (controller.lockedBusinessName.value.isNotEmpty
                      ? controller.lockedBusinessName.value
                      : selectedName)
                  : selectedName,
              onChanged: (value) {
                FocusManager.instance.primaryFocus?.unfocus();
                int? id;
                for (final item in controller.businesses) {
                  if (item.businessName == value) {
                    id = item.id;
                    break;
                  }
                }
                controller.onBusinessChanged(id);
              },
            ),
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
      return Container(
        key: controller.paymentMethodFieldKey,
        child: CustomSearchDropdown(
          height: 50,
          horizontalPadding: 12,
          verticalPadding: 20,
          iconSize: 25,
          textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          hintText: "Select Payment Method",
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
        ),
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
    final String qty = _displayQty(item.qty);
    final String unitPrice = _displayMoney(item.unitPrice);
    final String total = _displayMoney(_lineTotal(item));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => controller.removeItem(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _itemMetaTile(
                    label: "Qty",
                    value: qty,
                  ),
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _itemMetaTile(
                    label: "Unit",
                    value: unitPrice,
                  ),
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _itemMetaTile(
                    label: "Total",
                    value: total,
                    emphasize: true,
                  ),
                ),
              ],
            ),
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
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 14,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Add Line Item",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Add product/service details for this invoice",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(sheetContext),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment:Alignment.centerLeft,
                              child: _fieldLabel("Item Name")),
                          CustomTextField(
                            controller: nameController,
                            hintText: "e.g. Website Design",
                            inputFormatters: controller.itemNameInputFormatters,
                            validator: (v) => FormValidations.validateRequiredMinMax(
                              v ?? '',
                              fieldName: "Item Name",
                              min: 2,
                              max: CreateInvoiceController.itemNameMax,
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(sheetContext).nextFocus(),
                            verticalPadding: 15,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _fieldLabel("Qty"),
                                    CustomTextField(
                                      controller: qtyController,
                                      hintText: "1",
                                      keyboardType: TextInputType.number,
                                      inputFormatters: controller.itemQtyInputFormatters,
                                      validator: (v) =>
                                          FormValidations.validateCommonQuantity(
                                        v ?? '',
                                        fieldName: "Quantity",
                                      ),
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(sheetContext).nextFocus(),
                                      textInputAction: TextInputAction.next,
                                      verticalPadding: 15,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _fieldLabel("Unit Price"),
                                    CustomTextField(
                                      controller: unitPriceController,
                                      hintText: "0.00",
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters:
                                          controller.itemUnitPriceInputFormatters,
                                      validator: (v) => FormValidations.validateCommonAmount(
                                        v ?? '',
                                        fieldName: "Unit Price",
                                        maxChars: CreateInvoiceController.itemUnitPriceMax,
                                      ),
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(sheetContext).unfocus(),
                                      textInputAction: TextInputAction.done,
                                      verticalPadding: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: Listenable.merge([qtyController, unitPriceController]),
                      builder: (BuildContext context, Widget? _) {
                        final num qty = num.tryParse(qtyController.text.trim()) ?? 0;
                        final num unit = num.tryParse(unitPriceController.text.trim()) ?? 0;
                        final num lineTotal = qty * unit;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Estimated Total",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "PKR ${lineTotal % 1 == 0 ? lineTotal.toStringAsFixed(0) : lineTotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Done",
                            color: Colors.white,
                            textColor: AppColors.primary,
                            borderColor: AppColors.primary,
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: "Add Item",
                            onPressed: () {
                              final bool ok = formKey.currentState?.validate() ?? false;
                              if (!ok) return;
                              controller.items.add(
                                InvoiceItemModel(
                                  itemName: nameController.text.trim(),
                                  qty: qtyController.text.trim(),
                                  unitPrice: unitPriceController.text.trim(),
                                ),
                              );
                              AppUtils.showTopToast(
                                "Item added",
                                context: sheetContext,
                              );
                              nameController.clear();
                              qtyController.text = '1';
                              unitPriceController.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _selectionErrorText(String? message, {bool reserveSpace = false}) {
    if (message == null || message.isEmpty) {
      return reserveSpace
          ? const SizedBox(height: 22)
          : const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _invoiceTotalsCard() {
    return Obx(() {
      final double subtotal = controller.invoiceSubtotal;
      final double tax = controller.invoiceTaxAmount;
      final double total = controller.invoiceGrandTotal;
      final String currency = controller.invoiceCurrencyCode;
      final String taxLabel = controller.taxEnabled.value
          ? 'Tax (${controller.invoiceTaxPercent.toStringAsFixed(2)}%)'
          : 'Tax';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            _amountLine(
              "Subtotal",
              _formatMoney(subtotal, currency),
            ),
            const SizedBox(height: 6),
            _amountLine(
              taxLabel,
              _formatMoney(tax, currency),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1),
            ),
            _amountLine(
              "Total",
              _formatMoney(total, currency),
              bold: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _amountLine(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: bold ? AppColors.primary : AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatMoney(num value, String currency) {
    final String amount =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return '$currency $amount';
  }

  Widget _itemMetaTile({
    required String label,
    required String value,
    bool emphasize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
