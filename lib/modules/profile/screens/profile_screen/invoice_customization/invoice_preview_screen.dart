import 'dart:io';

import 'package:bizly/assets/images.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/invoice/invoice_document_card.dart';
import 'package:flutter/material.dart';

import 'package:bizly/utils/app_colors.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final String businessName;
  final String businessAddress;
  final String businessEmail;
  final String? taxRegistrationNo;
  final File? invoiceLogoFile;
  final String? invoiceLogoUrl;
  final String? businessLogoUrl;

  final String invoiceNumber;
  final DateTime invoiceDate;
  final String? dueDate;

  final String clientName;
  final String clientEmail;
  final String? clientPhone;

  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String currency;

  final String? paymentTerms;
  final String? lateFee;
  final String? termsAndConditions;
  final String? additionalNotes;
  final String? thankYouMessage;

  const InvoicePreviewScreen({
    super.key,
    required this.businessName,
    required this.businessAddress,
    required this.businessEmail,
    this.taxRegistrationNo,
    this.invoiceLogoFile,
    this.invoiceLogoUrl,
    this.businessLogoUrl,
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
    this.termsAndConditions,
    this.additionalNotes,
    this.thankYouMessage,
  });

  @override
  Widget build(BuildContext context) {
    final List<InvoiceDocumentLineItem> lineItems = items
        .map(
          (Map<String, dynamic> item) => InvoiceDocumentLineItem(
            name: '${item['name'] ?? '-'}',
            qty: '${item['qty'] ?? 0}',
            unitPrice: _money(_toNum(item['price'])),
            total: _money(_toNum(item['total'])),
          ),
        )
        .toList();

    final num subtotal = items.fold<num>(
      0,
      (num sum, Map<String, dynamic> item) => sum + (_toNum(item['total']) ?? 0),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(
        title: "Invoice Preview",
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: InvoiceDocumentCard(
          leadingLogo: _buildLogo(),
          businessName: businessName,
          businessAddress: businessAddress,
          businessContact: businessEmail,
          businessTaxId: (taxRegistrationNo ?? '').trim(),
          status: 'PAID',
          statusTextColor: const Color(0xFF1B5E20),
          statusBackgroundColor: const Color(0xFFE8F5E9),
          invoiceNumber: invoiceNumber,
          invoiceDate: '${invoiceDate.day}-${invoiceDate.month}-${invoiceDate.year}',
          billToName: clientName,
          billToEmail: clientEmail,
          billToPhone: (clientPhone ?? '').trim(),
          items: lineItems,
          metaEntries: <MapEntry<String, String>>[
            if ((paymentTerms ?? '').trim().isNotEmpty)
              MapEntry<String, String>('Payment Terms', paymentTerms!.trim()),
          ],
          subtotalText: _money(subtotal),
          taxText: _money(0),
          showTax: false,
          totalText: _money(totalAmount),
          lateFeeText: (lateFee ?? '').trim(),
          terms: (termsAndConditions ?? '').trim(),
          additionalNotes: (additionalNotes ?? '').trim(),
          thankYou: (thankYouMessage ?? '').trim(),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final File? localLogo = invoiceLogoFile;
    final String invoiceLogo = (invoiceLogoUrl ?? '').trim();
    final String businessLogo = (businessLogoUrl ?? '').trim();

    if (localLogo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          localLogo,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        ),
      );
    }

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

  num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  String _money(num? amount) {
    return '$currency ${_cleanNum(amount ?? 0)}';
  }

  String _cleanNum(num value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
  }
}
