import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/services/api_service.dart';

class TasksScreenController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxBool showFilter = false.obs;
  final RxString selectedDue = "".obs;
  final RxString selectedPriority = "".obs;
  final RxString selectedStatus = "".obs;

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  List<TaskModel> get filteredTasks {
    final String q = searchController.text.toLowerCase().trim();
    return tasks.where((task) {
      final bool matchesQuery = q.isEmpty ||
          task.taskTitle.toLowerCase().contains(q) ||
          task.description.toLowerCase().contains(q) ||
          (task.assignedEmployeeName ?? '').toLowerCase().contains(q);

      final bool matchesStatus = selectedStatus.value.isEmpty ||
          task.displayStatus.toLowerCase() == selectedStatus.value.toLowerCase();

      final bool matchesPriority = selectedPriority.value.isEmpty ||
          task.displayPriority.toLowerCase() == selectedPriority.value.toLowerCase();

      bool matchesDue = true;
      final DateTime? dueDate = task.dueDateParsed;
      if (selectedDue.value == "Today") {
        final DateTime now = DateTime.now();
        matchesDue = dueDate != null &&
            dueDate.year == now.year &&
            dueDate.month == now.month &&
            dueDate.day == now.day;
      } else if (selectedDue.value == "Tomorrow") {
        final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
        matchesDue = dueDate != null &&
            dueDate.year == tomorrow.year &&
            dueDate.month == tomorrow.month &&
            dueDate.day == tomorrow.day;
      } else if (selectedDue.value == "This Week") {
        if (dueDate == null) {
          matchesDue = false;
        } else {
          final DateTime now = DateTime.now();
          final DateTime weekEnd = now.add(const Duration(days: 7));
          matchesDue = dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
              dueDate.isBefore(weekEnd);
        }
      }

      return matchesQuery && matchesStatus && matchesPriority && matchesDue;
    }).toList();
  }

  void toggleFilter() => showFilter.value = !showFilter.value;

  void setDue(String val) {
    selectedDue.value = selectedDue.value == val ? "" : val;
  }

  void setPriority(String val) {
    selectedPriority.value = selectedPriority.value == val ? "" : val;
  }

  void setStatus(String val) {
    selectedStatus.value = selectedStatus.value == val ? "" : val;
  }

  void clearSelectedFilters() {
    selectedDue.value = "";
    selectedPriority.value = "";
    selectedStatus.value = "";
  }

  Future<void> fetchTasks() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.getAllTasks,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      tasks.assignAll(
        items
            .where((e) => e is Map)
            .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } else {
      tasks.clear();
      error.value = response.message;
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
