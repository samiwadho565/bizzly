import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/assets/images.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/components/invoice/invoice_document_card.dart';
import 'package:bizly/modules/invoice/controllers/invoice_detail_controller.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';

class InvoiceDetailScreen extends GetView<InvoiceDetailController> {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(title: "Invoice Detail"),
      backgroundColor: AppColors.background,
      body: Obx(
        () {
          if (controller.isViewLoading.value && controller.model.value == null) {
            return const Center(child: FinancePulseLoader());
          }
          final InvoiceModel? invoice = controller.model.value;
          if (invoice == null) {
            return const Center(
              child: Text(
                'Invoice not available',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }

          return SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      child: _invoicePreview(invoice),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Obx(
                      () => CustomButton(
                        text: "Download PDF",
                        isLoading: controller.isDownloadingPdf.value,
                        onPressed: controller.isDownloadingPdf.value
                            ? () {}
                            : controller.downloadPdf,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _actionIconButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            onTap: () async {
                              final dynamic result = await Get.toNamed(
                                Routes.createInvoiceScreen,
                                arguments: controller.model.value,
                              );
                              if (result is InvoiceModel) {
                                controller.model.value = result;
                              } else {
                                await controller.refreshInvoice();
                              }
                              if (Get.isRegistered<InvoiceScreenController>()) {
                                Get.find<InvoiceScreenController>().fetchInvoices();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionIconButton(
                            icon: Icons.history,
                            label: 'History',
                            onTap: () async {
                              final dynamic result = await Get.toNamed(
                                Routes.invoicePaymentsScreen,
                                arguments: controller.model.value,
                              );
                              if (result is InvoiceModel) {
                                controller.model.value = result;
                              } else {
                                await controller.refreshInvoice();
                              }
                              if (Get.isRegistered<InvoiceScreenController>()) {
                                Get.find<InvoiceScreenController>().fetchInvoices();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionIconButton(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            iconColor: Colors.red,
                            onTap: controller.confirmDelete,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _invoicePreview(InvoiceModel invoice) {
    final String status = (invoice.status ?? '').trim();
    final List<InvoiceDocumentLineItem> lineItems = invoice.items
        .map(
          (item) => InvoiceDocumentLineItem(
            name: item.itemName,
            qty: '${item.qty ?? 0}',
            unitPrice: controller.money(item.unitPrice),
            total: controller.money(item.totalAmount ?? _fallbackTotal(item)),
          ),
        )
        .toList();

    return InvoiceDocumentCard(
      leadingLogo: _buildBusinessLogo(),
      businessName: controller.displayBusinessName(),
      businessAddress: controller.displayBusinessAddress(),
      businessContact: controller.displayBusinessContact(),
      businessTaxId: controller.displayBusinessTaxId(),
      status: status,
      statusTextColor: controller.getStatusColor(),
      statusBackgroundColor: controller.getStatusBackgroundColor(),
      invoiceNumber: invoice.invoiceNumber ?? '-',
      invoiceDate: invoice.invoiceDate ?? '',
      billToName: invoice.customerName ?? '-',
      billToEmail: controller.showCustomerEmail ? (invoice.customerEmail ?? '') : '',
      billToPhone: controller.showCustomerPhone ? (invoice.customerPhone ?? '') : '',
      items: lineItems,
      metaEntries: <MapEntry<String, String>>[
        if (controller.paymentTermsText().isNotEmpty)
          MapEntry<String, String>('Payment Terms', controller.paymentTermsText()),
        if (controller.paymentMethodText().isNotEmpty)
          MapEntry<String, String>('Payment Method', controller.paymentMethodText()),
      ],
      subtotalText: controller.subtotalText(),
      taxText: controller.taxText(),
      showTax: invoice.taxEnabled == true,
      totalText: controller.totalText(),
      invoiceNotes: controller.invoiceNotesText(),
      lateFeeText: controller.lateFeeText(),
      terms: controller.termsText(),
      additionalNotes: controller.additionalNotesText(),
      thankYou: controller.thankYouMessageText(),
    );
  }

  Widget _buildBusinessLogo() {
    final String invoiceLogo = (controller.business.value?.invoiceLogoUrl ?? '').trim();
    final String businessLogo = (controller.business.value?.businessImageUrl ?? '').trim();

    if (invoiceLogo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          invoiceLogo,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackLogo(businessLogo),
        ),
      );
    }

    return _fallbackLogo(businessLogo);
  }

  Widget _fallbackLogo(String businessLogo) {
    if (businessLogo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          businessLogo,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _appLogo(),
        ),
      );
    }
    return _appLogo();
  }

  Widget _appLogo() {
    return Image.asset(
      AppImages.bizzlyLogo,
      width: 35,
      height: 35,
      fit: BoxFit.contain,
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = AppColors.textPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic _fallbackTotal(dynamic item) {
    final num qty = (item.qty ?? 0) is num
        ? (item.qty ?? 0) as num
        : num.tryParse('${item.qty ?? 0}') ?? 0;
    final num price = (item.unitPrice ?? 0) is num
        ? (item.unitPrice ?? 0) as num
        : num.tryParse('${item.unitPrice ?? 0}') ?? 0;
    return qty * price;
  }
}
