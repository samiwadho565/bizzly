import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/tasks_model.dart';

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

  // ✅ Tasks list using Model
  RxList<TaskModel> tasks = <TaskModel>[
    TaskModel(
      title: "Inventory",
      description: "Manage inventory stock",
      dueDate: DateTime(2026, 12, 19),
      assignedTo: "John Deo",
      priority: 3,
      status: "Pending", id: '1',
      // createdAt: null,
    ),
    TaskModel(
      title: "Update Prices",
      description: "Revise product pricing",
      dueDate: DateTime(2026, 12, 20),
      assignedTo: "Ali Traders",
      priority: 2,
      status: "In Progress", id: '',
    ),
    TaskModel(
      title: "Server Backup",
      description: "Weekly system backup",
      dueDate: DateTime(2026, 12, 22),
      assignedTo: "Tech Team",
      priority: 1,
      status: "Pending", id: '',
    ),
    TaskModel(
      title: "UI Improvements",
      description: "Dashboard UI polishing",
      dueDate: DateTime(2026, 12, 25),
      assignedTo: "Design Team",
      priority:3,
      status: "Completed", id: '',
    ),
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
