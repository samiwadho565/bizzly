import 'package:bizly/modules/profile/controllers/tax_setting_controller.dart';
import 'package:get/get.dart';

class TaxSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaxSettingsController>(() => TaxSettingsController());
  }
}
