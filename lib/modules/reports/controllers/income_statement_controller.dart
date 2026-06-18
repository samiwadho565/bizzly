import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/reports/models/income_statement_model.dart';
import 'package:bizly/services/api_service.dart';

class IncomeStatementController extends GetxController {
  final Rxn<IncomeStatementModel> report = Rxn<IncomeStatementModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // ── Date Filter ───────────────────────────────────────────────
  final RxString selectedPreset = 'this_year'.obs;
  late Rx<DateTime> fromDate;
  late Rx<DateTime> toDate;

  @override
  void onInit() {
    super.onInit();
    final DateTime now = DateTime.now();
    fromDate = DateTime(now.year, 1, 1).obs;
    toDate = now.obs;
    fetchReport();
  }

  void applyPreset(String preset) {
    final DateTime now = DateTime.now();
    switch (preset) {
      case 'this_month':
        fromDate.value = DateTime(now.year, now.month, 1);
        toDate.value = now;
        break;
      case 'last_month':
        fromDate.value = DateTime(now.year, now.month - 1, 1);
        toDate.value = DateTime(now.year, now.month, 0);
        break;
      case 'this_quarter':
        final int q = ((now.month - 1) ~/ 3);
        fromDate.value = DateTime(now.year, q * 3 + 1, 1);
        toDate.value = now;
        break;
      case 'this_year':
        fromDate.value = DateTime(now.year, 1, 1);
        toDate.value = now;
        break;
      case 'custom':
        selectedPreset.value = 'custom';
        return;
    }
    selectedPreset.value = preset;
    fetchReport();
  }

  void applyCustomRange(DateTime from, DateTime to) {
    fromDate.value = from;
    toDate.value = to;
    selectedPreset.value = 'custom';
    fetchReport();
  }

  Future<void> fetchReport() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse res = await ApiService().get(
      '${AppUrls.incomeStatement}?from_date=${_fmt(fromDate.value)}&to_date=${_fmt(toDate.value)}',
      isAuth: true,
    );

    isLoading.value = false;

    if (res.success && res.data is Map) {
      report.value = IncomeStatementModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } else {
      report.value = null;
      error.value = res.message;
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
