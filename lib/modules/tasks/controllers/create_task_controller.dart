import 'dart:io';

import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/date_formats.dart';

class CreateTaskController extends GetxController {
  final GlobalKey<FormState> createFormKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxnInt selectedEmployeeId = RxnInt();
  final RxString selectedPriorityCreate = 'medium'.obs;
  final Rxn<DateTime> selectedDueDate = Rxn<DateTime>();
  final RxString selectedStatusCreate = 'to do'.obs;
  final RxList<TaskAttachmentModel> existingAttachments =
      <TaskAttachmentModel>[].obs;
  final RxList<File> selectedAttachments = <File>[].obs;
  final RxList<int> removingAttachmentIds = <int>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxBool isEmployeesLoading = false.obs;
  final Rxn<TaskModel> editingTask = Rxn<TaskModel>();

  final ImagePicker _picker = ImagePicker();

  bool get isEditMode => editingTask.value?.id != null;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is TaskModel) {
      prepareForEdit(args);
    } else {
      prepareForCreate();
    }
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    if (isEmployeesLoading.value) return;
    isEmployeesLoading.value = true;

    final ApiResponse response = await ApiService().get(
      AppUrls.getAllEmployees,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      employees.assignAll(
        items
            .where((e) => e is Map)
            .map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    }

    isEmployeesLoading.value = false;
  }

  void prepareForCreate() {
    resetCreateForm();
    editingTask.value = null;
  }

  void prepareForEdit(TaskModel task) {
    editingTask.value = task;
    titleController.text = task.taskTitle;
    descriptionController.text = task.description;
    selectedEmployeeId.value = task.assignTo;
    selectedPriorityCreate.value = task.priority;
    selectedDueDate.value = task.dueDateParsed;
    selectedStatusCreate.value = task.status;
    existingAttachments.assignAll(task.attachments);
    selectedAttachments.clear();
    removingAttachmentIds.clear();
  }

  Future<void> pickAttachments() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    selectedAttachments.addAll(files.map((e) => File(e.path)));
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= selectedAttachments.length) return;
    selectedAttachments.removeAt(index);
  }

  Future<void> removeExistingAttachment(TaskAttachmentModel attachment) async {
    final int? taskId = editingTask.value?.id;
    final int? attachmentId = attachment.id;
    if (taskId == null || attachmentId == null) return;
    if (removingAttachmentIds.contains(attachmentId)) return;

    removingAttachmentIds.add(attachmentId);
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.deleteTaskAttachment}/$taskId/attachments/$attachmentId',
      isAuth: true,
    );
    removingAttachmentIds.remove(attachmentId);

    if (!response.success) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    existingAttachments.removeWhere((a) => a.id == attachmentId);
    final TaskModel? current = editingTask.value;
    if (current != null) {
      editingTask.value = TaskModel(
        id: current.id,
        userId: current.userId,
        assignTo: current.assignTo,
        assignedEmployeeName: current.assignedEmployeeName,
        taskTitle: current.taskTitle,
        priority: current.priority,
        dueDate: current.dueDate,
        description: current.description,
        status: current.status,
        attachments: existingAttachments.toList(),
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );
    }
  }

  Future<void> submitTask() async {

    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(createFormKey.currentState?.validate() ?? false)) return;

    final List<String> missing = <String>[];
    if (selectedEmployeeId.value == null) missing.add('Assign To');
    if (selectedDueDate.value == null) missing.add('Due Date');
    if (missing.isNotEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Required Fields",
        message: 'Please provide: ${missing.join(', ')}',
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    isSubmitting.value = true;

    final TaskModel request = TaskModel(
      taskTitle: titleController.text.trim(),
      assignTo: selectedEmployeeId.value,
      priority: selectedPriorityCreate.value,
      dueDate: DateFormats.yyyyMmDd(selectedDueDate.value!),
      description: descriptionController.text.trim(),
      status: selectedStatusCreate.value,
      attachmentFiles: selectedAttachments.toList(),
    );

    final bool isEdit = isEditMode && editingTask.value?.id != null;
    final TaskModel? beforeEdit = editingTask.value;
    final int? editedId = editingTask.value?.id;
    final ApiResponse response = isEdit
        ? await ApiService().postMultipart(
            '${AppUrls.updateTask}/${editingTask.value!.id}',
            data: request.toJson(),
            isAuth: true,
          )
        : await ApiService().postMultipart(
            AppUrls.createTask,
            data: request.toJson(),
            isAuth: true,
          );

    if (!response.success) {
      isSubmitting.value = false;
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    TaskModel? createdFromResponse;
    if (response.data is Map) {
      createdFromResponse = TaskModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    final int? resolvedAssignTo = createdFromResponse?.assignTo ??
        request.assignTo ??
        beforeEdit?.assignTo;
    final String? resolvedAssignedName = createdFromResponse
            ?.assignedEmployeeName
            ?.trim()
            .isNotEmpty ==
        true
        ? createdFromResponse!.assignedEmployeeName
        : _employeeNameById(resolvedAssignTo) ?? beforeEdit?.assignedEmployeeName;
    final List<TaskAttachmentModel> resolvedAttachments =
        createdFromResponse != null && createdFromResponse.attachments.isNotEmpty
            ? createdFromResponse.attachments
            : existingAttachments.toList();

    final TaskModel created = TaskModel(
      id: createdFromResponse?.id ?? beforeEdit?.id,
      userId: createdFromResponse?.userId ?? beforeEdit?.userId,
      assignTo: resolvedAssignTo,
      assignedEmployeeName: resolvedAssignedName,
      taskTitle: createdFromResponse?.taskTitle.isNotEmpty == true
          ? createdFromResponse!.taskTitle
          : request.taskTitle,
      priority: createdFromResponse?.priority.isNotEmpty == true
          ? createdFromResponse!.priority
          : request.priority,
      dueDate: createdFromResponse?.dueDate.isNotEmpty == true
          ? createdFromResponse!.dueDate
          : request.dueDate,
      description: createdFromResponse?.description.isNotEmpty == true
          ? createdFromResponse!.description
          : request.description,
      status: createdFromResponse?.status.isNotEmpty == true
          ? createdFromResponse!.status
          : request.status,
      attachments: resolvedAttachments,
      createdAt: createdFromResponse?.createdAt ?? beforeEdit?.createdAt,
      updatedAt: createdFromResponse?.updatedAt ?? beforeEdit?.updatedAt,
    );

    TaskModel? doneResult;
    if (Get.isRegistered<TasksScreenController>()) {
      await Get.find<TasksScreenController>().fetchTasks();
    }
    if (isEdit) {
      final int? targetId = editedId ?? created.id;
      doneResult = targetId == null ? null : await _fetchTaskById(targetId);
    }

    isSubmitting.value = false;

    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogSuccess,
      title: isEdit ? "Task Updated!" : "Task Added!",
      message: isEdit
          ? "Task has been updated successfully."
          : "Task has been added successfully.",
      actions: isEdit
          ? [
              AppDialogAction(
                label: "Done",
                onPressed: () {
                  resetCreateForm();
                  Get.back(result: doneResult ?? created);
                },
              ),
            ]
          : [
              AppDialogAction(
                label: "Add New Task",
                onPressed: resetCreateForm,
              ),
              AppDialogAction(
                label: "Done",
                onPressed: () {
                  resetCreateForm();
                  Get.back(result: created);
                },
              ),
            ],
    );
  }

  Future<TaskModel?> _fetchTaskById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllTasks}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    return TaskModel.fromJson(payload);
  }

  String? _employeeNameById(int? employeeId) {
    if (employeeId == null) return null;
    for (final EmployeeModel emp in employees) {
      if (emp.id == employeeId || emp.userId == employeeId) {
        return emp.fullName;
      }
    }
    return null;
  }

  void resetCreateForm() {
    titleController.clear();
    descriptionController.clear();
    selectedEmployeeId.value = null;
    selectedPriorityCreate.value = 'medium';
    selectedDueDate.value = null;
    selectedStatusCreate.value = 'to do';
    existingAttachments.clear();
    selectedAttachments.clear();
    removingAttachmentIds.clear();
    editingTask.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
