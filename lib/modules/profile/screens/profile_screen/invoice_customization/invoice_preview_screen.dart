import 'package:bizly/assets/images.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:flutter/material.dart';

import 'package:bizly/utils/app_colors.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final String businessName;
  final String businessAddress;
  final String businessEmail;
  final String? taxRegistrationNo; // New

  final String invoiceNumber;
  final DateTime invoiceDate;
  final String? dueDate; // New

  final String clientName;
  final String clientEmail;
  final String? clientPhone; // New

  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String currency; // New

  final String? paymentTerms;
  final String? lateFee; // New
  final String? footerNote;

  const InvoicePreviewScreen({
    super.key,
    required this.businessName,
    required this.businessAddress,
    required this.businessEmail,
    this.taxRegistrationNo,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    required this.clientName,
    required this.clientEmail,
    this.clientPhone,
    required this.items,
    required this.totalAmount,
    this.currency = "PKR",
    this.paymentTerms,
    this.lateFee,
    this.footerNote,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(
        title: "Invoice Preview",
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header with Logo & Business Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.bizzlyLogo,
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      businessName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text("INVOICE", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDense)),
                      Text("#$invoiceNumber", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      _buildText("${invoiceDate.day}-${invoiceDate.month}-${invoiceDate.year}", size: 12),
                   ],
                  ),
                ],
              ),

              // 🔹 Business Details & Invoice Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Business Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 45), // Aligned with name
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildText(businessAddress, size: 11),
                          _buildText(businessEmail, size: 11),
                          if (taxRegistrationNo != null && taxRegistrationNo!.isNotEmpty)
                            _buildText("Tax ID: $taxRegistrationNo", size: 11, color: Colors.grey.shade700),
                        ],
                      ),
                    ),
                  ),
                  // Right: Invoice Info

                ],
              ),

              const Divider(height: 40, thickness: 1),

              // 🔹 Billing To Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("BILL TO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      _buildText(clientEmail, size: 12),
                      if (clientPhone != null) _buildText(clientPhone!, size: 12),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔹 Items Table
              _buildItemsTable(),

              const SizedBox(height: 30),

              // 🔹 Payment Info & Summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Terms & Notes
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [

                           if (paymentTerms != null && paymentTerms!.isNotEmpty) ...[
                             Column(
                               children: [
                                 _sectionTitle("Payment Terms"),
                                 _buildText(paymentTerms!, size: 11),
                                 const SizedBox(height: 12),
                               ],
                             ),

                           ],
                           Container(
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               // color: AppColors.primaryDense.withOpacity(0.05),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Column(
                               children: [
                                 const Text("Total Amount", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                 const SizedBox(height: 4),
                                 Text(
                                   "$currency $totalAmount",
                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDense),
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),

                        // if (dueDate != null && dueDate!.isNotEmpty)
                        //   Text("Due: $dueDate", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                        // if (dueDate != null && dueDate!.isNotEmpty)SizedBox(height: 5,),
                        if (lateFee != null && lateFee!.isNotEmpty) ...[
                          _sectionTitle("Late Fee Policy"),
                          _buildText(lateFee!, size: 11, color: Colors.red.shade700),
                          const SizedBox(height: 12),
                        ],
                        if (footerNote != null && footerNote!.isNotEmpty) ...[
                          _sectionTitle("Notes"),
                          _buildText(footerNote!, size: 11),
                        ],
                      ],
                    ),
                  ),
                  // Right: Grand Total Box

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildText(String text, {double size = 12, Color? color}) {
    return Text(
      text,
      style: TextStyle(fontSize: size, color: color ?? Colors.grey.shade600),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
    );
  }

  Widget _buildItemsTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        // Table Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _tableCell("Item", isHeader: true),
            _tableCell("Qty", isHeader: true),
            _tableCell("Price", isHeader: true),
            _tableCell("Total", isHeader: true, align: TextAlign.right),
          ],
        ),
        // Table Items
        ...items.map((item) => TableRow(
          children: [
            _tableCell(item['name'] ?? "-"),
            _tableCell("${item['qty'] ?? 0}"),
            _tableCell("${item['price'] ?? 0}"),
            _tableCell("${item['total'] ?? 0}", align: TextAlign.right, isBold: true),
          ],
        )),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false, bool isBold = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }
}