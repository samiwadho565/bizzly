import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:bizly/modules/team/screens/team_screen/team_detail_screen.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/modules/team/models/employee_model.dart';

class TaskDetailController extends GetxController {
  final Rxn<TaskModel> task = Rxn<TaskModel>();
  final RxInt statusValue = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is TaskModel) {
      task.value = args;
      _setFromStatus(args.status);
    }
  }

  void _setFromStatus(String status) {
    final String value = status.toLowerCase();
    if (value == 'to do') {
      statusValue.value = 0;
      return;
    }
    if (value == 'in progress') {
      statusValue.value = 1;
      return;
    }
    statusValue.value = 2;
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

  Future<void> deleteAttachment(TaskAttachmentModel attachment) async {
    final int? taskId = task.value?.id;
    final int? attachmentId = attachment.id;
    if (taskId == null || attachmentId == null) return;

    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.deleteTaskAttachment}/$taskId/attachments/$attachmentId',
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (!response.success) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    final TaskModel? current = task.value;
    if (current == null) return;
    final List<TaskAttachmentModel> updated = current.attachments
        .where((a) => a.id != attachmentId)
        .toList();
    task.value = TaskModel(
      id: current.id,
      userId: current.userId,
      assignTo: current.assignTo,
      assignedEmployeeName: current.assignedEmployeeName,
      taskTitle: current.taskTitle,
      priority: current.priority,
      dueDate: current.dueDate,
      description: current.description,
      status: current.status,
      attachments: updated,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );

    if (Get.isRegistered<TasksScreenController>()) {
      Get.find<TasksScreenController>().fetchTasks();
    }
  }

  Future<void> openAssignedEmployeeDetail() async {
    final TaskModel? current = task.value;
    if (current == null || current.assignTo == null) return;


    AppDialogs.showLoading(message: "Loading employee...");
    final ApiResponse response = await ApiService().get(
      AppUrls.getAllEmployees,
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (!response.success) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    final dynamic raw = response.data;
    final List<dynamic> items = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] as List : []);

    EmployeeModel? employee;
    for (final dynamic item in items) {
      if (item is! Map) continue;
      final Map<String, dynamic> json = Map<String, dynamic>.from(item);
      final int? id = _toInt(json['id']);
      final int? userId = _toInt(json['user_id']);
      if (id == current.assignTo || userId == current.assignTo) {
        employee = EmployeeModel.fromJson(json);
        break;
      }
    }

    final EmployeeModel? foundEmployee = employee;
    if (foundEmployee == null) {
      Get.snackbar(
        "Not found",
        "Employee details not found",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.to(() => EmployeeDetailScreen(employee: foundEmployee));
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> editTask() async {
    final TaskModel? current = task.value;
    if (current == null) return;

    final dynamic result = await Get.toNamed(
      Routes.createTaskScreen,
      arguments: current,
    );
    if (result is TaskModel) {
      task.value = result;
      _setFromStatus(result.status);
    }
  }

  Future<void> deleteTask() async {
    final TaskModel? current = task.value;
    if (current?.id == null) return;

    AppDialogs.showConfirmation(
      title: "Delete Task",
      message: "Are you sure you want to delete this task?",
      onYes: () async {
        AppDialogs.showLoading(message: "Deleting...");
        final ApiResponse response = await ApiService().delete(
          '${AppUrls.deleteTask}/${current!.id}',
          isAuth: true,
        );
        AppDialogs.closeDialog();

        if (!response.success) {
          AppDialogs.showActionDialog(
            iconPath: AppImages.dialogWarning,
            title: "Error!",
            message: response.message,
            actions: [AppDialogAction(label: "Ok")],
          );
          return;
        }

        if (Get.isRegistered<TasksScreenController>()) {
          Get.find<TasksScreenController>().fetchTasks();
        }
        Get.back(result: true);
      },
    );
  }
}
