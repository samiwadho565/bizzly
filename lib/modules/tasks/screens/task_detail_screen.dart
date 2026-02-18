import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/task_card_widget.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/tasks/controllers/task_detail_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/date_formats.dart';

class TaskDetailScreen extends GetView<TaskDetailController> {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Task Detail"),
      body: Obx(() {
        final task = controller.task.value;
        if (task == null) {
          return const Center(child: Text("Task not found"));
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskCardWidget(
                  priority: task.priorityLevel,
                  title: task.taskTitle,
                  subtitle: task.description,
                  date: _taskDate(task),
                  assignTo: task.assignedEmployeeName ?? "",
                  status: task.displayStatus,
                ),
                const SizedBox(height: 20),
                Text(
                  "Due Date",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _taskDate(task),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Assigned Employee",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap:  () {
                    controller.openAssignedEmployeeDetail();
                  },
                  child: Text(
                    task.assignedEmployeeName?.isNotEmpty == true
                        ? task.assignedEmployeeName!
                        : "-",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: task.assignTo == null
                          ? Colors.black87
                          : AppColors.primary,
                      decoration: task.assignTo == null
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.displayStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.statusColor,
                  ),
                ),
                const SizedBox(height: 20),
                if (task.attachments.isNotEmpty) ...[
                  const Text(
                    "Attachments",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: task.attachments.map((attachment) {
                      return GestureDetector(
                        onTap: () => _openImagePreview(context, attachment.fileUrl),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: attachment.fileUrl,
                                width: 95,
                                height: 95,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 95,
                                  height: 95,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 95,
                                  height: 95,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: GestureDetector(
                                onTap: () => controller.deleteAttachment(attachment),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Edit Task",
                        color: AppColors.textPrimary,
                        onPressed: controller.editTask,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Delete Task",
                        color: Colors.white,
                        textColor: Colors.red,
                        borderColor: Colors.red,
                        onPressed: controller.deleteTask,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _taskDate(TaskModel task) {
    final DateTime? parsed = task.dueDateParsed;
    if (parsed != null) return DateFormats.dMonY(parsed);
    final String raw = task.dueDate.trim();
    return raw.isEmpty ? "-" : raw;
  }

  void _openImagePreview(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () => _downloadImage(imageUrl),
                icon: const Icon(Icons.download, color: Colors.white),
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String ext = _extractExt(imageUrl);
      final String filePath =
          '${dir.path}/task_image_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Dio().download(imageUrl, filePath);
      Get.snackbar(
        "Downloaded",
        "Saved to $filePath",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        "Error",
        "Unable to download image",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _extractExt(String url) {
    final Uri? uri = Uri.tryParse(url);
    final String path = uri?.path ?? '';
    final String last = path.split('.').last.toLowerCase();
    if (last == 'png' || last == 'jpg' || last == 'jpeg' || last == 'webp') {
      return last;
    }
    return 'jpg';
  }
}
