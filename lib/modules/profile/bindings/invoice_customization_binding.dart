import 'package:bizly/modules/profile/controllers/invoice_customization_controller.dart';
import 'package:get/get.dart';

class InvoiceCustomizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceCustomizationController>(() => InvoiceCustomizationController());
  }
}
