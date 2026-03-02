import 'package:get/get.dart';

import 'package:bizly/modules/invoice/controllers/invoice_payments_controller.dart';

class InvoicePaymentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoicePaymentsController>(() => InvoicePaymentsController());
  }
}
