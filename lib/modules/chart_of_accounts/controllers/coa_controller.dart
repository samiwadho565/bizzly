import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';

class CoaController extends GetxController {
  // ─── List State ───────────────────────────────────────────────
  final RxList<CoaModel> allAccounts = <CoaModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedNature = 'all'.obs; // all|asset|liability|equity|income|expense

  // Which L2 sections are expanded (by account id)
  final RxSet<int> expandedL2 = <int>{}.obs;

  // ─── Create/Edit Form ─────────────────────────────────────────
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final RxBool isSubmitting = false.obs;
  final Rxn<CoaModel> editingAccount = Rxn<CoaModel>();
  final Rxn<CoaModel> selectedParent = Rxn<CoaModel>(); // L2 parent

  // L2 accounts for parent picker (fetched once)
  final RxList<CoaModel> l2Accounts = <CoaModel>[].obs;
  final RxBool isLoadingL2 = false.obs;

  // Parent picker error
  final RxString parentError = ''.obs;

  bool get isEdit => editingAccount.value?.id != null;

  static const int nameMax = 80;

  // ─── Lifecycle ────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  // ─── Computed: grouped + filtered ─────────────────────────────
  /// Returns L1 accounts with nested L2>L3 already embedded,
  /// filtered by [selectedNature] and [searchQuery].
  List<CoaModel> get filteredL1 {
    final String nature = selectedNature.value;
    final String q = searchQuery.value.toLowerCase().trim();

    return allAccounts.where((l1) {
      if (nature != 'all' && l1.nature.toLowerCase() != nature) return false;
      if (q.isEmpty) return true;
      return _l1MatchesQuery(l1, q);
    }).toList();
  }

  bool _l1MatchesQuery(CoaModel l1, String q) {
    if (l1.accountName.toLowerCase().contains(q)) return true;
    if (l1.accountCode.toLowerCase().contains(q)) return true;
    for (final CoaModel l2 in l1.children) {
      if (l2.accountName.toLowerCase().contains(q)) return true;
      if (l2.accountCode.toLowerCase().contains(q)) return true;
      for (final CoaModel l3 in l2.children) {
        if (l3.accountName.toLowerCase().contains(q)) return true;
        if (l3.accountCode.toLowerCase().contains(q)) return true;
      }
    }
    return false;
  }

