import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/invoice/models/invoice_model.dart';
import 'package:bizly/modules/invoice/models/invoice_payment_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/date_formats.dart';

class CreateInvoicePaymentController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final Rxn<DateTime> paymentDate = Rxn<DateTime>();
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[].obs;
  final RxnInt selectedPaymentMethodId = RxnInt();
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<InvoiceModel> invoice = Rxn<InvoiceModel>();

  int? get invoiceId => invoice.value?.id;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is InvoiceModel) {
      invoice.value = args;
    }
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentMethods() async {
    isLoading.value = true;
    final ApiResponse response = await ApiService().get(
      AppUrls.paymentMethods,
      isAuth: true,
    );
    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      paymentMethods.assignAll(
        items.whereType<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      );
    }
    isLoading.value = false;
  }

  Future<void> submitPayment() async {
    if (isSubmitting.value) return;
    final int? id = invoiceId;
    if (id == null) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: 'Error!',
        message: 'Invoice not found.',
        actions: [AppDialogAction(label: 'Ok')],
      );
      return;
    }

    final bool ok = formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final List<String> missing = <String>[];
    if (paymentDate.value == null) missing.add('Payment Date');
    if (selectedPaymentMethodId.value == null) missing.add('Payment Method');
    if (missing.isNotEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: 'Required Fields',
        message: 'Please provide: ${missing.join(', ')}',
        actions: [AppDialogAction(label: 'Ok')],
      );
      return;
    }

    isSubmitting.value = true;
    final ApiResponse response = await ApiService().post(
      '${AppUrls.createInvoice}/$id/payments',
      isAuth: true,
      data: {
        'payment_amount': paymentAmountController.text.trim(),
        'payment_date': DateFormats.yyyyMmDd(paymentDate.value!),
        'payment_method_id': selectedPaymentMethodId.value?.toString(),
        'reference_number': referenceController.text.trim().isNotEmpty
            ? referenceController.text.trim()
            : null,
        'notes': notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
      },
    );
    isSubmitting.value = false;

    if (response.success) {
      InvoicePaymentModel? created;
      if (response.data is Map<String, dynamic>) {
        created = InvoicePaymentModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.data is Map) {
        created = InvoicePaymentModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: 'Payment Added!',
        message: response.message,
        actions: [
          AppDialogAction(
            label: 'Done',
            onPressed: () {
              Get.back(result: created ?? true);
            },
          ),
        ],
      );
      return;
    }

    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogWarning,
      title: 'Error!',
      message: response.message,
      actions: [AppDialogAction(label: 'Ok')],
    );
  }

  @override
  void onClose() {
    paymentAmountController.dispose();
    referenceController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
