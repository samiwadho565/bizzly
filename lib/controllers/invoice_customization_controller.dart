import 'package:bizly/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class InvoiceCustomizationController extends GetxController {
  // 🔹 Invoice Header
  var businessName = "Your Company Name".obs;
  var businessAddress = "Street, City, Country".obs;
  var businessEmail = "contact@bizly.com / +92 300 1234567".obs;
  var taxNo = "123456789".obs;

  // 🔹 Invoice Numbering
  var startNumber = "1001".obs;
  var prefix = "INV-".obs;
  var autoIncrement = "Enabled".obs;

  // 🔹 Customer Details
  var showEmail = "Yes".obs;
  var showPhone = "Yes".obs;
  var showNotes = "Optional".obs;

  // 🔹 Item & Table Settings
  var columns = "Item, Qty, Price, Tax, Total".obs;
  var currency = "PKR".obs;
  var precision = "2".obs;

  // 🔹 Payment Terms
  var dueDate = "15 days".obs;
  var lateFee = "5% if overdue".obs;

  // 🔹 Footer Notes
  var terms = "Default text".obs;
  var additionalNotes = "Optional message".obs;
  var thankYouMsg = "Enabled".obs;

  // 🔹 Colors & Theme
  var primaryColor = "Blue".obs;
  var bgColor = "White".obs;
  var fontStyle = "Default".obs;

  // Edit Logic
  void editField(String title, RxString observableValue) {
    TextEditingController textController = TextEditingController(text: observableValue.value);

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: Get.context!.mediaQueryViewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Edit $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomButton(text: "Save", onPressed: (){
                Get.back();
                observableValue.value = textController.text;
              })
            ),
          ],
        ),
      ),
    );
  }
}