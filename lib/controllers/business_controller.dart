import 'package:get/get.dart';

class BusinessDetailController extends GetxController {
  /// Selected Tab
  var selectedTab = 'Overview'.obs;

  /// Tasks List
  final tasks = <Map<String, String>>[
    {
      "title": "Inventory",
      "subtitle": "Manage inventory stock",
      "date": "19-12-2026",
      "user": "John Deo",
      "status": "Low",
    },
    {
      "title": "Update Prices",
      "subtitle": "Revise product pricing",
      "date": "20-12-2026",
      "user": "Ali Traders",
      "status": "Medium",
    },
    {
      "title": "Server Backup",
      "subtitle": "Weekly system backup",
      "date": "22-12-2026",
      "user": "Tech Team",
      "status": "High",
    },
    {
      "title": "UI Improvements",
      "subtitle": "Dashboard UI polishing",
      "date": "25-12-2026",
      "user": "Design Team",
      "status": "Low",
    },
  ].obs;

  /// Invoices List
  final invoices = <Map<String, String>>[
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
  ].obs;

  /// Tab change handler
  void changeTab(String tab) {
    selectedTab.value = tab;
  }
}
