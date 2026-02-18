import 'package:get/get.dart';

import 'package:bizly/modules/team/controllers/team_controller.dart';

class TeamScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamController>(() => TeamController());
  }
}
