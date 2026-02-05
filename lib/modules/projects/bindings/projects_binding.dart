import 'package:bizly/modules/projects/controllers/projects_screen_controller.dart';
import 'package:get/get.dart';

class ProjectsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectsScreenController>(() => ProjectsScreenController());
  }
}
