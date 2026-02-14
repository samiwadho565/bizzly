import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';

class InvoiceDetailController extends GetxController {
  final Rxn<InvoiceModel> model = Rxn<InvoiceModel>();

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
      default:
        return Colors.grey.shade300;
    }
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
}
