import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/accounting_periods/models/accounting_period_model.dart';
import 'package:bizly/services/api_service.dart';

class AccountingPeriodController extends GetxController {
  final RxList<AccountingPeriodModel> periods = <AccountingPeriodModel>[].obs;
  final Rxn<AccountingPeriodModel> currentPeriod = Rxn<AccountingPeriodModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final results = await Future.wait([
      ApiService().get(AppUrls.accountingPeriods, isAuth: true),
      ApiService().get(AppUrls.accountingPeriodsCurrent, isAuth: true),
    ]);

    final ApiResponse listRes = results[0];
    final ApiResponse currentRes = results[1];

    if (listRes.success) {
      final List<dynamic> raw = listRes.data is List
          ? listRes.data as List
          : (listRes.data is Map && listRes.data['data'] is List
              ? listRes.data['data'] as List
              : []);
      periods.assignAll(
        raw.whereType<Map<String, dynamic>>().map(AccountingPeriodModel.fromJson).toList(),
      );
    } else {
      error.value = listRes.message;
    }

    if (currentRes.success && currentRes.data != null) {
      final dynamic raw = currentRes.data is Map
          ? currentRes.data
          : (currentRes.data is List && (currentRes.data as List).isNotEmpty
              ? (currentRes.data as List).first
              : null);
      if (raw is Map<String, dynamic>) {
        currentPeriod.value = AccountingPeriodModel.fromJson(raw);
      }
    }

    isLoading.value = false;
  }
}
