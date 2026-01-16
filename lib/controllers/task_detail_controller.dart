import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/tasks_model.dart';


class TaskDetailController extends GetxController {
  // Status slider
  RxInt statusValue = 0.obs;

  // TaskModel ko store karne ke liye
  late TaskModel task;

  @override
  void onInit() {
    super.onInit();

    // 🔹 Dummy Data Assign
    task = TaskModel(
      id: "1",
      title: "Design Landing Page",
      description: "Create a modern and responsive landing page for the new product.",
      status: "In Progress",
      dueDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now(),
      assignedTo: "Sami Wadho",
      priority: 1,
      companyName: "Bizly Inc.",
      attachments: ["file1.pdf", "file2.docx"],
      relatedProject: "Website Redesign",
    );

    // Status Slider ko update karo model se
    setFromStatus(task.status);
  }

  void setFromStatus(String status) {
    statusValue.value = status == "To-Do"
        ? 0
        : status == "In Progress"
        ? 1
        : 2;
  }

  String get statusText {
    switch (statusValue.value) {
      case 0:
        return "To-Do";
      case 1:
        return "In Progress";
      default:
        return "Done";
    }
  }

  Color get statusColor {
    switch (statusValue.value) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
