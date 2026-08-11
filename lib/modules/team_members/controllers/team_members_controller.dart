import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/modules/team_members/models/team_member_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/form_validations.dart';

class TeamMembersController extends GetxController {
  // ── List state ─────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;
  final RxList<TeamMemberModel> members = <TeamMemberModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // ── Business picker ────────────────────────────────────
  final Rxn<BusinessModel> selectedBusiness = Rxn<BusinessModel>();
  final RxString businessError = ''.obs;
  final GlobalKey businessFieldKey = GlobalKey();

  List<BusinessModel> get businesses =>
      Get.isRegistered<HomeScreenController>()
          ? Get.find<HomeScreenController>().businesses
          : <BusinessModel>[];

  // ── Form ───────────────────────────────────────────────
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxString accountingRole = 'accountant'.obs;
  final RxBool createEmployeeRecord = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<TeamMemberModel> editingMember = Rxn<TeamMemberModel>();

  final GlobalKey<FormFieldState<String>> nameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> emailFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> phoneFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  bool get isEdit => editingMember.value?.id != null;

  List<TeamMemberModel> get filteredMembers {
    final String q = query.value.toLowerCase().trim();
    if (q.isEmpty) return members;
    return members.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          m.phone.toLowerCase().contains(q) ||
          m.accountingRole.toLowerCase().contains(q);
    }).toList();
  }

  // ── Input formatters ───────────────────────────────────
  List<TextInputFormatter> get nameFormatters => <TextInputFormatter>[
        LengthLimitingTextInputFormatter(60),
      ];

  List<TextInputFormatter> get emailFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        LengthLimitingTextInputFormatter(80),
      ];

  List<TextInputFormatter> get phoneFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]')),
        LengthLimitingTextInputFormatter(15),
      ];

  List<TextInputFormatter> get passwordFormatters => <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        LengthLimitingTextInputFormatter(64),
      ];

  // ── Validators ─────────────────────────────────────────
  FormFieldValidator<String> get nameValidator => (v) =>
      FormValidations.validateCommonName(v ?? '', fieldName: 'Name', minLength: 2, maxLength: 60);

  FormFieldValidator<String> get emailValidator => (v) =>
      FormValidations.validateCommonEmail(v ?? '', required: true, maxLength: 80);

  FormFieldValidator<String> get phoneValidator => (v) =>
      FormValidations.validateCommonPhoneNumber(v ?? '',
          fieldName: 'Phone', required: true, minDigits: 10, maxDigits: 15);

  FormFieldValidator<String>? get passwordValidator => isEdit
      ? null
      : (v) => FormValidations.validateRequiredMinMax(v ?? '',
          fieldName: 'Password', min: 6, max: 64);

  // ── Lifecycle ──────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  // ── Fetch ──────────────────────────────────────────────
  Future<void> fetchMembers() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse res = await ApiService().get(
      AppUrls.teamMembers,
      isAuth: true,
    );

    if (res.success) {
      final dynamic raw = res.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      members.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => TeamMemberModel.fromJson(e))
            .toList(),
      );
    } else {
      members.clear();
      error.value = res.message;
    }

    isLoading.value = false;
  }

  // ── Prepare form ───────────────────────────────────────
  void prepareCreate() {
    editingMember.value = null;
    _resetForm();
    if (businesses.length == 1) selectedBusiness.value = businesses.first;
  }

  void prepareEdit(TeamMemberModel member) {
    editingMember.value = member;
    nameController.text = member.name;
    emailController.text = member.email;
    phoneController.text = member.phone;
    passwordController.clear();
    accountingRole.value = member.accountingRole;
    createEmployeeRecord.value = false;
    businessError.value = '';
    // Try to match business
    if (member.businessId != null) {
      for (final BusinessModel b in businesses) {
        if (b.id == member.businessId) {
          selectedBusiness.value = b;
          break;
        }
      }
    } else if (businesses.length == 1) {
      selectedBusiness.value = businesses.first;
    }
  }

  void _resetForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    accountingRole.value = 'accountant';
    createEmployeeRecord.value = false;
    businessError.value = '';
    // Keep selectedBusiness
  }

  // ── Submit ─────────────────────────────────────────────
  Future<void> submitAndClose() async {
    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate business
    if (selectedBusiness.value == null && !isEdit) {
      businessError.value = 'Business is required';
    } else {
      businessError.value = '';
    }

    final bool valid = formKey.currentState?.validate() ?? false;
    if (businessError.value.isNotEmpty || !valid) {
      if (businessError.value.isNotEmpty) {
        final BuildContext? ctx = businessFieldKey.currentContext;
        if (ctx != null) {
          await Scrollable.ensureVisible(ctx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.15);
        }
      }
      return;
    }

    isSubmitting.value = true;
    final bool wasEdit = isEdit;

    final ApiResponse res;

    if (wasEdit) {
      // Update: only status can be changed via API
      final TeamMemberModel updated = TeamMemberModel(
        id: editingMember.value!.id,
        userId: editingMember.value!.userId,
        name: editingMember.value!.name,
        email: editingMember.value!.email,
        phone: editingMember.value!.phone,
        accountingRole: accountingRole.value,
        status: editingMember.value!.status, // kept same; status toggled via detail
        businessId: editingMember.value!.businessId,
      );
      res = await ApiService().post(
        '${AppUrls.teamMembers}/${editingMember.value!.id}',
        data: <String, dynamic>{'accounting_role': accountingRole.value},
        isAuth: true,
      );
    } else {
      final TeamMemberModel newMember = TeamMemberModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        accountingRole: accountingRole.value,
        status: 'active',
        businessId: selectedBusiness.value?.id,
      );
      res = await ApiService().post(
        AppUrls.teamMembers,
        data: newMember.toCreateJson(
          password: passwordController.text.trim(),
          createEmployeeRecord: createEmployeeRecord.value,
        ),
        isAuth: true,
      );
    }

    isSubmitting.value = false;

    if (!res.success) {
      AppUtils.showAppSnackbar(
        'Error',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.error,
        backgroundColor: Colors.red.shade100,
        textColor: Colors.black,
      );
      return;
    }

    TeamMemberModel? saved;
    if (res.data is Map) {
      saved = TeamMemberModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    }

    await fetchMembers();

    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogSuccess,
      title: wasEdit ? 'Member Updated!' : 'Member Added!',
      message: wasEdit
          ? 'Team member updated successfully.'
          : 'Team member added successfully.',
      actions: <AppDialogAction>[
        if (!wasEdit)
          AppDialogAction(
            label: 'Add Another',
            onPressed: () {
              _resetForm();
              formKey.currentState?.reset();
            },
          ),
        AppDialogAction(
          label: 'Done',
          onPressed: () => Get.back(result: saved),
        ),
      ],
    );
  }

  // ── Toggle status ──────────────────────────────────────
  Future<void> toggleStatus(TeamMemberModel member) async {
    final String newStatus =
        member.status.toLowerCase() == 'active' ? 'inactive' : 'active';

    AppDialogs.showLoading(message: 'Updating...');
    final ApiResponse res = await ApiService().post(
      '${AppUrls.teamMembers}/${member.id}',
      data: <String, dynamic>{'status': newStatus},
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (res.success) {
      await fetchMembers();
    } else {
      AppUtils.showAppSnackbar(
        'Error',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.error,
        backgroundColor: Colors.red.shade100,
        textColor: Colors.black,
      );
    }
  }

  // ── Delete ─────────────────────────────────────────────
  Future<void> deleteMember(TeamMemberModel member) async {
    if (member.id == null) return;
    AppDialogs.showLoading(message: 'Deleting...');
    final ApiResponse res = await ApiService().delete(
      '${AppUrls.teamMembers}/${member.id}',
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (res.success) {
      members.removeWhere((m) => m.id == member.id);
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: 'Error!',
        message: res.message,
        actions: <AppDialogAction>[AppDialogAction(label: 'Ok')],
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
