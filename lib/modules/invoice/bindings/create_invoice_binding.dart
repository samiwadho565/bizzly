import 'package:bizly/modules/invoice/controllers/create_invoice_controller.dart';
import 'package:get/get.dart';

class CreateInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateInvoiceController>(() => CreateInvoiceController());
  }
}
