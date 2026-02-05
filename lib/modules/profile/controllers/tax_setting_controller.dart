import 'package:get/get.dart';

class TaxSettingsController extends GetxController {
  var isTaxEnabled = true.obs;
  var taxName = "GST".obs; // GST, VAT, etc.
  var taxRate = "18".obs;
  var taxId = "NTN-1234567-8".obs;

  void toggleTax(bool value) {
    isTaxEnabled.value = value;
  }
}