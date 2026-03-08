import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/company_assets/models/assets_model.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/date_formats.dart';
import 'package:bizly/utils/form_validations.dart';

class CompanyAssetsController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxList<AssetModel> filtered = <AssetModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isDeleting = false.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> assetNameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> assetTypeFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> valueFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey assignedToFieldKey = GlobalKey();
  final GlobalKey purchaseDateFieldKey = GlobalKey();
  final TextEditingController assetNameController = TextEditingController();
  final TextEditingController assetTypeController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController();
  final RxnInt selectedEmployeeId = RxnInt();
  final Rxn<DateTime> selectedPurchaseDate = Rxn<DateTime>();
  final RxBool isSubmitting = false.obs;
  final Rxn<AssetModel> editingAsset = Rxn<AssetModel>();
  final RxBool showFieldErrors = false.obs;

  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxBool isEmployeesLoading = false.obs;

  static const int assetNameMax = 80;
  static const int assetTypeMax = 60;
  static const int assetValueMax = 15;

  bool get isEdit => editingAsset.value?.id != null;

  List<TextInputFormatter> get assetNameInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(assetNameMax),
      ];

  List<TextInputFormatter> get assetTypeInputFormatters =>
      <TextInputFormatter>[
        LengthLimitingTextInputFormatter(assetTypeMax),
      ];

  List<TextInputFormatter> get assetValueInputFormatters =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(assetValueMax),
      ];

  FormFieldValidator<String> get assetNameValidator => (String? value) {
        return FormValidations.validateCommonName(
          value ?? '',
          fieldName: "Asset Name",
          minLength: 3,
          maxLength: assetNameMax,
        );
      };

  FormFieldValidator<String> get assetTypeValidator => (String? value) {
        return FormValidations.validateRequiredMinMax(
          value ?? '',
          fieldName: "Asset Type",
          min: 2,
          max: assetTypeMax,
        );
      };

  FormFieldValidator<String> get assetValueValidator => (String? value) {
        return FormValidations.validateRequiredNumber(
          value ?? '',
          fieldName: "Value",
        );
      };

  @override
  void onInit() {
    super.onInit();
    fetchAssets();
    fetchEmployees();
  }

  Future<void> fetchAssets() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.getAllAssets,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : <dynamic>[]);
      assets.assignAll(
        items
            .where((e) => e is Map)
            .map((e) => AssetModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
      filtered.assignAll(assets);
    } else {
      assets.clear();
      filtered.clear();
      error.value = response.message;
    }

    isLoading.value = false;
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
          : (raw is Map && raw['data'] is List ? raw['data'] as List : <dynamic>[]);
      employees.assignAll(
        items
            .where((e) => e is Map)
            .map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } else {
      employees.clear();
    }

    isEmployeesLoading.value = false;
  }

  void filter(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(assets);
      return;
    }

    filtered.assignAll(
      assets.where((a) {
        return a.assetName.toLowerCase().contains(q) ||
            a.assetType.toLowerCase().contains(q) ||
            (a.assignedEmployeeName ?? '').toLowerCase().contains(q);
      }).toList(),
    );
  }

  void prepareForCreate() {
    resetForm();
    if (employees.isEmpty) {
      fetchEmployees();
    }
  }

  void openAddAssetForm(dynamic args) {
    showFieldErrors.value = false;
    if (args is AssetModel) {
      loadForEdit(args);
      return;
    }
    prepareForCreate();
  }

  Future<void> submitAssetFromForm() async {
    if (isSubmitting.value) return;
    showFieldErrors.value = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final bool formValid = formKey.currentState?.validate() ?? false;
    if (!formValid) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstError();
      return;
    }
    if (selectedEmployeeId.value == null || selectedPurchaseDate.value == null) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstError();
      return;
    }
    await submitAsset();
  }

  void loadForEdit(AssetModel asset) {
    editingAsset.value = asset;
    assetNameController.text = asset.assetName;
    assetTypeController.text = asset.assetType;
    valueController.text = asset.value.toString();
    purchaseDateController.text = asset.purchaseDate;
    selectedEmployeeId.value = asset.assignedTo;
    selectedPurchaseDate.value = DateTime.tryParse(asset.purchaseDate);
    if (employees.isEmpty) {
      fetchEmployees();
    }
  }

  Future<void> submitAsset() async {
    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final List<String> missing = <String>[];
    if (selectedEmployeeId.value == null) missing.add('Assigned To');
    if (selectedPurchaseDate.value == null) missing.add('Purchase Date');
    if (missing.isNotEmpty) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Required Fields",
        message: 'Please provide: ${missing.join(', ')}',
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    final num? parsedValue = num.tryParse(valueController.text.trim());
    if (parsedValue == null || parsedValue <= 0) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Invalid Value",
        message: "Asset value must be greater than 0.",
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    isSubmitting.value = true;

    final AssetModel request = AssetModel(
      assetName: assetNameController.text.trim(),
      assetType: assetTypeController.text.trim(),
      value: parsedValue,
      purchaseDate: DateFormats.yyyyMmDd(selectedPurchaseDate.value!),
      assignedTo: selectedEmployeeId.value,
    );

    final ApiResponse response = isEdit
        ? await ApiService().post(
            '${AppUrls.updateAsset}/${editingAsset.value!.id}',
            data: request.toJson(),
            isAuth: true,
          )
        : await ApiService().post(
            AppUrls.createAsset,
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
    final int? editedId = editingAsset.value?.id;

    AssetModel? createdFromResponse;
    if (response.data is Map) {
      createdFromResponse = AssetModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    final AssetModel created = AssetModel(
      id: createdFromResponse?.id ?? editingAsset.value?.id,
      userId: createdFromResponse?.userId ?? editingAsset.value?.userId,
      assignedTo: createdFromResponse?.assignedTo ?? request.assignedTo,
      assignedEmployeeName:
          createdFromResponse?.assignedEmployeeName ?? _employeeNameById(request.assignedTo),
      assignedEmployeeEmail:
          createdFromResponse?.assignedEmployeeEmail ?? editingAsset.value?.assignedEmployeeEmail,
      assetName:
          createdFromResponse?.assetName.isNotEmpty == true ? createdFromResponse!.assetName : request.assetName,
      assetType:
          createdFromResponse?.assetType.isNotEmpty == true ? createdFromResponse!.assetType : request.assetType,
      value: createdFromResponse?.value ?? request.value,
      purchaseDate: createdFromResponse?.purchaseDate.isNotEmpty == true
          ? createdFromResponse!.purchaseDate
          : request.purchaseDate,
      createdAt: createdFromResponse?.createdAt ?? editingAsset.value?.createdAt,
      updatedAt: createdFromResponse?.updatedAt ?? editingAsset.value?.updatedAt,
    );

    AssetModel? doneResult;
    await fetchAssets();
    if (isEdit) {
      final int? targetId = editedId ?? created.id;
      doneResult = targetId == null ? null : await _fetchAssetById(targetId);
    }

    isSubmitting.value = false;

    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogSuccess,
      title: isEdit ? "Asset Updated!" : "Asset Added!",
      message: isEdit
          ? "Asset has been updated successfully."
          : "Asset has been added successfully.",
      actions: isEdit
          ? [
              AppDialogAction(
                label: "Done",
                onPressed: () {
                  resetForm();
                  Get.back(result: doneResult ?? created);
                },
              ),
            ]
          : [
              AppDialogAction(
                label: "Add New Asset",
                onPressed: () {
                  fetchAssets();
                  resetForm();
                },
              ),
              AppDialogAction(
                label: "Done",
                onPressed: () {
                  resetForm();
                  Get.back(result: created);
                },
              ),
            ],
    );
  }

  Future<void> _scrollToFirstError() async {
    final List<GlobalKey<FormFieldState<String>>> textFieldKeys =
        <GlobalKey<FormFieldState<String>>>[
      assetNameFieldKey,
      assetTypeFieldKey,
      valueFieldKey,
    ];

    for (final GlobalKey<FormFieldState<String>> key in textFieldKeys) {
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

    if (selectedEmployeeId.value == null) {
      final BuildContext? context = assignedToFieldKey.currentContext;
      if (context != null) {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
        return;
      }
    }

    if (selectedPurchaseDate.value == null) {
      final BuildContext? context = purchaseDateFieldKey.currentContext;
      if (context != null) {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
      }
    }
  }

  Future<AssetModel?> _fetchAssetById(int id) async {
    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllAssets}/$id',
      isAuth: true,
    );
    if (!response.success || response.data is! Map) return null;
    final Map<String, dynamic> map =
        Map<String, dynamic>.from(response.data as Map);
    final Map<String, dynamic> payload =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
    return AssetModel.fromJson(payload);
  }

  Future<void> deleteAsset(AssetModel asset) async {
    if (asset.id == null || isDeleting.value) return;
    isDeleting.value = true;

    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.deleteAsset}/${asset.id}',
      isAuth: true,
    );
    AppDialogs.closeDialog();
    isDeleting.value = false;

    if (!response.success) {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
      return;
    }

    assets.removeWhere((a) => a.id == asset.id);
    filtered.removeWhere((a) => a.id == asset.id);
    AppUtils.showAppSnackbar(
      "Success",
      "Asset deleted successfully",
      snackPosition: SnackPosition.BOTTOM,
      type: AppSnackType.success,
    );
  }

  String? _employeeNameById(int? id) {
    if (id == null) return null;
    for (final EmployeeModel employee in employees) {
      if (employee.id == id || employee.userId == id) {
        return employee.fullName;
      }
    }
    return null;
  }

  void resetForm() {
    editingAsset.value = null;
    showFieldErrors.value = false;
    assetNameController.clear();
    assetTypeController.clear();
    valueController.clear();
    purchaseDateController.clear();
    selectedEmployeeId.value = null;
    selectedPurchaseDate.value = null;
  }

  @override
  void onClose() {
    searchController.dispose();
    assetNameController.dispose();
    assetTypeController.dispose();
    valueController.dispose();
    purchaseDateController.dispose();
    super.onClose();
  }
}
