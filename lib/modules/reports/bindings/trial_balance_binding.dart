import 'package:get/get.dart';

import 'package:bizly/modules/reports/controllers/trial_balance_controller.dart';

class TrialBalanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrialBalanceController>(
      () => TrialBalanceController(),
      fenix: true,
    );
  }
}
