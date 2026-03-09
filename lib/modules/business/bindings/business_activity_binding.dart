import 'package:get/get.dart';

import 'package:bizly/modules/business/controllers/business_activity_controller.dart';

class BusinessActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessActivityController>(() => BusinessActivityController());
  }
}
