import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:get/get.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TasksScreenController>(() => TasksScreenController());
  }
}
