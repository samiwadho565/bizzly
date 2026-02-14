import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/expense/controllers/expenses_list_controller.dart';
import 'package:bizly/modules/expense/models/expense_model.dart';
import 'package:bizly/utils/date_formats.dart';

class ExpenseDetailController extends GetxController {
  final Rxn<ExpenseModel> model = Rxn<ExpenseModel>();

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
    final String id = model.value?.id?.toString() ?? '';
    if (id.isEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Missing ID",
        message: "Expense id not found.",
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }
    final String url = '${AppUrls.expensePdf}/$id/pdf';
    await _downloadFile(url, 'expense_$id', isPdf: true);
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
}
