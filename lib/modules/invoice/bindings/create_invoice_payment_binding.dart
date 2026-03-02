import 'package:get/get.dart';

import 'package:bizly/modules/invoice/controllers/create_invoice_payment_controller.dart';

class CreateInvoicePaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateInvoicePaymentController>(() => CreateInvoicePaymentController());
  }
}
