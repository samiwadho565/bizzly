import 'package:get/get.dart';

import 'package:bizly/modules/vendors/controllers/vendors_controller.dart';

class VendorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorsController>(() => VendorsController());
  }
}
