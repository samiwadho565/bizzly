import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/business/controllers/business_controller.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';


class InvoiceCustomizationController extends GetxController {
  final Rxn<BusinessModel> business = Rxn<BusinessModel>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<File> invoiceLogoFile = Rxn<File>();
  final ImagePicker _picker = ImagePicker();
  // 🔹 Invoice Header
  var businessName = "Your Company Name".obs;
  var businessAddress = "Street, City, Country".obs;
  var businessEmail = "contact@bizly.com / +92 300 1234567".obs;
  var taxNo = "123456789".obs;

  // 🔹 Invoice Numbering
  var startNumber = "1001".obs;
  var prefix = "INV-".obs;
  var autoIncrement = "Enabled".obs;

  // 🔹 Customer Details
  final RxBool showEmail = true.obs;
  final RxBool showPhone = true.obs;
  var showNotes = "Optional".obs;

  // 🔹 Item & Table Settings
  var columns = "Item, Qty, Price, Tax, Total".obs;
  var currency = "PKR".obs;
  var precision = "2".obs;

  // 🔹 Payment Terms
  var dueDate = "15 days".obs;
  var lateFee = "5% if overdue".obs;

  // 🔹 Footer Notes
  var terms = "Default text".obs;
  var additionalNotes = "Optional message".obs;
  var thankYouMsg = "Enabled".obs;

