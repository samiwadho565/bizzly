
import 'package:bizly/modules/auth/controllers/signin_controller.dart';
import 'package:bizly/modules/auth/controllers/signup_controller.dart';
import 'package:bizly/modules/expense/controllers/expense_detail_screen_controller.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/modules/nav/controllers/main_screen_controller.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/expense/controllers/expense_screen_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<MainScreenController>(() => MainScreenController());
    Get.lazyPut<ExpenseDetailController>(() =>ExpenseDetailController());
    Get.lazyPut<ExpenseScreenController>(() =>ExpenseScreenController());
    Get.lazyPut<SignInController>(() => SignInController());
    Get.lazyPut<SignupController>(() => SignupController());

  }
}
