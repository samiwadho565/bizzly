import 'package:get/get.dart';
import 'package:bizly/modules/customers/controllers/create_customer_controller.dart';

class CreateCustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateCustomerController>(() => CreateCustomerController());
  }
}
