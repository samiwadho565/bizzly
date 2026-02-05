import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceScreenController extends GetxController {
  // Search
  final TextEditingController searchController = TextEditingController();

  // Selected status
  RxString selectedStatus = "Paid".obs;

  // Invoice list
  RxList<Map<String, String>> invoices = <Map<String, String>>[
    {
      "client": "John Doe",
      "business": "TechNova",
      "item": "Website Design",
      "amount": "\$500",
      "status": "Paid",
    },
    {
      "client": "Robert De Niro",
      "business": "Crypto Trading",
      "item": "Mobile App",
      "amount": "\$1200",
      "status": "Paid",
    },
    {
      "client": "Jack Smith",
      "business": "Fixonto",
      "item": "Backend Setup",
      "amount": "\$800",
      "status": "Paid",
    },
  ].obs;

  // Change status
  void setStatus(String value) {
    selectedStatus.value = value;
  }
}
