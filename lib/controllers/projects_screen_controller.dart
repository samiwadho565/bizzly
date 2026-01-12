import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectsScreenController extends GetxController {
  // Search
  final TextEditingController searchController = TextEditingController();

  // Filters visibility
  RxBool showFilter = false.obs;

  // Selected filters
  RxString selectedDue = "Today".obs;
  RxString selectedPriority = "Low".obs;
  RxString selectedStatus = "Active".obs;

  // Projects list
  RxList<Map<String, String>> projects = <Map<String, String>>[
    {
      "title": "Inventory Management",
      "owner": "John Deo",
      "status": "Low",
      "date": "10-02-2025 - 10-02-2026",
    },
    {
      "title": "Crypto Trading App",
      "owner": "Ali Traders",
      "status": "Active",
      "date": "26-11-2025 - 02-12-2025",
    },
    {
      "title": "E-Commerce Website",
      "owner": "Fixonto",
      "status": "Completed",
      "date": "01-01-2025 - 01-06-2025",
    },
    {
      "title": "HR Management System",
      "owner": "TechNova",
      "status": "High",
      "date": "15-03-2025 - 15-09-2025",
    },
  ].obs;

  // Toggle filter section
  void toggleFilter() {
    showFilter.value = !showFilter.value;
  }

  // Update filters
  void setDue(String value) => selectedDue.value = value;
  void setPriority(String value) => selectedPriority.value = value;
  void setStatus(String value) => selectedStatus.value = value;
}
