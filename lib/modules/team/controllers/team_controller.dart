import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/form_validations.dart';

class TeamController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;

  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Business selection for employee create/filter
  final Rxn<BusinessModel> selectedBusiness = Rxn<BusinessModel>();
  List<BusinessModel> get businesses =>
      Get.isRegistered<HomeScreenController>()
          ? Get.find<HomeScreenController>().businesses
          : <BusinessModel>[];

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

  final GlobalKey businessFieldKey = GlobalKey();
  final RxString businessError = ''.obs;

  final GlobalKey<FormFieldState<String>> nameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> emailFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> phoneFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> addressFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> roleFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> salaryFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> notesFieldKey =
      GlobalKey<FormFieldState<String>>();

  static const int employeeNameMax = 60;
  static const int employeeEmailMax = 80;
  static const int employeePhoneMax = 15;
  static const int employeeAddressMax = 160;
  static const int employeeRoleMax = 60;
  static const int employeeSalaryMax = 13;
  static const int employeeNotesMax = 300;

  @override
  void onInit() {
    super.onInit();
    // If navigated from Business Detail, a BusinessModel may be passed as argument
    final dynamic args = Get.arguments;
    if (args is BusinessModel) {
      selectedBusiness.value = args;
    } else if (args is Map && args['business'] is BusinessModel) {
      selectedBusiness.value = args['business'] as BusinessModel;
    }
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

    final Map<String, dynamic> query = <String, dynamic>{
      if (selectedBusiness.value?.id != null)
        'business_id': selectedBusiness.value!.id.toString(),
    };

    final ApiResponse response = await ApiService().get(
      AppUrls.getAllEmployees,
      queryParameters: query.isEmpty ? null : query,
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

  void prepareCreateForm(dynamic args) {
    if (args is EmployeeModel) {
      loadForEdit(args);
      return;
    }
    resetCreateForm();
    // Pre-select business if one is already selected in the list screen
    if (selectedBusiness.value != null) return;
    // Try to pre-select if only one business exists
    if (businesses.length == 1) {
      selectedBusiness.value = businesses.first;
    }
  }

  List<TextInputFormatter> get employeeNameInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(employeeNameMax),
      ];

  List<TextInputFormatter> get employeeEmailInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        LengthLimitingTextInputFormatter(employeeEmailMax),
      ];

  List<TextInputFormatter> get employeePhoneInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]')),
        LengthLimitingTextInputFormatter(employeePhoneMax),
      ];

  List<TextInputFormatter> get employeeAddressInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(employeeAddressMax),
      ];

  List<TextInputFormatter> get employeeRoleInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(employeeRoleMax),
      ];

  List<TextInputFormatter> get employeeSalaryInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(employeeSalaryMax),
      ];

  List<TextInputFormatter> get employeeNotesInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(employeeNotesMax),
      ];

  FormFieldValidator<String> get employeeNameValidator => (String? value) {
        return FormValidations.validateCommonName(
          value ?? '',
          fieldName: "Full Name",
          minLength: 3,
          maxLength: employeeNameMax,
        );
      };

  FormFieldValidator<String> get employeeEmailValidator => (String? value) {
        return FormValidations.validateCommonEmail(
          value ?? '',
          required: true,
          maxLength: employeeEmailMax,
        );
      };

  FormFieldValidator<String> get employeePhoneValidator => (String? value) {
        return FormValidations.validateCommonPhoneNumber(
          value ?? '',
          fieldName: "Phone Number",
          required: true,
          minDigits: 10,
          maxDigits: 15,
        );
      };

  FormFieldValidator<String> get employeeAddressValidator => (String? value) {
        return FormValidations.validateCommonAddress(
          value ?? '',
          fieldName: "Address",
          minLength: 3,
          maxLength: employeeAddressMax,
        );
      };

  FormFieldValidator<String> get employeeRoleValidator => (String? value) {
        return FormValidations.validateRequiredMinMax(
          value ?? '',
          fieldName: "Role",
          min: 2,
          max: employeeRoleMax,
        );
      };

  FormFieldValidator<String> get employeeSalaryValidator => (String? value) {
        return FormValidations.validateRequiredNumber(
          value ?? '',
          fieldName: "Salary",
        );
      };

  FormFieldValidator<String> get employeeNotesValidator => (String? value) {
        return FormValidations.validateCommonNotes(
          value ?? '',
          fieldName: "Notes",
          maxLength: employeeNotesMax,
        );
      };

  Future<void> submitEmployeeAndClose() async {
    if (isSubmitting.value) return;
    final bool wasEdit = isEdit;
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate business selection first
    if (selectedBusiness.value == null) {
      businessError.value = 'Business is required';
    } else {
      businessError.value = '';
    }

    final bool valid = createFormKey.currentState?.validate() ?? false;

    if (businessError.value.isNotEmpty || !valid) {
      await Future<void>.delayed(Duration.zero);
      // Scroll to business field first if that's the error, otherwise scroll to first form error
      if (businessError.value.isNotEmpty) {
        final BuildContext? ctx = businessFieldKey.currentContext;
        if (ctx != null) {
          await Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.15,
          );
        }
        return;
      }
      await _scrollToFirstError();
      return;
    }
    final EmployeeModel? saved = await submitEmployee();
    if (saved == null) return;

    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogSuccess,
      title: wasEdit ? "Employee Updated!" : "Employee Added!",
      message: wasEdit
          ? "Employee updated successfully."
          : "Employee created successfully.",
      actions: <AppDialogAction>[
        if (!wasEdit)
          AppDialogAction(
            label: "Create New Employee",
            onPressed: clearCreateFormAfterSuccess,
          ),
        AppDialogAction(
          label: "Done",
          onPressed: () {
            if (!wasEdit) {
              clearCreateFormAfterSuccess();
            }
            Get.back(result: saved);
          },
        ),
      ],
    );
  }

  Future<void> _scrollToFirstError() async {
    final List<GlobalKey<FormFieldState<String>>> keysInOrder =
        <GlobalKey<FormFieldState<String>>>[
      nameFieldKey,
      emailFieldKey,
      phoneFieldKey,
      addressFieldKey,
      roleFieldKey,
      salaryFieldKey,
      notesFieldKey,
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

  Future<EmployeeModel?> submitEmployee() async {
    if (isSubmitting.value) return null;
    FocusManager.instance.primaryFocus?.unfocus();

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
      businessId: selectedBusiness.value?.id,
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

    if (!response.success) {
      isSubmitting.value = false;
     // print(" response.message,  ${response.message}");
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

    if (!wasEdit) {
      isSubmitting.value = false;
      clearCreateFormAfterSuccess();
      return created;
    }
    final int? targetId = editedId ?? created?.id;
    if (targetId == null) {
      isSubmitting.value = false;
      clearCreateFormAfterSuccess();
      return created;
    }
    final EmployeeModel? fresh = await _fetchEmployeeById(targetId);
    isSubmitting.value = false;
    clearCreateFormAfterSuccess();
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
    businessError.value = '';
    // Keep selectedBusiness — user likely wants same business for next entry
  }

  void clearCreateFormAfterSuccess() {
    resetCreateForm();
    createFormKey.currentState?.reset();
    final List<GlobalKey<FormFieldState<String>>> keys =
        <GlobalKey<FormFieldState<String>>>[
      nameFieldKey,
      emailFieldKey,
      phoneFieldKey,
      addressFieldKey,
      roleFieldKey,
      salaryFieldKey,
      notesFieldKey,
    ];
    for (final GlobalKey<FormFieldState<String>> key in keys) {
      key.currentState?.didChange('');
      key.currentState?.reset();
    }
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
    _restoreBusinessForEmployee(employee);
    // If business still not resolved (list API doesn't return business_id),
    // fetch the single-employee endpoint which usually has the full data.
    if (selectedBusiness.value == null && employee.id != null) {
      _enrichBusinessFromApi(employee.id!);
    }
  }

  Future<void> _enrichBusinessFromApi(int employeeId) async {
    final EmployeeModel? fresh = await _fetchEmployeeById(employeeId);
    if (fresh == null) return;
    // Don't overwrite if user already picked something manually
    if (selectedBusiness.value != null) return;
    final int? bizId = fresh.businessId;
    if (bizId == null) return;
    final BusinessModel? match = _findBusinessById(bizId);
    if (match != null) {
      selectedBusiness.value = match;
      return;
    }
    // businesses list may still be loading — watch for it
    if (Get.isRegistered<HomeScreenController>()) {
      Worker? worker;
      worker = ever<List<BusinessModel>>(
        Get.find<HomeScreenController>().businesses,
        (list) {
          if (selectedBusiness.value != null) { worker?.dispose(); return; }
          for (final BusinessModel b in list) {
            if (b.id == bizId) { selectedBusiness.value = b; break; }
          }
          if (list.isNotEmpty) worker?.dispose();
        },
      );
    }
  }

  void _restoreBusinessForEmployee(EmployeeModel employee) {
    final int? bizId = employee.businessId;

    if (bizId != null) {
      // Try immediately if businesses already loaded
      final BusinessModel? match = _findBusinessById(bizId);
      if (match != null) {
        selectedBusiness.value = match;
        return;
      }
      // Businesses might not be loaded yet — react when they do
      if (Get.isRegistered<HomeScreenController>()) {
        Worker? worker;
        worker = ever<List<BusinessModel>>(
          Get.find<HomeScreenController>().businesses,
          (list) {
            if (list.isEmpty) return;
            for (final BusinessModel b in list) {
              if (b.id == bizId) {
                selectedBusiness.value = b;
                break;
              }
            }
            worker?.dispose();
          },
        );
      }
      return;
    }

    // businessId is null (API doesn't return it) — use best available fallback:
    // 1. If selectedBusiness is already set (e.g. came from business-filtered list), keep it
    if (selectedBusiness.value != null) return;

    // 2. If only one business exists, it must be the employee's business
    final List<BusinessModel> biz = businesses;
    if (biz.length == 1) {
      selectedBusiness.value = biz.first;
      return;
    }

    // 3. Businesses not loaded yet — wait and retry once
    if (biz.isEmpty && Get.isRegistered<HomeScreenController>()) {
      Worker? worker;
      worker = ever<List<BusinessModel>>(
        Get.find<HomeScreenController>().businesses,
        (list) {
          worker?.dispose();
          if (selectedBusiness.value != null) return;
          if (list.length == 1) selectedBusiness.value = list.first;
        },
      );
    }
  }

  BusinessModel? _findBusinessById(int id) {
    for (final BusinessModel b in businesses) {
      if (b.id == id) return b;
    }
    return null;
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
