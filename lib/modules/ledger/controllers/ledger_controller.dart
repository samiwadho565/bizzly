import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/ledger/models/ledger_model.dart';
import 'package:bizly/services/api_service.dart';

class LedgerController extends GetxController {
  final RxList<LedgerEntry> entries = <LedgerEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // For account-specific ledger
  final Rxn<AccountLedger> accountLedger = Rxn<AccountLedger>();
  final RxBool isAccountLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEntries();
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
