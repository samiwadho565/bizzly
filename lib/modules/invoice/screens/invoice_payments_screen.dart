import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/add_button.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/components/common/top_border_ccontainer.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/modules/invoice/controllers/invoice_payments_controller.dart';
import 'package:bizly/modules/invoice/models/invoice_payment_model.dart';
import 'package:bizly/utils/app_colors.dart';

class InvoicePaymentsScreen extends GetView<InvoicePaymentsController> {
  const InvoicePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: 'Invoice Payments',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 23),
          onPressed: controller.closeWithResult,
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          controller.closeWithResult();
          return false;
        },
        child: TopBorderContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.invoice.value?.customerName ?? 'Invoice',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invoice #${controller.invoice.value?.invoiceNumber ?? '-'}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Text(
                          'History (${controller.payments.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    addButton('Add Payment', onTap: controller.goToCreatePayment),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: FinancePulseLoader());
                    }
                    if (controller.error.value.isNotEmpty) {
                      return Center(child: Text(controller.error.value));
                    }
                    if (controller.payments.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.fetchPayments,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No payment history found.')),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.fetchPayments,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.payments.length,
                        padding: const EdgeInsets.only(bottom: 100),
                        itemBuilder: (context, index) {
                          final InvoicePaymentModel item = controller.payments[index];
                          return _paymentCard(item);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
        ),
      ),
      ),
    );
  }

  Widget _paymentCard(InvoicePaymentModel payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  'Amount: ${payment.paymentAmount ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  payment.paymentMethodName ?? '-',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow('Date', payment.paymentDate ?? '-'),
          if ((payment.referenceNumber ?? '').isNotEmpty)
            _infoRow('Reference', payment.referenceNumber ?? ''),
          if ((payment.notes ?? '').isNotEmpty) _infoRow('Notes', payment.notes ?? ''),
          if ((payment.userName ?? '').isNotEmpty) _infoRow('Recorded By', payment.userName ?? ''),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
