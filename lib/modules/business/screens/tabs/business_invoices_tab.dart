import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/business/controllers/business_controller.dart';
import 'package:bizly/components/invoice/invoice_card.dart';

class BusinessInvoicesTab extends StatelessWidget {
  const BusinessInvoicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessDetailController>();
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
        final invoices = controller.invoices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InvoiceCard(
            status: invoices["status"] ?? "-",
            clientName: invoices['client'] ?? "-",
            businessName: invoices['business'] ?? "-",
            itemName: invoices['item'] ?? "-",
            amount: invoices['amount'] ?? '0',
          ),
        );
      }, childCount: controller.invoices.length),
    );
  }
}
