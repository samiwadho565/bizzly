import 'package:get/get.dart';

import 'package:bizly/modules/reports/controllers/balance_sheet_controller.dart';

class BalanceSheetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BalanceSheetController>(
      () => BalanceSheetController(),
      fenix: true,
    );
  }
}
