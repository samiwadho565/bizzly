import 'package:bizly/modules/expense/controllers/expense_screen_controller.dart';
import 'package:get/get.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseScreenController>(() => ExpenseScreenController());
  }
}
