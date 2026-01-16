
import 'package:bizly/controllers/expense_detail_screen_controller.dart';
import 'package:bizly/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../controllers/expense_screen_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<ExpenseDetailController>(() =>ExpenseDetailController());
    Get.lazyPut<ExpenseScreenController>(() =>ExpenseScreenController());

  }
}