  // ─── Fetch ────────────────────────────────────────────────────
  Future<void> fetchAccounts() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.chartOfAccounts,
      isAuth: true,
    );

    if (response.success) {
      final List<dynamic> raw = response.data is List
          ? response.data as List
          : (response.data is Map && response.data['data'] is List
              ? response.data['data'] as List
              : []);

      final List<CoaModel> flat = raw
          .whereType<Map<String, dynamic>>()
          .map(CoaModel.fromJson)
          .toList();

      allAccounts.assignAll(_buildTree(flat));
    } else {
      error.value = response.message;
    }

    isLoading.value = false;
  }

  /// Converts flat list from API into L1 → L2 → L3 tree.
  Map<int, List<CoaModel>> _byParent = {};

  List<CoaModel> _buildTree(List<CoaModel> flat) {
    _byParent = {};
    for (final CoaModel item in flat) {
      final int key = item.parentId ?? 0;
      _byParent.putIfAbsent(key, () => []).add(item);
    }
    final List<CoaModel> roots = _byParent[0] ?? [];
    return roots.map(_attachChildren).toList();
  }

  CoaModel _attachChildren(CoaModel node) {
    final List<CoaModel> kids =
        (_byParent[node.id] ?? []).map(_attachChildren).toList();
    return node.withChildren(kids);
  }

  Future<void> fetchL2Accounts() async {
    if (isLoadingL2.value || l2Accounts.isNotEmpty) return;
    isLoadingL2.value = true;

    final ApiResponse response = await ApiService().get(
      AppUrls.chartOfAccounts,
      queryParameters: {'level': '2'},
      isAuth: true,
    );

    if (response.success) {
      final List<dynamic> raw = response.data is List
          ? response.data as List
          : (response.data is Map && response.data['data'] is List
              ? response.data['data'] as List
              : []);
      l2Accounts.assignAll(
        raw.whereType<Map<String, dynamic>>().map(CoaModel.fromJson).toList(),
      );
    }

    isLoadingL2.value = false;
  }

  // ─── Toggle L2 expand ─────────────────────────────────────────
  void toggleL2(int id) {
    if (expandedL2.contains(id)) {
      expandedL2.remove(id);
    } else {
      expandedL2.add(id);
    }
  }

  // ─── Create / Update ──────────────────────────────────────────
  Future<void> submitForm() async {
    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate parent selection (required for create)
    if (!isEdit && selectedParent.value == null) {
      parentError.value = 'Parent account is required';
    } else {
      parentError.value = '';
    }

    final bool valid = formKey.currentState?.validate() ?? false;
    if (parentError.value.isNotEmpty || !valid) return;

    isSubmitting.value = true;

    final Map<String, dynamic> payload = {
      'account_name': nameController.text.trim(),
      if (!isEdit && selectedParent.value != null)
        'parent_id': selectedParent.value!.id.toString(),
      if (isEdit) 'is_active': editingAccount.value!.isActive,
    };

    final ApiResponse response = isEdit
        ? await ApiService().post(
            '${AppUrls.chartOfAccounts}/${editingAccount.value!.id}',
            data: payload,
            isAuth: true,
          )
        : await ApiService().post(
            AppUrls.chartOfAccounts,
            data: payload,
            isAuth: true,
          );

    isSubmitting.value = false;

    if (response.success) {
      final bool editing = isEdit;
      if (!editing) _clearForm();
      fetchAccounts(); // background mein, await nahi

      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: editing ? 'Account Updated!' : 'Account Created!',
        message: editing
            ? 'Account updated successfully.'
            : 'Account created successfully.',
        actions: [
          if (!editing)
            AppDialogAction(
              label: 'Add Another',
              onPressed: prepareCreate,
            ),
          AppDialogAction(
            label: 'Done',
            onPressed: () => Get.back(result: true),
          ),
        ],
      );
    } else {
      AppUtils.showAppSnackbar(
        'Error',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.error,
      );
    }
  }

  // ─── Form helpers ─────────────────────────────────────────────
  void _clearForm() {
    nameController.clear();
    selectedParent.value = null;
    parentError.value = '';
    editingAccount.value = null;
  }

  void prepareCreate() {
    _clearForm();
    fetchL2Accounts();
  }

  // ─── Current Detail Account (reactive, for detail screen) ────────
  final Rxn<CoaModel> currentDetailAccount = Rxn<CoaModel>();

  /// Immediately patches isActive in the tree without waiting for fetchAccounts()
  void _patchActiveStatus(int id, bool active) {
    allAccounts.assignAll(
      allAccounts.map((l1) => _patchInTree(l1, id, active)).toList(),
    );
    // Also update detail screen's reactive account
    if (currentDetailAccount.value?.id == id) {
      currentDetailAccount.value = currentDetailAccount.value!.copyWith(isActive: active);
    }
  }

  CoaModel _patchInTree(CoaModel node, int targetId, bool active) {
    if (node.id == targetId) return node.copyWith(isActive: active);
    return node.copyWith(
      children: node.children.map((c) => _patchInTree(c, targetId, active)).toList(),
    );
  }

  // ─── Toggle Active ─────────────────────────────────────────────
  final RxBool isTogglingActive = false.obs;

  Future<void> toggleActive(CoaModel account) async {
    final bool activate = !account.isActive;

    AppDialogs.showActionDialog(
      iconPath: activate ? AppImages.dialogSuccess : AppImages.dialogWarning,
      title: activate ? 'Activate Account?' : 'Deactivate Account?',
      message: activate
          ? '"${account.accountName}" will be activated and available for transactions.'
          : '"${account.accountName}" will be deactivated and hidden from transactions.',
      actions: [
        AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: activate ? 'Activate' : 'Deactivate',
          textColor: activate ? AppColors.primary : const Color(0xFFFB8C00),
          onPressed: () async {
            isTogglingActive.value = true;

            final ApiResponse response = await ApiService().post(
              '${AppUrls.chartOfAccounts}/${account.id}',
              data: {'is_active': activate},
              isAuth: true,
            );

            isTogglingActive.value = false;

            if (response.success) {
              _patchActiveStatus(account.id, activate);
              fetchAccounts();
              AppUtils.showAppSnackbar(
                activate ? 'Activated' : 'Deactivated',
                '"${account.accountName}" has been ${activate ? 'activated' : 'deactivated'}.',
                type: AppSnackType.success,
                snackPosition: SnackPosition.BOTTOM,
              );
              Get.back();
            } else {
              AppUtils.showAppSnackbar(
                'Error',
                response.message,
                type: AppSnackType.error,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      ],
    );
  }

  void prepareEdit(CoaModel account) {
    editingAccount.value = account;
    nameController.text = account.accountName;
    selectedParent.value = null;
    parentError.value = '';
  }

  String? nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Account name is required';
    if (value.trim().length < 3) return 'Minimum 3 characters';
    if (value.trim().length > nameMax) return 'Maximum $nameMax characters';
    return null;
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
