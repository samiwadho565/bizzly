import 'package:get/get.dart';
import 'package:bizly/modules/accounting_periods/controllers/accounting_period_controller.dart';

class AccountingPeriodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingPeriodController>(() => AccountingPeriodController());
  }
}
