import 'package:get/get.dart';
import 'package:bizly/modules/chart_of_accounts/controllers/coa_controller.dart';

class CoaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoaController>(() => CoaController());
  }
}
