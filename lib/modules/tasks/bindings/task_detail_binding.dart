import 'package:bizly/modules/tasks/controllers/task_detail_controller.dart';
import 'package:get/get.dart';

class TaskDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskDetailController>(() => TaskDetailController());
  }
}
