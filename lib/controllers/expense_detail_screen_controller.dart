import 'package:bizly/assets/images.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ExpenseDetailController extends GetxController {
  var title = ''.obs;
  var category = ''.obs;
  var amount = ''.obs;
  var status = ''.obs;
  var expenseDate = Rxn<DateTime>();
  var paymentMethod = ''.obs;
  var notes = ''.obs;

  // Naye fields jo screenshot mein hain
  var vendorName = ''.obs;
  var referenceNumber = ''.obs;
  var taxAmount = ''.obs;
  var projectName = ''.obs;
  var customerName = ''.obs;
  var receiptPath = ''.obs;
  var isRepeatMonthly = false.obs;

  Color getStatusColor() {
    switch (status.value.toLowerCase()) {
      case "paid": return Colors.green;
      case "pending": return Colors.orange;
      case "reimbursed": return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Screenshot ke mutabiq dummy data
    title.value = "Microsoft 365 Subscription";
    category.value = "IT Service";
    amount.value = "30";
    status.value = "Paid";
    expenseDate.value = DateTime(2026, 1, 1);
    paymentMethod.value = "Bank Transfer";
    notes.value = "Additional details about this expense";
receiptPath.value = AppImages.follower;
    vendorName.value = "Microsoft Corp";
    referenceNumber.value = "REF123456";
    taxAmount.value = "5.00";
    projectName.value = "Website Design";
    customerName.value = "Smith";
    isRepeatMonthly.value = true;
  }
}
