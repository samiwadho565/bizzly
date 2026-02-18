import 'package:get/get.dart';

import 'package:bizly/modules/company_assets/controllers/company_assets_controller.dart';

class AddCompanyAssetBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CompanyAssetsController>()) {
      Get.put<CompanyAssetsController>(CompanyAssetsController());
    }
  }
}
