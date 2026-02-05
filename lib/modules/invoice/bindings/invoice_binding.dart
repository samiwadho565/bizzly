import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:get/get.dart';

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceScreenController>(() => InvoiceScreenController());
  }
}
