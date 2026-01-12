import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TasksScreenController extends GetxController {
  // Search controller
  TextEditingController searchController = TextEditingController();

  // Filter visibility
  RxBool showFilter = false.obs;

  // Selected filters
  RxString selectedDue = "Today".obs;
  RxString selectedPriority = "Low".obs;
  RxString selectedStatus = "In Progress".obs;

  // Tasks list
  RxList<Map<String, String>> tasks = <Map<String, String>>[
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

  // Toggle filter visibility
  void toggleFilter() {
    showFilter.value = !showFilter.value;
  }

  // Update selected filters
  void setDue(String val) => selectedDue.value = val;
  void setPriority(String val) => selectedPriority.value = val;
  void setStatus(String val) => selectedStatus.value = val;
}
