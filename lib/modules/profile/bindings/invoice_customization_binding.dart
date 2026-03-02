import 'package:bizly/modules/profile/controllers/invoice_customization_controller.dart';
import 'package:get/get.dart';

class InvoiceCustomizationBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<InvoiceCustomizationController>()) {
      Get.delete<InvoiceCustomizationController>();
    }
    Get.lazyPut<InvoiceCustomizationController>(
      () => InvoiceCustomizationController(),
      fenix: true,
    );
  }
}
