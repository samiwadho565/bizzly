import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/reports/models/income_statement_model.dart';
import 'package:bizly/services/api_service.dart';

class IncomeStatementController extends GetxController {
  final Rxn<IncomeStatementModel> report = Rxn<IncomeStatementModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Date range — defaults to current year
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

  Future<void> fetchReport() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final String from =
        '${fromDate.value.year}-${fromDate.value.month.toString().padLeft(2, '0')}-${fromDate.value.day.toString().padLeft(2, '0')}';
    final String to =
        '${toDate.value.year}-${toDate.value.month.toString().padLeft(2, '0')}-${toDate.value.day.toString().padLeft(2, '0')}';

    final ApiResponse res = await ApiService().get(
      '${AppUrls.incomeStatement}?from_date=$from&to_date=$to',
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
}
