import 'package:get/get.dart';
import 'package:bizly/modules/vendors/controllers/create_vendor_controller.dart';

class CreateVendorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateVendorController>(() => CreateVendorController());
  }
}
