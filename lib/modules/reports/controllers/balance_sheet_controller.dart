import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/reports/models/balance_sheet_model.dart';
import 'package:bizly/services/api_service.dart';

class BalanceSheetController extends GetxController {
  final Rxn<BalanceSheetModel> report = Rxn<BalanceSheetModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  Future<void> fetchReport() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.balanceSheet,
      isAuth: true,
    );

    if (response.success && response.data is Map) {
      report.value = BalanceSheetModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } else {
      report.value = null;
      error.value = response.message;
    }

    isLoading.value = false;
  }
}
