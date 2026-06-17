import 'package:get/get.dart';
import 'package:bizly/modules/reports/controllers/income_statement_controller.dart';

class IncomeStatementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeStatementController>(() => IncomeStatementController());
  }
}
