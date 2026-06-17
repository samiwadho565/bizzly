import 'package:get/get.dart';
import 'package:bizly/modules/ledger/controllers/ledger_controller.dart';

class LedgerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerController>(() => LedgerController());
  }
}
