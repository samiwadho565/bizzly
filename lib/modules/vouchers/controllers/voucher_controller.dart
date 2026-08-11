import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';

class VoucherController extends GetxController {
  // ─── List ─────────────────────────────────────────────────────
  final RxList<VoucherModel> vouchers = <VoucherModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Filters
  final RxString filterType = 'all'.obs;
  final RxString filterStatus = 'all'.obs;
  final Rxn<DateTime> fromDate = Rxn<DateTime>();
  final Rxn<DateTime> toDate = Rxn<DateTime>();

  // ─── Detail ───────────────────────────────────────────────────
  final Rxn<VoucherModel> currentVoucher = Rxn<VoucherModel>();
  final RxBool isActionLoading = false.obs;

  // ─── Pending Approvals ────────────────────────────────────────
  final RxList<VoucherModel> pendingApprovals = <VoucherModel>[].obs;
  final RxBool isLoadingPending = false.obs;
  int get pendingCount => pendingApprovals.length;

  // ─── Create/Edit Form ─────────────────────────────────────────
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController narrationController = TextEditingController();
  final RxString selectedType = 'receipt'.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<DraftLine> lines = <DraftLine>[].obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<VoucherModel> editingVoucher = Rxn<VoucherModel>();
  final RxBool showLineErrors = false.obs;

  // CoA dropdown for account picker
  final RxList<CoaDropdownItem> coaDropdown = <CoaDropdownItem>[].obs;
  final RxBool isLoadingCoa = false.obs;

  // CRM dropdowns
  final RxList<CrmDropdownItem> businessList = <CrmDropdownItem>[].obs;
  final RxList<CrmDropdownItem> customerList = <CrmDropdownItem>[].obs;
  final RxList<CrmDropdownItem> vendorList = <CrmDropdownItem>[].obs;
  final RxBool isLoadingCrm = false.obs;

  // CRM selected values
  final Rxn<CrmDropdownItem> selectedBusiness = Rxn<CrmDropdownItem>();
  final Rxn<CrmDropdownItem> selectedCustomer = Rxn<CrmDropdownItem>();
  final Rxn<CrmDropdownItem> selectedVendor = Rxn<CrmDropdownItem>();

  // True while CoA + CRM data is being fetched for the form
  bool get isLoadingInitial => isLoadingCoa.value || isLoadingCrm.value;

  bool get isEdit => editingVoucher.value != null;

  static const List<String> voucherTypes = [
    'receipt', 'payment', 'journal', 'contra', 'adjustment'
  ];

  static const List<String> statuses = [
    'all', 'draft', 'submitted', 'posted', 'rejected'
  ];

  // ─── Computed ─────────────────────────────────────────────────
  // Type filter is client-side; status/date filters are server-side.
  List<VoucherModel> get filteredVouchers {
    if (filterType.value == 'all') return vouchers;
    return vouchers.where((v) => v.voucherType == filterType.value).toList();
  }

  bool get hasActiveTypeFilter => filterType.value != 'all';

  bool get hasActiveServerFilters =>
      filterStatus.value != 'all' ||
      fromDate.value != null ||
      toDate.value != null;

  bool get hasActiveFilters => hasActiveTypeFilter || hasActiveServerFilters;

  double get totalDebit => lines.fold(0, (s, l) => s + (l.isDebit ? l.parsedAmount : 0));
  double get totalCredit => lines.fold(0, (s, l) => s + (!l.isDebit ? l.parsedAmount : 0));
  bool get isBalanced => totalDebit == totalCredit && totalDebit > 0;

