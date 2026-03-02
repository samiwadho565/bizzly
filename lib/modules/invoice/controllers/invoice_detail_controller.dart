import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/modules/invoice/models/invoice_item_model.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/modules/invoice/screens/invoice_pdf_preview_screen.dart';

class InvoiceDetailController extends GetxController {
  final Rxn<InvoiceModel> model = Rxn<InvoiceModel>();
  final RxBool isDownloadingPdf = false.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is InvoiceModel) {
      model.value = args;
    }
  }

  Color getStatusColor() {
    switch ((model.value?.status ?? '').toLowerCase()) {
      case "paid":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "unpaid":
        return Colors.redAccent;
      case "partialy-paid":
      case "partially-paid":
      case "partially paid":
        return Colors.blueAccent;
      default:
        return Colors.grey.shade300;
    }
  }

  Future<void> refreshInvoice() async {
    final int? id = model.value?.id;
    if (id == null) return;
    final ApiResponse response = await ApiService().get(
      '${AppUrls.createInvoice}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return;
    final Map<String, dynamic> map = Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    model.value = InvoiceModel.fromJson(payload);
  }

  Future<void> deleteInvoice() async {
    final String id = model.value?.id?.toString() ?? '';
    if (id.isEmpty) return;
    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.deleteInvoice}/$id',
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (response.success) {
      if (Get.isRegistered<InvoiceScreenController>()) {
        Get.find<InvoiceScreenController>().fetchInvoices();
      }
      Get.back();
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: "Deleted",
        message: "Invoice deleted successfully.",
        actions: [AppDialogAction(label: "Ok")],
      );
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  void confirmDelete() {
    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogTrash,
      title: "Delete Invoice?",
      message: "Are you sure you want to delete this invoice?",
      actions: [
        AppDialogAction(label: "Cancel"),
        AppDialogAction(
          label: "Delete",
          textColor: Colors.red,
          onPressed: () {
            deleteInvoice();
          },
        ),
      ],
    );
  }

  Future<void> downloadPdf() async {
    if (isDownloadingPdf.value) return;
    final InvoiceModel? current = model.value;
    if (current?.id == null) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Missing Invoice",
        message: "Invoice data is not available.",
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    isDownloadingPdf.value = true;
    AppDialogs.showLoading(message: "Generating PDF...");

    try {
      final InvoiceModel? invoice = await _fetchInvoiceById(current!.id!);
      if (invoice == null) {
        throw Exception('Unable to fetch invoice');
      }

      final InvoiceModel resolvedInvoice = await _hydrateInvoiceCustomer(invoice);
      model.value = resolvedInvoice;
      final BusinessModel? business = invoice.businessId == null
          ? null
          : await _fetchBusinessById(invoice.businessId!);

      final pw.Document doc = pw.Document();
      final Uint8List? logoBytes = await _resolveLogoBytes(business);

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (pw.Context context) => <pw.Widget>[
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(18),
                border: pw.Border.all(color: PdfColors.grey200, width: 0.6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfHeader(resolvedInvoice, business, logoBytes),
                  pw.SizedBox(height: 24),
                  _buildPdfCustomer(resolvedInvoice, business),
                  pw.SizedBox(height: 24),
                  _buildPdfItems(resolvedInvoice, business),
                  pw.SizedBox(height: 24),
                  _buildPdfSummary(resolvedInvoice, business),
                ],
              ),
            ),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final String invoiceNo = (resolvedInvoice.invoiceNumber ?? 'invoice').trim();
      final String safeName = invoiceNo.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final file = File('${directory.path}/${safeName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final Uint8List pdfBytes = await doc.save();
      await file.writeAsBytes(pdfBytes);

      AppDialogs.closeDialog();
      await Get.to(
        () => InvoicePdfPreviewScreen(
          bytes: pdfBytes,
          filePath: file.path,
        ),
      );
    } catch (_) {
      AppDialogs.closeDialog();
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "PDF Failed",
        message: "Unable to generate invoice PDF. Please try again.",
        actions: [AppDialogAction(label: "Ok")],
      );
    } finally {
      isDownloadingPdf.value = false;
    }
  }

  Future<InvoiceModel?> _fetchInvoiceById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.createInvoice}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    return InvoiceModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<BusinessModel?> _fetchBusinessById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllBusinesses}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    return BusinessModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<InvoiceModel> _hydrateInvoiceCustomer(InvoiceModel invoice) async {
    final bool hasEmail = (invoice.customerEmail ?? '').trim().isNotEmpty;
    final bool hasPhone = (invoice.customerPhone ?? '').trim().isNotEmpty;
    final bool hasName = (invoice.customerName ?? '').trim().isNotEmpty;
    if ((hasEmail && hasPhone && hasName) || invoice.customerId == null) {
      return invoice;
    }

    final ApiResponse response = await ApiService().get(
      '${AppUrls.createCustomer}/${invoice.customerId}',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) {
      return invoice;
    }

    final Map<String, dynamic> raw = Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        raw['data'] is Map ? Map<String, dynamic>.from(raw['data'] as Map) : raw;

    final String? customerName = _pickCustomerField(
      <dynamic>[payload['customer_name'], payload['name'], invoice.customerName],
    );
    final String? customerEmail = _pickCustomerField(
      <dynamic>[payload['email'], invoice.customerEmail],
    );
    final String? customerPhone = _pickCustomerField(
      <dynamic>[payload['phone_number'], payload['phone'], invoice.customerPhone],
    );

    return InvoiceModel(
      id: invoice.id,
      userId: invoice.userId,
      customerId: invoice.customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      businessId: invoice.businessId,
      businessName: invoice.businessName,
      paymentMethodId: invoice.paymentMethodId,
      paymentMethodName: invoice.paymentMethodName,
      invoiceNumber: invoice.invoiceNumber,
      invoiceDate: invoice.invoiceDate,
      status: invoice.status,
      notes: invoice.notes,
      taxEnabled: invoice.taxEnabled,
      subtotalAmount: invoice.subtotalAmount,
      taxAmount: invoice.taxAmount,
      totalAmount: invoice.totalAmount,
      paidAmount: invoice.paidAmount,
      remainingAmount: invoice.remainingAmount,
      paymentStatus: invoice.paymentStatus,
      items: invoice.items,
      payments: invoice.payments,
      createdAt: invoice.createdAt,
      updatedAt: invoice.updatedAt,
    );
  }

  Future<Uint8List?> _resolveLogoBytes(BusinessModel? business) async {
    final String invoiceLogo = (business?.invoiceLogoUrl ?? '').trim();
    final String businessLogo = (business?.businessImageUrl ?? '').trim();

    Uint8List? bytes;
    if (invoiceLogo.isNotEmpty) {
      bytes = await _loadNetworkBytes(invoiceLogo);
    }
    if (bytes == null && businessLogo.isNotEmpty) {
      bytes = await _loadNetworkBytes(businessLogo);
    }
    if (bytes != null) return bytes;

    final data = await rootBundle.load(AppImages.bizzlyLogo);
    return data.buffer.asUint8List();
  }

  Future<Uint8List?> _loadNetworkBytes(String url) async {
    try {
      final Response<List<int>> response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final List<int>? data = response.data;
      if (data == null) return null;
      return Uint8List.fromList(data);
    } catch (_) {
      return null;
    }
  }

  pw.Widget _buildPdfHeader(
    InvoiceModel invoice,
    BusinessModel? business,
    Uint8List? logoBytes,
  ) {
    final String businessName = _firstNonEmpty(
      <String?>[
        business?.invoiceBusinessName,
        business?.businessName,
        invoice.businessName,
      ],
      fallback: 'Business',
    );
    final String businessAddress = _firstNonEmpty(
      <String?>[
        business?.invoiceBusinessAddress,
        business?.businessAddress,
      ],
      fallback: '',
    );
    final String businessEmail = _composeBusinessContact(business);
    final String taxNo = _firstNonEmpty(
      <String?>[
        business?.invoiceTaxNtn,
        business?.taxNtnNumber,
      ],
      fallback: '',
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logoBytes != null)
              pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.SizedBox(
                  width: 35,
                  height: 35,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),
            if (logoBytes != null) pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Text(
                businessName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if ((invoice.status ?? '').trim().isNotEmpty) ...[
                  _buildStatusBadge(invoice.status ?? ''),
                  pw.SizedBox(height: 6),
                ],
                pw.Text(
                  '#${invoice.invoiceNumber ?? '-'}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  invoice.invoiceDate ?? '',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
        if (businessAddress.isNotEmpty || businessEmail.isNotEmpty || taxNo.isNotEmpty)
          pw.Padding(
            padding: pw.EdgeInsets.only(left: logoBytes != null ? 46 : 0, top: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (businessAddress.isNotEmpty)
                  pw.Text(
                    businessAddress,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                if (businessEmail.isNotEmpty)
                  pw.Text(
                    businessEmail,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                if (taxNo.isNotEmpty)
                  pw.Text(
                    'Tax ID: $taxNo',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
              ],
            ),
          ),
        pw.SizedBox(height: 18),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4),
          child: pw.Divider(color: PdfColors.grey200, height: 1),
        ),
      ],
    );
  }

  pw.Widget _buildPdfCustomer(InvoiceModel invoice, BusinessModel? business) {
    final bool showEmail = business?.invoiceShowEmail ?? true;
    final bool showPhone = business?.invoiceShowPhone ?? true;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'BILL TO',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          invoice.customerName ?? '-',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (showEmail && (invoice.customerEmail ?? '').trim().isNotEmpty)
          pw.Text(
            invoice.customerEmail!.trim(),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        if (showPhone && (invoice.customerPhone ?? '').trim().isNotEmpty)
          pw.Text(
            invoice.customerPhone!.trim(),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
      ],
    );
  }

  pw.Widget _buildPdfItems(InvoiceModel invoice, BusinessModel? business) {
    final String currency = _firstNonEmpty(
      <String?>[
        business?.currency,
      ],
      fallback: 'PKR',
    );

    final List<pw.TableRow> rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _cell('Item', isHeader: true),
          _cell('Qty', isHeader: true),
          _cell('Price', isHeader: true),
          _cell('Total', isHeader: true, align: pw.TextAlign.right),
        ],
      ),
      ...invoice.items.map(
        (InvoiceItemModel item) => pw.TableRow(
          children: [
            _cell(item.itemName),
            _cell('${item.qty ?? 0}'),
            _cell(_money(_toNum(item.unitPrice), currency)),
            _cell(
              _money(_toNum(item.totalAmount) ?? _fallbackTotal(item), currency),
              align: pw.TextAlign.right,
            ),
          ],
        ),
      ),
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Table(
        border: const pw.TableBorder(
          horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.35),
        ),
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(2),
          3: const pw.FlexColumnWidth(2),
        },
        children: rows,
      ),
    );
  }

  pw.Widget _buildPdfSummary(InvoiceModel invoice, BusinessModel? business) {
    final String currency = _firstNonEmpty(
      <String?>[
        business?.currency,
      ],
      fallback: 'PKR',
    );
    final String terms = _limitText(business?.invoiceTermsText ?? '', 120);
    final String additionalNotes =
        _limitText(business?.invoiceAdditionalNotes ?? '', 100);
    final String dueDays = business?.invoiceDueDateDays != null
        ? '${business!.invoiceDueDateDays} days'
        : '';
    final String lateFee = business?.invoiceLateFee != null
        ? _cleanNum(business!.invoiceLateFee!)
        : '';
    final String paymentMethod = (invoice.paymentMethodName ?? '').trim();
    final String invoiceNotes = _limitText(invoice.notes ?? '', 100);
    final bool showTax = invoice.taxEnabled == true;
    final String subtotal = _money(_toNum(invoice.subtotalAmount), currency);
    final String tax = _money(showTax ? _toNum(invoice.taxAmount) : 0, currency);
    final String total = _money(_toNum(invoice.totalAmount), currency);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (dueDays.isNotEmpty) ...[
                    pw.Text(
                      'Payment Terms',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      dueDays,
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                  if (paymentMethod.isNotEmpty) ...[
                    pw.Text(
                      'Payment Method',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      paymentMethod,
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                  if (invoiceNotes.isNotEmpty) ...[
                    pw.Text(
                      'Invoice Notes',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      invoiceNotes,
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(width: 14),
            pw.Container(
              width: 150,
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Total Amount',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _money(_toNum(invoice.totalAmount), currency),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(AppColors.primaryDense.value),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.grey200, height: 1),
                  pw.SizedBox(height: 8),
                  _amountRow('Subtotal', subtotal),
                  if (showTax) _amountRow('Tax', tax),
                  pw.SizedBox(height: 4),
                  _amountRow('Total', total, bold: true),
                ],
              ),
            ),
          ],
        ),
        if (lateFee.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            'Late Fee Policy',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            lateFee,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.red600),
          ),
        ],
        if (terms.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            'Terms & Conditions',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            terms,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
          ),
        ],
        if (additionalNotes.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            'Additional Notes',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            additionalNotes,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildStatusBadge(String status) {
    final String normalized = status.trim();
    final PdfColor textColor = _pdfStatusColor(normalized);
    final PdfColor backgroundColor = _pdfStatusBackgroundColor(normalized);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: textColor, width: 0.5),
      ),
      child: pw.Text(
        normalized.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  pw.Widget _amountRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _cell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey900 : PdfColors.grey800,
        ),
      ),
    );
  }

  String _composeBusinessContact(BusinessModel? business) {
    final String email = (business?.invoiceBusinessEmail ?? business?.businessEmail ?? '').trim();
    final String phone = (business?.invoiceBusinessPhone ?? business?.phoneNumber ?? '').trim();
    if (email.isEmpty && phone.isEmpty) return '';
    if (email.isEmpty) return phone;
    if (phone.isEmpty) return email;
    return '$email / $phone';
  }

  String _firstNonEmpty(List<String?> values, {required String fallback}) {
    for (final String? value in values) {
      final String normalized = (value ?? '').trim();
      if (normalized.isNotEmpty) return normalized;
    }
    return fallback;
  }

  String _limitText(String value, int maxLength) {
    final String trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength).trimRight();
  }

  String? _pickCustomerField(List<dynamic> values) {
    for (final dynamic value in values) {
      final String normalized = value?.toString().trim() ?? '';
      if (normalized.isNotEmpty) return normalized;
    }
    return null;
  }

  String _money(num? amount, String currency) {
    final num value = amount ?? 0;
    return '$currency ${_cleanNum(value)}';
  }

  String _cleanNum(num value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  PdfColor _pdfStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PdfColors.green;
      case 'unpaid':
      case 'pending':
        return PdfColors.orange;
      case 'partialy-paid':
      case 'partially-paid':
      case 'partially paid':
        return PdfColors.blue;
      default:
        return PdfColors.grey700;
    }
  }

  PdfColor _pdfStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PdfColors.green100;
      case 'unpaid':
      case 'pending':
        return PdfColors.orange100;
      case 'partialy-paid':
      case 'partially-paid':
      case 'partially paid':
        return PdfColors.blue100;
      default:
        return PdfColors.grey200;
    }
  }

  num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  num _fallbackTotal(InvoiceItemModel item) {
    final num qty = _toNum(item.qty) ?? 0;
    final num unit = _toNum(item.unitPrice) ?? 0;
    return qty * unit;
  }
}