  // 🔹 Colors & Theme
  var primaryColor = "Blue".obs;
  var bgColor = "White".obs;
  var fontStyle = "Default".obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is BusinessModel) {
      business.value = args;
      _hydrateFromBusiness(args);
    } else if (Get.isRegistered<BusinessDetailController>()) {
      final BusinessModel? current =
          Get.find<BusinessDetailController>().business.value;
      if (current != null) {
        business.value = current;
        _hydrateFromBusiness(current);
      }
    }
    fetchBusiness();
  }

  Future<void> fetchBusiness() async {
    final int? id = business.value?.id;
    if (id == null || isLoading.value) return;
    isLoading.value = true;

    final ApiResponse response = await ApiService().get(
      '${AppUrls.getAllBusinesses}/$id',
      isAuth: true,
    );

    if (response.success && response.data is Map) {
      final BusinessModel updated =
          BusinessModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      business.value = updated;
      invoiceLogoFile.value = null;
      _hydrateFromBusiness(updated);
      _syncBusiness(updated);
    }

    isLoading.value = false;
  }

  Future<void> pickInvoiceLogo() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    invoiceLogoFile.value = await _compressImageFile(File(picked.path));
  }

  // Edit Logic
  void editField(
    String title,
    RxString observableValue, {
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool sanitizeNumericInput = false,
    String Function(String value)? onSaveTransform,
  }) {
    final String initialValue = sanitizeNumericInput
        ? _extractLeadingNumber(observableValue.value)
        : observableValue.value;
    TextEditingController textController = TextEditingController(text: initialValue);

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: Get.context!.mediaQueryViewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Edit $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: textController,
              autofocus: true,
              maxLength: maxLength,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLength == null ? 1 : 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomButton(text: "Save", onPressed: (){
                Get.back();
                String value = textController.text.trim();
                if (maxLength != null && value.length > maxLength) {
                  value = value.substring(0, maxLength);
                }
                if (onSaveTransform != null) {
                  value = onSaveTransform(value);
                }
                if (maxLength != null && value.length > maxLength) {
                  observableValue.value = value.substring(0, maxLength);
                  return;
                }
                observableValue.value = value;
              })
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveSettings() async {
    final int? id = business.value?.id;
    if (id == null || isSaving.value) return;
    isSaving.value = true;

    final Map<String, dynamic> data = <String, dynamic>{
      'invoice_show_email': showEmail.value ? '1' : '0',
      'invoice_show_phone': showPhone.value ? '1' : '0',
      'invoice_currency_decimal_position':
          int.tryParse(precision.value.trim()) ?? 2,
      'invoice_due_date_days': _parseDueDateDays(dueDate.value),
      'invoice_late_fee': num.tryParse(_extractLeadingNumber(lateFee.value)) ?? 0,
      'invoice_order_notes': showNotes.value.trim(),
      'invoice_additional_notes': additionalNotes.value.trim(),
      'invoice_thank_you_message': thankYouMsg.value.trim(),
      'invoice_show_thank_you_message':
          thankYouMsg.value.trim().isNotEmpty ? '1' : '0',
      'invoice_prefix': prefix.value.trim(),
      'invoice_numbering_starting_from':
          int.tryParse(startNumber.value.trim()) ?? 1,
      'invoice_terms_text': terms.value.trim(),
      'invoice_business_name': businessName.value.trim(),
      'invoice_business_address': businessAddress.value.trim(),
      'invoice_business_phone': _splitEmailAndPhone()['phone'],
      'invoice_business_email': _splitEmailAndPhone()['email'],
      'invoice_tax_ntn': taxNo.value.trim(),
      'invoice_tax_name': taxNo.value.trim().isNotEmpty
          ? (business.value?.invoiceTaxName ?? 'Tax')
          : '',
      if (invoiceLogoFile.value != null) 'invoice_logo': invoiceLogoFile.value,
    };

    final Map<String, dynamic> debugData = <String, dynamic>{
      for (final MapEntry<String, dynamic> entry in data.entries)
        entry.key: entry.value is File ? entry.value.path : entry.value,
    };
    debugPrint('Invoice customization payload: $debugData');

    final ApiResponse response = await ApiService().postMultipart(
      '${AppUrls.updateBusiness}/$id',
      data: data,
      isAuth: true,
    );

    if (response.success && response.data is Map) {
      final BusinessModel updated =
          BusinessModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      business.value = updated;
      invoiceLogoFile.value = null;
      _hydrateFromBusiness(updated);
      _syncBusiness(updated);
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogSuccess,
        title: 'Success',
        message: 'Invoice customization updated successfully',
        actions: [AppDialogAction(label: 'Ok')],
      );
    } else if (!response.success) {
      debugPrint(
        'Invoice customization error: '
        'message=${response.message}, '
        'statusCode=${response.statusCode}, '
        'errors=${response.errors}, '
        'data=${response.data}',
      );
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: 'Error!',
        message: response.message,
        actions: [AppDialogAction(label: 'Ok')],
      );
    }

    isSaving.value = false;
  }

  void _hydrateFromBusiness(BusinessModel model) {
    businessName.value = _firstNonEmpty(
      <String?>[
        model.invoiceBusinessName,
        model.businessName,
      ],
      fallback: 'Your Company Name',
    );
    businessAddress.value = _firstNonEmpty(
      <String?>[
        model.invoiceBusinessAddress,
        model.businessAddress,
      ],
      fallback: 'Street, City, Country',
    );
    final String email = _firstNonEmpty(
      <String?>[
        model.invoiceBusinessEmail,
        model.businessEmail,
      ],
      fallback: 'contact@bizly.com',
    );
    final String phone = _firstNonEmpty(
      <String?>[
        model.invoiceBusinessPhone,
        model.phoneNumber,
      ],
      fallback: '+92 300 1234567',
    );
    businessEmail.value = _combineEmailPhone(email, phone);
    taxNo.value = _firstNonEmpty(
      <String?>[
        model.invoiceTaxNtn,
        model.taxNtnNumber,
      ],
      fallback: '123456789',
    );
    startNumber.value = (model.invoiceNumberingStartingFrom ?? 1).toString();
    prefix.value = model.invoicePrefix ?? 'INV-';
    autoIncrement.value = 'Enabled';
    showEmail.value = model.invoiceShowEmail ?? true;
    showPhone.value = model.invoiceShowPhone ?? true;
    showNotes.value = _firstNonEmpty(
      <String?>[model.invoiceOrderNotes],
      fallback: 'Optional',
    );
    currency.value = _firstNonEmpty(
      <String?>[model.currency],
      fallback: 'PKR',
    );
    precision.value =
        (model.invoiceCurrencyDecimalPosition ?? 2).toString();
    final int dueDays = model.invoiceDueDateDays ?? 15;
    dueDate.value = '$dueDays ${dueDays == 1 ? 'day' : 'days'}';
    lateFee.value = model.invoiceLateFee == null
        ? '0'
        : _cleanNumber(model.invoiceLateFee!);
    terms.value = _firstNonEmpty(
      <String?>[model.invoiceTermsText],
      fallback: 'Default text',
    );
    additionalNotes.value = _firstNonEmpty(
      <String?>[model.invoiceAdditionalNotes],
      fallback: 'Optional message',
    );
    thankYouMsg.value = _firstNonEmpty(
      <String?>[model.invoiceThankYouMessage],
      fallback: 'Thank you for your business!',
    );
  }

  void _syncBusiness(BusinessModel updated) {
    if (Get.isRegistered<BusinessDetailController>()) {
      Get.find<BusinessDetailController>().applyUpdatedBusiness(updated);
    }
    if (Get.isRegistered<HomeScreenController>()) {
      final HomeScreenController home = Get.find<HomeScreenController>();
      final int index = home.businesses.indexWhere((b) => b.id == updated.id);
      if (index >= 0) {
        home.businesses[index] = updated;
      }
    }
  }

  int _parseDueDateDays(String value) {
    return int.tryParse(_extractLeadingNumber(value)) ?? 15;
  }

  String _extractLeadingNumber(String value) {
    final RegExp match = RegExp(r'[-+]?[0-9]*\.?[0-9]+');
    return match.firstMatch(value)?.group(0) ?? value.trim();
  }

  Map<String, String> _splitEmailAndPhone() {
    final List<String> parts = businessEmail.value.split('/');
    final String email = parts.isNotEmpty ? parts.first.trim() : '';
    final String phone = parts.length > 1 ? parts.last.trim() : '';
    return <String, String>{
      'email': email,
      'phone': phone,
    };
  }

  String _combineEmailPhone(String email, String phone) {
    if (email.isEmpty && phone.isEmpty) return '';
    if (email.isEmpty) return phone;
    if (phone.isEmpty) return email;
    return '$email / $phone';
  }

  String _firstNonEmpty(
    List<String?> values, {
    required String fallback,
  }) {
    for (final String? value in values) {
      final String normalized = (value ?? '').trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return fallback;
  }

  String _cleanNumber(num value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
  }

  String limitedText(String value, int maxLength) {
    final String trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength).trimRight();
  }

  Future<File> _compressImageFile(File file) async {
    final Directory dir = await getTemporaryDirectory();
    int quality = 85;
    File? compressed = file;

    while (compressed != null &&
        await compressed.length() > 2048 * 1024 &&
        quality >= 40) {
      final String targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (result == null) {
        break;
      }
      compressed = File(result.path);
      quality -= 10;
    }

    return compressed ?? file;
  }
}
