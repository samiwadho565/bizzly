import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceDetailController extends GetxController {
  // Required fields
  var clientName = "".obs;
  var businessName = "".obs;
  var itemName = "".obs;
  var amount = "".obs;
  var status = "".obs;
  var invoiceNumber = "".obs;
  var invoiceDate = Rxn<DateTime>();

  // Optional fields
  var notes = "".obs;
  var paymentMethod = "".obs;

  /// 🔹 Initialize with dummy data
  @override
  void onInit() {
    super.onInit();

    // Dummy data example
    clientName.value = "John Doe";
    businessName.value = "Acme Corp";
    itemName.value = "Web Design Service";
    amount.value = "\$1200";
    status.value = "Sent";
    invoiceNumber.value = "INV-2026-001";
    invoiceDate.value = DateTime.now();
    notes.value = "Payment due in 30 days.";
    paymentMethod.value = "Bank Transfer";
  }

  /// 🔹 Status color based on status
  Color getStatusColor() {
    switch (status.value.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "sent":
        return Colors.blue;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey.shade300;
    }
  }
}
