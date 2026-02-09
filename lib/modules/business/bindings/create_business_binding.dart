import 'package:get/get.dart';

import 'package:bizly/modules/business/controllers/create_business_controller.dart';

class CreateBusinessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateBusinessController>(() => CreateBusinessController());
  }
}
