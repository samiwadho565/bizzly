import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/reports/models/balance_sheet_model.dart';
import 'package:bizly/services/api_service.dart';

class BalanceSheetController extends GetxController {
  final Rxn<BalanceSheetModel> report = Rxn<BalanceSheetModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // ── Date Filter (single as_of_date) ──────────────────────────
  final RxString selectedPreset = 'today'.obs;
  late Rx<DateTime> asOfDate;

  @override
  void onInit() {
    super.onInit();
    asOfDate = DateTime.now().obs;
    fetchReport();
  }

  void applyPreset(String preset) {
    final DateTime now = DateTime.now();
    switch (preset) {
      case 'today':
        asOfDate.value = now;
        break;
      case 'end_of_month':
        asOfDate.value = DateTime(now.year, now.month + 1, 0);
        break;
      case 'end_of_quarter':
        final int q = ((now.month - 1) ~/ 3);
        asOfDate.value = DateTime(now.year, (q + 1) * 3 + 1, 0);
        break;
      case 'end_of_year':
        asOfDate.value = DateTime(now.year, 12, 31);
        break;
      case 'custom':
        selectedPreset.value = 'custom';
        return;
    }
    selectedPreset.value = preset;
    fetchReport();
  }

  void applyCustomDate(DateTime date) {
    asOfDate.value = date;
    selectedPreset.value = 'custom';
    fetchReport();
  }

  Future<void> fetchReport() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      '${AppUrls.balanceSheet}?as_of_date=${_fmt(asOfDate.value)}',
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

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
