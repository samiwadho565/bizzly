import 'package:bizly/modules/nav/controllers/main_screen_controller.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/modules/expense/controllers/expense_screen_controller.dart';
import 'package:bizly/modules/expense/controllers/expenses_list_controller.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:bizly/modules/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainScreenController>(() => MainScreenController());
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<AddExpenseScreenController>(() => AddExpenseScreenController());
    Get.lazyPut<ExpensesListController>(() => ExpensesListController());
    Get.lazyPut<InvoiceScreenController>(() => InvoiceScreenController());
    Get.lazyPut<TasksScreenController>(() => TasksScreenController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
