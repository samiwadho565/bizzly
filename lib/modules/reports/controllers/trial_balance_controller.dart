import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/reports/models/trial_balance_model.dart';
import 'package:bizly/services/api_service.dart';

class TrialBalanceController extends GetxController {
  final Rxn<TrialBalanceModel> report = Rxn<TrialBalanceModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool showAllTransactions = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  Future<void> fetchReport() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';
    showAllTransactions.value = false;

    final ApiResponse response = await ApiService().get(
      AppUrls.trialBalance,
      isAuth: true,
    );

    if (response.success && response.data is Map) {
      report.value = TrialBalanceModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } else {
      report.value = null;
      error.value = response.message;
    }

    isLoading.value = false;
  }

  void toggleTransactionsVisibility() {
    showAllTransactions.value = !showAllTransactions.value;
  }
}
