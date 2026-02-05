import 'package:get/get.dart';

class CreateInvoiceController extends GetxController {

  /// 🔹 Text Fields
  final clientName = ''.obs;
  final invoiceNumber = ''.obs;
  final itemName = ''.obs;
  final amount = ''.obs;
  final businessName = ''.obs;
  final notes = ''.obs;

  /// 🔹 Dropdowns
  final status = 'Unpaid'.obs;
  final paymentMethod = ''.obs;

  /// 🔹 Date
  final Rxn<DateTime> invoiceDate = Rxn<DateTime>();

  /// 🔹 Loading State (API ke liye)
  final isLoading = false.obs;

  /// 🔹 Validation
  bool validateForm() {
    if (clientName.value.isEmpty) {
      Get.snackbar("Error", "Client name is required");
      return false;
    }
    if (invoiceNumber.value.isEmpty) {
      Get.snackbar("Error", "Invoice number is required");
      return false;
    }
    if (invoiceDate.value == null) {
      Get.snackbar("Error", "Invoice date is required");
      return false;
    }
    if (itemName.value.isEmpty) {
      Get.snackbar("Error", "Item name is required");
      return false;
    }
    if (amount.value.isEmpty) {
      Get.snackbar("Error", "Amount is required");
      return false;
    }
    return true;
  }

  /// 🔹 Create Invoice (API placeholder)
  Future<void> createInvoice() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      /// 🔹 Payload (ready for API)
      final payload = {
        "client_name": clientName.value,
        "invoice_number": invoiceNumber.value,
        "invoice_date": invoiceDate.value.toString(),
        "status": status.value,
        "item_name": itemName.value,
        "amount": amount.value,
        "business_name": businessName.value,
        "notes": notes.value,
        "payment_method": paymentMethod.value,
      };

      /// TODO: API CALL
      /// await ApiService.createInvoice(payload);

      await Future.delayed(const Duration(seconds: 2)); // dummy delay

      Get.snackbar("Success", "Invoice created successfully");

      clearForm();

      /// optional: back to list
      Get.back();

    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Clear Form
  void clearForm() {
    clientName.value = '';
    invoiceNumber.value = '';
    itemName.value = '';
    amount.value = '';
    businessName.value = '';
    notes.value = '';
    paymentMethod.value = '';
    status.value = 'Unpaid';
    invoiceDate.value = null;
  }
}
