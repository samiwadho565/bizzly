import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/expense/controllers/expenses_list_controller.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';
import 'package:bizly/modules/invoice/screens/invoice_pdf_preview_screen.dart';
import 'package:bizly/utils/date_formats.dart';

class ExpenseDetailController extends GetxController {
  final Rxn<ExpenseModel> model = Rxn<ExpenseModel>();
  final RxBool isDownloadingPdf = false.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is ExpenseModel) {
      model.value = args;
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String formattedUpdatedAt() {
    final String? raw = model.value?.updatedAt;
    final DateTime? dt = _parseDate(raw);
    if (dt == null) return raw ?? '';
    return DateFormats.hMmAmPmDMonY(dt);
  }

  Future<void> downloadReceipt() async {
    final String url = model.value?.receiptUrl ?? '';
    if (url.isEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "No Receipt",
        message: "Receipt not available for this expense.",
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }
    await _downloadFile(url, 'receipt');
  }

  Future<void> deleteExpense() async {
    final String id = model.value?.id?.toString() ?? '';
    if (id.isEmpty) return;

    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.deleteExpense}/$id',
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (response.success) {
      if (Get.isRegistered<ExpensesListController>()) {
        Get.find<ExpensesListController>().fetchExpenses();
      }
      Get.back();
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: "Deleted",
        message: "Expense deleted successfully.",
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
      title: "Delete Expense?",
      message: "Are you sure you want to delete this expense?",
      actions: [
        AppDialogAction(label: "Cancel"),
        AppDialogAction(
          label: "Delete",
          textColor: Colors.red,
          onPressed: () {
            deleteExpense();
          },
        ),
      ],
    );
  }

  Future<void> downloadPdf() async {
    if (isDownloadingPdf.value) return;
    final ExpenseModel? expense = model.value;
    if (expense?.id == null) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Missing ID",
        message: "Expense id not found.",
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }
    isDownloadingPdf.value = true;
    try {
      final Uint8List pdfBytes = await _buildExpensePdfBytes(expense!);
      final String filePath = await _saveExpensePdfFile(expense.id!, pdfBytes);
      await Get.to(
        () => InvoicePdfPreviewScreen(
          bytes: pdfBytes,
          filePath: filePath,
          title: 'Expense PDF Preview',
        ),
      );
    } catch (_) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "PDF Failed",
        message: "Unable to generate expense PDF. Please try again.",
        actions: [AppDialogAction(label: "Ok")],
      );
    } finally {
      isDownloadingPdf.value = false;
    }
  }

  Future<void> _downloadFile(
    String url,
    String namePrefix, {
    bool isPdf = false,
  }) async {
    try {
      AppDialogs.showLoading(message: "Downloading...");
      final Directory dir = await getApplicationDocumentsDirectory();
      final String ext = isPdf ? 'pdf' : _inferExtension(url);
      final String filePath =
          '${dir.path}/${namePrefix}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final Dio dio = Dio(
        BaseOptions(baseUrl: AppUrls.baseUrl),
      );
      final String? token = await LocalStorage.getAuthToken();
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final String resolved = _resolveUrl(url);
      await dio.download(resolved, filePath);
      AppDialogs.closeDialog();
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: "Downloaded",
        message: "Saved to $filePath",
        actions: [AppDialogAction(label: "Ok")],
      );
    } catch (_) {
      AppDialogs.closeDialog();
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Download Failed",
        message: "Unable to download file. Please try again.",
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${AppUrls.baseUrl}$url';
  }

  String _inferExtension(String url) {
    final Uri? uri = Uri.tryParse(url);
    final String path = uri?.path ?? url;
    final int dot = path.lastIndexOf('.');
    if (dot != -1 && dot < path.length - 1) {
      return path.substring(dot + 1);
    }
    return 'jpg';
  }

  Future<String> _saveExpensePdfFile(int id, Uint8List bytes) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath =
        '${dir.path}/expense_${id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  Future<Uint8List> _buildExpensePdfBytes(ExpenseModel expense) async {
    final pw.Document doc = pw.Document();
    final num amount = _toNum(expense.amount) ?? 0;
    final num taxAmount = _toNum(expense.taxAmount) ?? 0;
    final num subtotal = amount - taxAmount;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context context) => <pw.Widget>[
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(18),
              border: pw.Border.all(color: PdfColors.grey200, width: 0.6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildExpensePdfHeader(expense),
                pw.SizedBox(height: 16),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _buildDetailsSection(
                        title: 'EXPENSE INFORMATION',
                        rows: <pw.Widget>[
                          _pdfRow('Title', expense.title),
                          _pdfRow('Category', expense.categoryName),
                          _pdfRow('Expense Date', expense.expenseDate),
                          _pdfRow('Payment Method', expense.paymentMethodName),
                          _pdfRow('Reference Number', expense.referenceNumber),
                          _pdfRow('Updated At', formattedUpdatedAt()),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildDetailsSection(
                        title: 'RELATED RECORDS',
                        rows: <pw.Widget>[
                          _pdfRow('Business', expense.businessName),
                          _pdfRow('Vendor', expense.vendorName),
                          _pdfRow('Customer', expense.customerName),
                          _pdfRow('Project', expense.projectName),
                          _pdfRow('Expense Type', expense.expenseType),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                if ((expense.notes ?? '').trim().isNotEmpty) ...[
                  _buildNotesBox(expense.notes!.trim()),
                  pw.SizedBox(height: 12),
                ],
                _buildAmountSummary(
                  subtotal: subtotal < 0 ? 0 : subtotal,
                  tax: taxAmount,
                  total: amount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _buildExpensePdfHeader(ExpenseModel expense) {
    final String idLabel = expense.id == null ? '-' : '#${expense.id}';
    final String dateLabel = _cleanText(expense.expenseDate);
    final String typeLabel = _cleanText(expense.expenseType).toUpperCase();
    final String generatedOn = DateFormats.dMonY(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(14),
            border: pw.Border.all(color: PdfColors.blue100, width: 0.7),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Expense Report',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on $generatedOn',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              _buildChip(typeLabel == 'N/A' ? 'EXPENSE' : typeLabel),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildMetaPill(
                label: 'Expense ID',
                value: idLabel,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _buildMetaPill(
                label: 'Expense Date',
                value: dateLabel,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _buildMetaPill(
                label: 'Updated At',
                value: formattedUpdatedAt(),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey200, height: 1),
      ],
    );
  }

  pw.Widget _buildDetailsSection({
    required String title,
    required List<pw.Widget> rows,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  pw.Widget _buildNotesBox(String notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.amber100, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'NOTES',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            notes,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAmountSummary({
    required num subtotal,
    required num tax,
    required num total,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.green100, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Amount Summary',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 10),
                _amountRow('Subtotal', _money(subtotal)),
                _amountRow('Tax', _money(tax)),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          _buildGrandTotalCard(total),
        ],
      ),
    );
  }

  pw.Widget _pdfRow(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 88,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9.2,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _cleanText(value),
              style: const pw.TextStyle(fontSize: 9.8, color: PdfColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildChip(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue800,
        borderRadius: pw.BorderRadius.circular(11),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _amountRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey900,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetaPill({
    required String label,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8.2, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _cleanText(value),
            style: pw.TextStyle(
              fontSize: 9.4,
              color: PdfColors.grey900,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGrandTotalCard(num total) {
    return pw.Container(
      width: 132,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.green800,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TOTAL',
            style: pw.TextStyle(
              fontSize: 8.8,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            _money(total),
            style: pw.TextStyle(
              fontSize: 13,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _cleanText(String? value) {
    final String normalized = (value ?? '').trim();
    return normalized.isEmpty ? 'N/A' : normalized;
  }

  String _money(num value) {
    return 'PKR ${_cleanNum(value)}';
  }

  num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  String _cleanNum(num value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }
}