  // ─── Lifecycle ────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchVouchers();
    fetchPendingApprovals();
  }

  // ─── Filters ──────────────────────────────────────────────────
  // Type chip — client-side only, no API call
  void applyType(String type) {
    filterType.value = type;
  }

  // Client-side only clear — no API call
  void clearTypeFilter() {
    filterType.value = 'all';
  }

  // Bottom sheet filters — hit API
  void applyStatus(String status) {
    filterStatus.value = status;
    fetchVouchers();
  }

  void applyDateRange(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;
    fetchVouchers();
  }

  // Clear server filters + reset type chip + API call
  void clearServerFilters() {
    filterType.value = 'all';
    filterStatus.value = 'all';
    fromDate.value = null;
    toDate.value = null;
    fetchVouchers();
  }

  // ─── Fetch ────────────────────────────────────────────────────
  Future<void> fetchVouchers() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    // Build query string
    final StringBuffer query = StringBuffer('?');
    if (filterType.value != 'all') query.write('voucher_type=${filterType.value}&');
    if (filterStatus.value != 'all') query.write('status=${filterStatus.value}&');
    if (fromDate.value != null) query.write('from_date=${DateFormat('yyyy-MM-dd').format(fromDate.value!)}&');
    if (toDate.value != null) query.write('to_date=${DateFormat('yyyy-MM-dd').format(toDate.value!)}&');

    final String url = '${AppUrls.vouchers}${query.toString() == '?' ? '' : query.toString()}';

    final ApiResponse res = await ApiService().get(
      url,
      isAuth: true,
    );

    if (res.success) {
      final List<dynamic> raw = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['data'] is List ? res.data['data'] as List : []);
      vouchers.assignAll(
        raw.whereType<Map>()
            .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } else {
      error.value = res.message;
    }

    isLoading.value = false;
  }

  Future<void> fetchPendingApprovals() async {
    if (isLoadingPending.value) return;
    isLoadingPending.value = true;

    final ApiResponse res = await ApiService().get(
      AppUrls.vouchersPendingApprovals,
      isAuth: true,
    );

    if (res.success) {
      final List<dynamic> raw = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['data'] is List ? res.data['data'] as List : []);
      pendingApprovals.assignAll(
        raw.whereType<Map>()
            .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    isLoadingPending.value = false;
  }

  Future<void> fetchCoaDropdown() async {
    if (isLoadingCoa.value || coaDropdown.isNotEmpty) return;
    isLoadingCoa.value = true;

    final ApiResponse res = await ApiService().get(
      AppUrls.chartOfAccountsDropdown,
      isAuth: true,
    );

    if (res.success) {
      final List<dynamic> raw = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['data'] is List ? res.data['data'] as List : []);
      coaDropdown.assignAll(
        raw.whereType<Map>()
            .map((e) => CoaDropdownItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    isLoadingCoa.value = false;
  }

  Future<void> fetchCrmDropdowns() async {
    if (isLoadingCrm.value) return;
    // Only fetch if lists are empty
    if (businessList.isNotEmpty && customerList.isNotEmpty && vendorList.isNotEmpty) return;
    isLoadingCrm.value = true;

    final List<Future<ApiResponse>> futures = [
      ApiService().get(AppUrls.getAllBusinesses, isAuth: true),
      ApiService().get(AppUrls.createCustomer, isAuth: true),
      ApiService().get(AppUrls.createVendor, isAuth: true),
    ];

    final List<ApiResponse> results = await Future.wait(futures);

    List<CrmDropdownItem> _parse(ApiResponse res, String nameKey) {
      if (!res.success) return [];
      final List<dynamic> raw = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['data'] is List ? res.data['data'] as List : []);
      return raw.whereType<Map>().map((e) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(e);
        return CrmDropdownItem(
          id: m['id'] is int ? m['id'] : int.tryParse(m['id'].toString()) ?? 0,
          name: m[nameKey]?.toString() ?? '',
        );
      }).toList();
    }

    if (businessList.isEmpty) businessList.assignAll(_parse(results[0], 'business_name'));
    if (customerList.isEmpty) customerList.assignAll(_parse(results[1], 'customer_name'));
    if (vendorList.isEmpty) vendorList.assignAll(_parse(results[2], 'vendor_name'));

    isLoadingCrm.value = false;
  }

  // ─── Form helpers ─────────────────────────────────────────────
  void prepareCreate() {
    editingVoucher.value = null;
    narrationController.clear();
    selectedType.value = 'receipt';
    selectedDate.value = DateTime.now();
    selectedBusiness.value = null;
    selectedCustomer.value = null;
    selectedVendor.value = null;
    showLineErrors.value = false;
    lines.assignAll([DraftLine(lineType: 'debit'), DraftLine(lineType: 'credit')]);
    Future.wait([fetchCoaDropdown(), fetchCrmDropdowns()]);
  }

  void prepareEdit(VoucherModel v) {
    editingVoucher.value = v;
    narrationController.text = v.narration;
    selectedType.value = v.voucherType;
    selectedDate.value = v.voucherDate;
    // Pre-select CRM values from voucher
    selectedBusiness.value = v.business != null
        ? CrmDropdownItem(id: v.business!.id, name: v.business!.businessName)
        : null;
    selectedCustomer.value = v.customer != null
        ? CrmDropdownItem(id: v.customer!.id, name: v.customer!.customerName)
        : null;
    selectedVendor.value = v.vendor != null
        ? CrmDropdownItem(id: v.vendor!.id, name: v.vendor!.vendorName)
        : null;
    lines.assignAll(v.lines.map((l) => DraftLine(
          accountId: l.chartOfAccountId,
          accountCode: l.account?.accountCode,
          accountName: l.account?.accountName,
          lineType: l.lineType,
          amount: l.amount.toStringAsFixed(0),
        )));
    Future.wait([fetchCoaDropdown(), fetchCrmDropdowns()]);
  }

  // ─── Voucher type change ──────────────────────────────────────
  // Clears all account selections when type changes (accounts differ per type)
  void changeVoucherType(String type) {
    selectedType.value = type;
    lines.assignAll(lines.map((l) => DraftLine(lineType: l.lineType)).toList());
  }

  /// Returns CoA items filtered by voucher type + line side (debit/credit).
  ///
  /// Rules (per screenshot spec):
  ///   receipt  debit  → code starts with A  (Assets)
  ///   receipt  credit → code starts with G  (Revenue)
  ///   payment  debit  → code starts with E  (Expenses)
  ///   payment  credit → code starts with A  (Assets)
  ///   journal  debit  → normal_balance = debit
  ///   journal  credit → normal_balance = credit
  ///   contra   both   → code starts with A10 (Current Assets)
  ///   adjust   debit  → normal_balance = debit
  ///   adjust   credit → normal_balance = credit
  List<CoaDropdownItem> filteredCoaFor(String voucherType, String lineType) {
    final bool isDebit = lineType == 'debit';
    return coaDropdown.where((item) {
      // Only Level 3 accounts allowed for journal entries
      if (item.level != 3) return false;

      final String code = item.accountCode.toUpperCase();
      switch (voucherType) {
        case 'receipt':
          return isDebit ? code.startsWith('A') : code.startsWith('G');
        case 'payment':
          return isDebit ? code.startsWith('E') : code.startsWith('A');
        case 'journal':
        case 'adjustment':
          return isDebit
              ? item.normalBalance == 'debit'
              : item.normalBalance == 'credit';
        case 'contra':
          return code.startsWith('A10');
        default:
          return true;
      }
    }).toList();
  }

  void addLine() {
    lines.add(DraftLine(lineType: 'debit'));
  }

  void removeLine(int index) {
    if (lines.length > 2) lines.removeAt(index);
  }

  void updateLine(int index, DraftLine updated) {
    lines[index] = updated;
    lines.refresh();
  }

  // ─── Submit form ──────────────────────────────────────────────
  // [onScrollToError] called by screen to scroll to first invalid field
  Future<void> submitForm({VoidCallback? onScrollToError}) async {
    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    // Show inline errors on lines
    showLineErrors.value = true;

    final bool formValid = formKey.currentState?.validate() ?? false;
    final bool linesValid = lines.every((l) => l.isValid);
    final bool balanced = isBalanced;

    if (!formValid || !linesValid || !balanced) {
      onScrollToError?.call();
      return;
    }

    isSubmitting.value = true;

    final Map<String, dynamic> payload = {
      'voucher_type': selectedType.value,
      'voucher_date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
      'narration': narrationController.text.trim(),
      'lines': lines.map((l) => {
            'chart_of_account_id': l.accountId,
            'line_type': l.lineType,
            'amount': l.parsedAmount,
          }).toList(),
      if (selectedBusiness.value != null) 'business_id': selectedBusiness.value!.id.toString(),
      if (selectedCustomer.value != null) 'customer_id': selectedCustomer.value!.id.toString(),
      if (selectedVendor.value != null) 'vendor_id': selectedVendor.value!.id.toString(),
    };

    final ApiResponse res = isEdit
        ? await ApiService().post(
            '${AppUrls.vouchers}/${editingVoucher.value!.id}',
            data: payload,
            isAuth: true,
          )
        : await ApiService().post(AppUrls.vouchers, data: payload, isAuth: true);

    isSubmitting.value = false;

    if (res.success) {
      fetchVouchers();
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: isEdit ? 'Voucher Updated!' : 'Voucher Created!',
        actions: [
          if (!isEdit)
            AppDialogAction(
              label: 'New Voucher',
              onPressed: () {
                prepareCreate();
              },
            ),
          AppDialogAction(
            label: 'Done',
            onPressed: () => Get.back(result: true),
          ),
        ],
      );
    } else {
      AppUtils.showAppSnackbar('Error', res.message,
          type: AppSnackType.error, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Actions ──────────────────────────────────────────────────
  Future<void> submitVoucher(VoucherModel v) async {
    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogWarning,
      title: 'Send for Approval?',
      message: '"${v.voucherNumber}" will be sent to the approver for review.',
      actions: [
        AppDialogAction(
          label: 'Cancel',
          onPressed: null,
        ),
        AppDialogAction(
          label: 'Send',
          onPressed: () async {
            isActionLoading.value = true;
            final ApiResponse res = await ApiService().post(
              '${AppUrls.vouchers}/${v.id}/submit',
              data: {},
              isAuth: true,
            );
            isActionLoading.value = false;
            if (res.success) {
              _refreshAndPop(v.id);
              AppUtils.showAppSnackbar(
                  'Submitted', 'Voucher submitted for approval',
                  type: AppSnackType.success,
                  snackPosition: SnackPosition.BOTTOM);
            } else {
              AppUtils.showAppSnackbar('Error', res.message,
                  type: AppSnackType.error,
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
        ),
      ],
    );
  }

  Future<void> approveVoucher(VoucherModel v) async {
    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogSuccess,
      title: 'Approve Voucher?',
      message: '"${v.voucherNumber}" will be approved and posted.',
      actions: [
        AppDialogAction(
          label: 'Cancel',
          onPressed: null,
        ),
        AppDialogAction(
          label: 'Approve',
          onPressed: () async {
            isActionLoading.value = true;
            final ApiResponse res = await ApiService().post(
              '${AppUrls.vouchers}/${v.id}/approve',
              data: {'comments': 'Approved'},
              isAuth: true,
            );
            isActionLoading.value = false;
            if (res.success) {
              _refreshAndPop(v.id);
              AppUtils.showAppSnackbar(
                  'Approved', 'Voucher approved and posted',
                  type: AppSnackType.success,
                  snackPosition: SnackPosition.BOTTOM);
            } else {
              AppUtils.showAppSnackbar('Error', res.message,
                  type: AppSnackType.error,
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
        ),
      ],
    );
  }

  Future<void> rejectVoucher(VoucherModel v) async {
    AppDialogs.showRejectDialog(
      iconPath: AppImages.dialogTrash,
      title: 'Reject Voucher?',
      message: 'Please provide a reason for rejecting "${v.voucherNumber}".',
      hintText: 'Enter rejection reason...',
      rejectText: 'Reject',
      onReject: (reason) async {
        isActionLoading.value = true;
        final ApiResponse res = await ApiService().post(
          '${AppUrls.vouchers}/${v.id}/reject',
          data: {'rejection_reason': reason},
          isAuth: true,
        );
        isActionLoading.value = false;
        if (res.success) {
          _refreshAndPop(v.id);
          AppUtils.showAppSnackbar('Rejected', 'Voucher rejected',
              type: AppSnackType.error, snackPosition: SnackPosition.BOTTOM);
        } else {
          AppUtils.showAppSnackbar('Error', res.message,
              type: AppSnackType.error, snackPosition: SnackPosition.BOTTOM);
        }
      },
    );
  }

  Future<void> deleteVoucher(VoucherModel v) async {
    AppDialogs.showDeleteDialog(
      title: 'Delete Voucher?',
      message: '"${v.voucherNumber}" will be permanently removed. This action cannot be undone.',
      onDelete: () async {
        isActionLoading.value = true;
        final ApiResponse res = await ApiService().delete(
          '${AppUrls.vouchers}/${v.id}',
          isAuth: true,
        );
        isActionLoading.value = false;
        if (res.success) {
          vouchers.removeWhere((e) => e.id == v.id);
          Get.back();
          AppUtils.showAppSnackbar('Deleted', 'Voucher deleted',
              type: AppSnackType.success, snackPosition: SnackPosition.BOTTOM);
        } else {
          AppUtils.showAppSnackbar('Error', res.message,
              type: AppSnackType.error, snackPosition: SnackPosition.BOTTOM);
        }
      },
    );
  }

  void _refreshAndPop(int voucherId) {
    fetchVouchers();
    fetchPendingApprovals();
    if (currentVoucher.value?.id == voucherId) {
      currentVoucher.value = null;
    }
    Get.back();
  }

  @override
  void onClose() {
    narrationController.dispose();
    super.onClose();
  }
}

// ── CRM dropdown item ─────────────────────────────────────────────
class CrmDropdownItem {
  final int id;
  final String name;
  CrmDropdownItem({required this.id, required this.name});
}
