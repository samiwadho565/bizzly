import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/business/controllers/business_activity_controller.dart';
import 'package:bizly/components/invoice/invoice_card.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/routes/routes.dart';

class BusinessInvoicesTab extends StatelessWidget {
  const BusinessInvoicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessActivityController>();
    return Obx(() {
      if (controller.isInvoicesLoading.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: FinancePulseLoader()),
          ),
        );
      }

      if (controller.invoicesError.value.isNotEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(child: Text(controller.invoicesError.value)),
          ),
        );
      }

      if (controller.invoices.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text("No invoices available")),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final InvoiceModel invoice = controller.invoices[index];
          final String itemName = invoice.items.isNotEmpty
              ? invoice.items.first.itemName
              : '-';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Get.toNamed(
                  Routes.invoiceDetailScreen,
                  arguments: invoice,
                );
              },
              child: InvoiceCard(
                status: _status(invoice),
                clientName: invoice.customerName ?? '-',
                businessName:
                    invoice.businessName ?? controller.business.value?.businessName ?? '-',
                itemName: itemName,
                amount: _amount(invoice),
              ),
            ),
          );
        }, childCount: controller.invoices.length),
      );
    });
  }

  String _status(InvoiceModel invoice) {
    final String status = (invoice.paymentStatus ?? invoice.status ?? '').trim();
    return status.isEmpty ? '-' : status;
  }

  String _amount(InvoiceModel invoice) {
    final dynamic raw =
        invoice.totalAmount ?? invoice.subtotalAmount ?? invoice.taxAmount ?? 0;
    if (raw is num) return 'PKR ${raw.toStringAsFixed(raw % 1 == 0 ? 0 : 2)}';
    final String normalized = raw?.toString().trim() ?? '';
    if (normalized.isEmpty) return 'PKR 0';
    return 'PKR $normalized';
  }
}
