import 'package:get/get.dart';

import 'package:bizly/modules/company_assets/controllers/company_assets_controller.dart';

class CompanyAssetsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyAssetsController>(() => CompanyAssetsController(), fenix: true);
  }
}
