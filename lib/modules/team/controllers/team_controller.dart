import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';

class TeamController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;

  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final GlobalKey<FormState> createFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final RxString status = 'active'.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<EmployeeModel> editingEmployee = Rxn<EmployeeModel>();

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  List<EmployeeModel> get filteredEmployees {
    final String q = query.value.toLowerCase().trim();
    if (q.isEmpty) return employees;
    return employees.where((e) {
      return e.fullName.toLowerCase().contains(q) ||
          e.role.toLowerCase().contains(q) ||
          e.phoneNumber.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> fetchEmployees() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

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
            .whereType<Map<String, dynamic>>()
            .map((e) => EmployeeModel.fromJson(e))
            .toList(),
      );
    } else {
      employees.clear();
      error.value = response.message;
    }

    isLoading.value = false;
  }

  bool get isEdit => editingEmployee.value?.id != null;

  Future<EmployeeModel?> submitEmployee() async {
    if (isSubmitting.value) return null;
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(createFormKey.currentState?.validate() ?? false)) return null;

    isSubmitting.value = true;

    final EmployeeModel request = EmployeeModel(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      address: addressController.text.trim(),
      role: roleController.text.trim(),
      salary: salaryController.text.trim(),
      status: status.value,
      notes: notesController.text.trim(),
    );

    final bool wasEdit = isEdit;
    final int? editedId = editingEmployee.value?.id;
    final String endpoint =
        wasEdit ? '${AppUrls.updateEmployee}/${editingEmployee.value!.id}' : AppUrls.createEmployee;

    final ApiResponse response = await ApiService().post(
      endpoint,
      data: request.toJson(),
      isAuth: true,
    );

    isSubmitting.value = false;

    if (!response.success) {
      AppUtils.showAppSnackbar(
        "Error",
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.error,
        backgroundColor: Colors.red.shade100,
        textColor: Colors.black,
      );
      return null;
    }

    EmployeeModel? created;
    if (response.data is Map) {
      created = EmployeeModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } else {
      final EmployeeModel? current = editingEmployee.value;
      created = EmployeeModel(
        id: current?.id,
        userId: current?.userId,
        fullName: request.fullName,
        email: request.email,
        phoneNumber: request.phoneNumber,
        address: request.address,
        role: request.role,
        salary: request.salary,
        status: request.status,
        notes: request.notes,
        createdAt: current?.createdAt,
        updatedAt: DateTime.now().toString(),
      );
    }

    if (Get.isRegistered<TeamController>()) {
      await Get.find<TeamController>().fetchEmployees();
    } else {
      await fetchEmployees();
    }

    if (!wasEdit) return created;
    final int? targetId = editedId ?? created?.id;
    if (targetId == null) return created;
    final EmployeeModel? fresh = await _fetchEmployeeById(targetId);
    return fresh ?? created;
  }

  Future<void> deleteEmployee(EmployeeModel employee) async {
    if (employee.id == null) return;
    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.deleteEmployee}/${employee.id}',
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (response.success) {
      employees.removeWhere((e) => e.id == employee.id);
      return;
    }

    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogWarning,
      title: "Error!",
      message: response.message,
      actions: [AppDialogAction(label: "Ok")],
    );
  }

  Future<CustomerModel?> fetchCustomerByUserId(int userId) async {
    final ApiResponse singleResponse = await ApiService().get(
      '${AppUrls.createCustomer}/$userId',
      isAuth: true,
    );

    if (singleResponse.success && singleResponse.data is Map) {
      final Map<String, dynamic> raw = Map<String, dynamic>.from(
        singleResponse.data as Map,
      );
      if (raw['customer_name'] != null) {
        return CustomerModel.fromJson(raw);
      }
      if (raw['data'] is Map) {
        return CustomerModel.fromJson(
          Map<String, dynamic>.from(raw['data'] as Map),
        );
      }
    }

    final ApiResponse listResponse = await ApiService().get(
      AppUrls.createCustomer,
      isAuth: true,
    );
    if (!listResponse.success) return null;

    final dynamic rawList = listResponse.data;
    final List<dynamic> items = rawList is List
        ? rawList
        : (rawList is Map && rawList['data'] is List ? rawList['data'] as List : []);

    for (final dynamic item in items) {
      if (item is! Map) continue;
      final Map<String, dynamic> json = Map<String, dynamic>.from(item);
      final int? candidateUserId = _toInt(json['user_id']);
      if (candidateUserId == userId) {
        return CustomerModel.fromJson(json);
      }
    }

    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<EmployeeModel?> _fetchEmployeeById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllEmployees}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    return EmployeeModel.fromJson(payload);
  }

  void resetCreateForm() {
    editingEmployee.value = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    roleController.clear();
    salaryController.clear();
    notesController.clear();
    status.value = 'active';
  }

  void loadForEdit(EmployeeModel employee) {
    editingEmployee.value = employee;
    nameController.text = employee.fullName;
    emailController.text = employee.email;
    phoneController.text = employee.phoneNumber;
    addressController.text = employee.address;
    roleController.text = employee.role;
    salaryController.text = employee.salary?.toString() ?? '';
    notesController.text = employee.notes ?? '';
    status.value = employee.status.toLowerCase();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    roleController.dispose();
    salaryController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
