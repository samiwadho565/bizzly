import 'dart:io';

import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/business/controllers/business_activity_controller.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/date_formats.dart';

class CreateTaskController extends GetxController {
  final GlobalKey<FormState> createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> titleFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> descriptionFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey businessFieldKey = GlobalKey();
  final GlobalKey assignFieldKey = GlobalKey();
  final GlobalKey dueDateFieldKey = GlobalKey();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
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
  final RxList<BusinessModel> businesses = <BusinessModel>[].obs;
  final RxBool isBusinessesLoading = false.obs;
  final Rxn<TaskModel> editingTask = Rxn<TaskModel>();
  final RxnInt selectedBusinessId = RxnInt();
  final RxBool isBusinessLocked = false.obs;
  final RxString lockedBusinessName = ''.obs;
  final RxString lockedBusinessImageUrl = ''.obs;

  static const int taskTitleMax = 80;
  static const int taskDescriptionMax = 300;

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
      _applyBusinessSelectionFromArgs(args);
    }
    fetchDropdowns();
  }

  Future<void> fetchDropdowns() async {
    final List<Future<void>> requests = <Future<void>>[
      fetchEmployees(),
    ];
    final bool shouldSkipBusinessFetch =
        isBusinessLocked.value && selectedBusinessId.value != null;
    if (shouldSkipBusinessFetch) {
      _ensureLockedBusinessPresent();
      await Future.wait(requests);
      return;
    }
    requests.add(fetchBusinesses());
    await Future.wait(requests);
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

  Future<void> fetchBusinesses() async {
    if (isBusinessesLoading.value) return;
    isBusinessesLoading.value = true;

    final ApiResponse response = await ApiService().get(
      AppUrls.getAllBusinesses,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      businesses.assignAll(
        items
            .where((e) => e is Map)
            .map(
              (e) => BusinessModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );
      _resolveBusinessSelectionForEdit();
      _ensureLockedBusinessPresent();
    }

    isBusinessesLoading.value = false;
  }

  void prepareForCreate() {
    resetCreateForm();
    editingTask.value = null;
  }

  void prepareForEdit(TaskModel task) {
    isBusinessLocked.value = false;
    lockedBusinessName.value = '';
    lockedBusinessImageUrl.value = '';
    editingTask.value = task;
    titleController.text = task.taskTitle;
    descriptionController.text = task.description;
    selectedEmployeeId.value = task.assignTo;
    selectedBusinessId.value = task.businessId;
    selectedPriorityCreate.value = task.priority;
    selectedDueDate.value = task.dueDateParsed;
    selectedStatusCreate.value = task.status;
    existingAttachments.assignAll(task.attachments);
    selectedAttachments.clear();
    removingAttachmentIds.clear();
    _hydrateBusinessForEdit(task);
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
        businessId: current.businessId,
        businessName: current.businessName,
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
    final bool formOk = createFormKey.currentState?.validate() ?? false;
    if (!formOk) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstTextError();
      return;
    }

    final List<String> missing = _missingRequiredSelections();
    if (missing.isNotEmpty) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstSelectionError();
      _showMissingSelectionDialog(missing);
      return;
    }

    isSubmitting.value = true;

    final TaskModel request = TaskModel(
      taskTitle: titleController.text.trim(),
      assignTo: selectedEmployeeId.value,
      businessId: selectedBusinessId.value,
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
      businessId: createdFromResponse?.businessId ??
          request.businessId ??
          beforeEdit?.businessId,
      businessName: createdFromResponse?.businessName ??
          _businessNameById(request.businessId) ??
          beforeEdit?.businessName,
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

  String? _businessNameById(int? businessId) {
    if (businessId == null) return null;
    for (final BusinessModel business in businesses) {
      if (business.id == businessId) return business.businessName;
    }
    return null;
  }

  void resetCreateForm() {
    titleController.clear();
    descriptionController.clear();
    selectedBusinessId.value = null;
    isBusinessLocked.value = false;
    lockedBusinessName.value = '';
    lockedBusinessImageUrl.value = '';
    selectedEmployeeId.value = null;
    selectedPriorityCreate.value = 'medium';
    selectedDueDate.value = null;
    selectedStatusCreate.value = 'to do';
    existingAttachments.clear();
    selectedAttachments.clear();
    removingAttachmentIds.clear();
    editingTask.value = null;
  }

  List<TextInputFormatter> get taskTitleInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(taskTitleMax),
      ];

  List<TextInputFormatter> get taskDescriptionInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(taskDescriptionMax),
      ];

  List<String> _missingRequiredSelections() {
    final List<String> missing = <String>[];
    if (selectedBusinessId.value == null) missing.add('Business');
    if (selectedEmployeeId.value == null) missing.add('Assign To');
    if (selectedDueDate.value == null) missing.add('Due Date');
    return missing;
  }

  void _showMissingSelectionDialog(List<String> missing) {
    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogWarning,
      title: "Required Fields",
      message: 'Please provide: ${missing.join(', ')}',
      actions: [AppDialogAction(label: "Ok")],
    );
  }

  Future<void> _scrollToFirstTextError() async {
    final List<GlobalKey<FormFieldState<String>>> keysInOrder =
        <GlobalKey<FormFieldState<String>>>[
      titleFieldKey,
      descriptionFieldKey,
    ];

    for (final GlobalKey<FormFieldState<String>> key in keysInOrder) {
      final FormFieldState<String>? state = key.currentState;
      final BuildContext? context = key.currentContext;
      if (state?.hasError == true && context != null) {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
        return;
      }
    }
  }

  Future<void> _scrollToFirstSelectionError() async {
    final List<({bool invalid, GlobalKey key})> checks =
        <({bool invalid, GlobalKey key})>[
      (invalid: selectedBusinessId.value == null, key: businessFieldKey),
      (invalid: selectedEmployeeId.value == null, key: assignFieldKey),
      (invalid: selectedDueDate.value == null, key: dueDateFieldKey),
    ];

    for (final ({bool invalid, GlobalKey key}) check in checks) {
      if (!check.invalid) continue;
      final BuildContext? context = check.key.currentContext;
      if (context == null) continue;
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }
  }

  @override
  void onClose() {
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void setSelectedBusinessByName(String? businessName) {
    if (businessName == null || isBusinessLocked.value) return;
    final String normalized = businessName.trim();
    if (normalized.isEmpty) return;
    for (final BusinessModel business in businesses) {
      if (business.businessName == normalized) {
        selectedBusinessId.value = business.id;
        return;
      }
    }
  }

  String? get selectedBusinessName {
    final int? id = selectedBusinessId.value;
    if (id == null) return null;
    for (final BusinessModel business in businesses) {
      if (business.id == id) return business.businessName;
    }
    final String fromEdit = editingTask.value?.businessName?.trim() ?? '';
    if (fromEdit.isNotEmpty) return fromEdit;
    if (isBusinessLocked.value && lockedBusinessName.value.isNotEmpty) {
      return lockedBusinessName.value;
    }
    return null;
  }

  String? get selectedBusinessImageUrl {
    final int? id = selectedBusinessId.value;
    if (id != null) {
      for (final BusinessModel business in businesses) {
        if (business.id == id) return business.businessImageUrl;
      }
    }
    final String locked = lockedBusinessImageUrl.value.trim();
    if (locked.isNotEmpty) return locked;
    return null;
  }

  void _applyBusinessSelectionFromArgs(dynamic args) {
    if (args is BusinessModel && args.id != null) {
      selectedBusinessId.value = args.id;
      isBusinessLocked.value = true;
      lockedBusinessName.value = args.businessName;
      lockedBusinessImageUrl.value = args.businessImageUrl ?? '';
      return;
    }
    if (args is! Map) return;
    final dynamic businessIdRaw = args['businessId'] ?? args['business_id'];
    final int? businessId = _toInt(businessIdRaw);
    if (businessId == null) return;
    selectedBusinessId.value = businessId;
    final bool lock = args['lockBusiness'] == true || args['lock_business'] == true;
    isBusinessLocked.value = lock;
    final String name = (args['businessName'] ?? args['business_name'] ?? '')
        .toString()
        .trim();
    if (name.isNotEmpty) {
      lockedBusinessName.value = name;
    }
    final String imageUrl =
        (args['businessImageUrl'] ?? args['business_image_url'] ?? '')
            .toString()
            .trim();
    if (imageUrl.isNotEmpty) {
      lockedBusinessImageUrl.value = imageUrl;
    }
  }

  void _ensureLockedBusinessPresent() {
    final int? id = selectedBusinessId.value;
    if (id == null) return;
    if (businesses.any((b) => b.id == id)) return;
    final String fallbackName = lockedBusinessName.value.trim().isEmpty
        ? 'Business #$id'
        : lockedBusinessName.value.trim();
    businesses.add(
      BusinessModel(
        id: id,
        businessName: fallbackName,
        businessAddress: '',
        phoneNumber: '',
        currency: '',
        businessImageUrl: lockedBusinessImageUrl.value.trim().isEmpty
            ? null
            : lockedBusinessImageUrl.value.trim(),
      ),
    );
  }

  void _resolveBusinessSelectionForEdit() {
    if (selectedBusinessId.value != null) return;
    final String fromEdit = editingTask.value?.businessName?.trim() ?? '';
    if (fromEdit.isEmpty) return;
    for (final BusinessModel business in businesses) {
      if (business.businessName.trim().toLowerCase() == fromEdit.toLowerCase()) {
        selectedBusinessId.value = business.id;
        return;
      }
    }
  }

  Future<void> _hydrateBusinessForEdit(TaskModel task) async {
    if (selectedBusinessId.value == null &&
        Get.isRegistered<BusinessActivityController>()) {
      final BusinessModel? activeBusiness =
          Get.find<BusinessActivityController>().business.value;
      if (activeBusiness?.id != null) {
        selectedBusinessId.value = activeBusiness!.id;
        if (lockedBusinessName.value.trim().isEmpty) {
          lockedBusinessName.value = activeBusiness.businessName;
        }
        if (lockedBusinessImageUrl.value.trim().isEmpty) {
          lockedBusinessImageUrl.value = activeBusiness.businessImageUrl ?? '';
        }
      }
    }

    if (selectedBusinessId.value != null) return;
    final int? id = task.id;
    if (id == null) return;
    final TaskModel? fresh = await _fetchTaskById(id);
    if (fresh == null) return;
    if (selectedBusinessId.value == null) {
      selectedBusinessId.value = fresh.businessId;
    }
    final String fetchedBusinessName = fresh.businessName?.trim() ?? '';
    if (fetchedBusinessName.isNotEmpty && lockedBusinessName.value.trim().isEmpty) {
      lockedBusinessName.value = fetchedBusinessName;
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
