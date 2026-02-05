import 'package:bizly/modules/invoice/controllers/invoice_detail_controller.dart';
import 'package:get/get.dart';

class InvoiceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceDetailController>(() => InvoiceDetailController());
  }
}
