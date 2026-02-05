import 'package:bizly/modules/business/controllers/business_controller.dart';
import 'package:get/get.dart';

class BusinessDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessDetailController>(() => BusinessDetailController());
  }
}
