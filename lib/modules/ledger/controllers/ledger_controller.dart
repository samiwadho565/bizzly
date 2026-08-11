import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/modules/ledger/models/ledger_model.dart';
import 'package:bizly/services/api_service.dart';

class LedgerController extends GetxController {
  // GET /api/ledger — full list
  final RxList<LedgerEntry> entries = <LedgerEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // GET /api/ledger/{id} — single entry
  final Rxn<LedgerEntry> selectedEntry = Rxn<LedgerEntry>();
  final RxBool isEntryLoading = false.obs;
  final RxString entryError = ''.obs;

  // GET /api/ledger/account/{id} — account-specific ledger
  final Rxn<AccountLedger> accountLedger = Rxn<AccountLedger>();
  final RxBool isAccountLoading = false.obs;

  // Chart of Accounts dropdown — used to pick which account's ledger to view
  // (GET /api/dropdowns/chart-of-accounts)
  final RxList<CoaDropdownItem> coaDropdown = <CoaDropdownItem>[].obs;
  final RxBool isLoadingCoa = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEntries();
    fetchCoaDropdown();
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
          : (res.data is Map && res.data['data'] is List
              ? res.data['data'] as List
              : []);
      coaDropdown.assignAll(
        raw
            .whereType<Map>()
            .map((e) => CoaDropdownItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    isLoadingCoa.value = false;
  }

  Future<void> fetchEntries() async {
    isLoading.value = true;
    error.value = '';
    final ApiResponse res = await ApiService().get(
      AppUrls.ledger,
      isAuth: true,
    );
    isLoading.value = false;
    if (res.success) {
      final List<dynamic> raw = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['data'] is List
              ? res.data['data'] as List
              : []);
      entries.assignAll(
        raw
            .whereType<Map>()
            .map((e) => LedgerEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } else {
      error.value = res.message;
    }
  }

  Future<void> fetchEntryDetail(int entryId) async {
    isEntryLoading.value = true;
    entryError.value = '';
    selectedEntry.value = null;

    final ApiResponse res = await ApiService().get(
      '${AppUrls.ledger}/$entryId',
      isAuth: true,
    );
    isEntryLoading.value = false;

    if (res.success && res.data is Map) {
      final Map<String, dynamic> raw = Map<String, dynamic>.from(res.data as Map);
      final Map<String, dynamic> data =
          raw['data'] is Map ? Map<String, dynamic>.from(raw['data'] as Map) : raw;
      selectedEntry.value = LedgerEntry.fromJson(data);
    } else {
      entryError.value = res.message;
    }
  }

  Future<void> fetchAccountLedger(int accountId) async {
    isAccountLoading.value = true;
    accountLedger.value = null;
    final ApiResponse res = await ApiService().get(
      '${AppUrls.ledger}/account/$accountId',
      isAuth: true,
    );
    isAccountLoading.value = false;
    if (res.success && res.data is Map) {
      accountLedger.value = AccountLedger.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    }
  }
}
