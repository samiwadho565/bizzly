import 'dart:io';

import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/business/controllers/create_business_controller.dart';

class _PhoneDigitLimitFormatter extends TextInputFormatter {
  _PhoneDigitLimitFormatter({this.maxDigits = 15});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int digitsCount = newValue.text.replaceAll(RegExp(r'\D'), '').length;
    if (digitsCount > maxDigits) {
      return oldValue;
    }
    return newValue;
  }
}

class AddNewBusinessScreen extends GetView<CreateBusinessController> {
  AddNewBusinessScreen({super.key});

  // ✅ Common TextStyles
  final TextStyle requiredLabelStyle =
  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black);


  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  final GlobalKey<FormFieldState<String>> _businessNameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _businessAddressFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _phoneFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _currencyFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _emailFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _websiteFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _socialFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _secondaryContactFieldKey =
      GlobalKey<FormFieldState<String>>();
  final _PhoneDigitLimitFormatter _phoneDigitLimitFormatter =
      _PhoneDigitLimitFormatter(maxDigits: 15);
  final TextInputFormatter _nameLimitFormatter =
      LengthLimitingTextInputFormatter(60);
  final TextInputFormatter _addressLimitFormatter =
      LengthLimitingTextInputFormatter(140);
  final TextInputFormatter _emailLimitFormatter =
      LengthLimitingTextInputFormatter(80);
  final TextInputFormatter _taxLimitFormatter =
      LengthLimitingTextInputFormatter(30);
  final TextInputFormatter _urlLimitFormatter =
      LengthLimitingTextInputFormatter(120);
  final TextInputFormatter _descriptionLimitFormatter =
      LengthLimitingTextInputFormatter(300);

  Future<void> _scrollToFirstError() async {
    final List<GlobalKey<FormFieldState<String>>> keysInOrder =
        <GlobalKey<FormFieldState<String>>>[
      _businessNameFieldKey,
      _businessAddressFieldKey,
      _phoneFieldKey,
      _currencyFieldKey,
      _emailFieldKey,
      _websiteFieldKey,
      _socialFieldKey,
      _secondaryContactFieldKey,
    ];

    for (final GlobalKey<FormFieldState<String>> key in keysInOrder) {
      final FormFieldState<String>? state = key.currentState;
      final BuildContext? context = key.currentContext;
      if (state?.hasError == true && context != null) {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
        return;
      }
    }
  }

  Future<void> _submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final bool valid = controller.formKey.currentState?.validate() ?? false;
    if (!valid) {
      await Future<void>.delayed(Duration.zero);
      await _scrollToFirstError();
      return;
    }
    await controller.createBusiness();
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(
      time,
      alwaysUse24HourFormat: false,
    );
  }

  TimeOfDay? _parseTimePart(String value) {
    final RegExp pattern =
        RegExp(r'^\s*(\d{1,2})(?::(\d{2}))?\s*([AaPp][Mm])\s*$');
    final RegExpMatch? match = pattern.firstMatch(value);
    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    final int minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final String amPm = match.group(3)!.toUpperCase();

    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;

    if (amPm == 'AM') {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  ({TimeOfDay start, TimeOfDay end})? _parseOperatingHours(String raw) {
    final List<String> parts = raw.split('-');
    if (parts.length != 2) return null;

    final TimeOfDay? start = _parseTimePart(parts[0].trim());
    final TimeOfDay? end = _parseTimePart(parts[1].trim());
    if (start == null || end == null) return null;

    return (start: start, end: end);
  }

  Future<TimeOfDay?> _showThemedTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    required String helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      builder: (BuildContext context, Widget? child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        final ThemeData baseTheme = Theme.of(context);
        final WidgetStateColor selectedTextColor =
            WidgetStateColor.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textPrimary;
        });
        final WidgetStateColor selectedBgColor =
            WidgetStateColor.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textField;
        });
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: baseTheme.colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: selectedBgColor,
              hourMinuteTextColor: selectedTextColor,
              dayPeriodColor: selectedBgColor,
              dayPeriodTextColor: selectedTextColor,
              dialHandColor: AppColors.primary,
              dialBackgroundColor: AppColors.textField,
              dialTextColor: selectedTextColor,
              entryModeIconColor: AppColors.primary,
              helpTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child,
        );
      },
    );
  }

  int _timeToMinutes(TimeOfDay time) => (time.hour * 60) + time.minute;

  Future<void> _pickOperatingHours(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final ({TimeOfDay start, TimeOfDay end})? existingHours =
        _parseOperatingHours(controller.operatingHoursController.text);
    final TimeOfDay startInitial =
        existingHours?.start ?? const TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay endInitial =
        existingHours?.end ?? const TimeOfDay(hour: 18, minute: 0);

    final TimeOfDay? startTime = await _showThemedTimePicker(
      context: context,
      initialTime: startInitial,
      helpText: 'Select opening time',
    );
    if (startTime == null || !context.mounted) return;

    TimeOfDay? endTime;
    TimeOfDay currentEndInitial = endInitial;
    while (true) {
      endTime = await _showThemedTimePicker(
        context: context,
        initialTime: currentEndInitial,
        helpText: 'Select closing time',
      );
      if (endTime == null) return;

      if (_timeToMinutes(endTime) > _timeToMinutes(startTime)) {
        break;
      }

      AppUtils.showAppSnackbar(
        'Invalid Time Range',
        'Closing time must be later than opening time.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withAlpha(220),
      );
      currentEndInitial = endTime;
    }

    controller.operatingHoursController.text =
        '${_formatTime(context, startTime)} - ${_formatTime(context, endTime)}';
  }

  String? _validatePhoneNumber(
    String? value, {
    required String fieldName,
    required bool isRequired,
  }) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return isRequired ? '$fieldName is required' : null;
    }
    final RegExp phoneRegex = RegExp(r'^[\d+\-\s()]+$');
    if (!phoneRegex.hasMatch(text)) {
      return 'Enter a valid $fieldName';
    }
    final String digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return '$fieldName must be at least 10 digits';
    }
    if (digitsOnly.length > 15) {
      return '$fieldName cannot exceed 15 digits';
    }
    return null;
  }

  String? _validateOptionalEmail(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return FormValidations.validateEmail(text);
  }

  String? _validateOptionalUrl(String? value, {required String fieldName}) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return null;

    final Uri? uri = Uri.tryParse(text);
    final bool hasValidSchemeUrl =
        uri != null && uri.hasScheme && uri.host.isNotEmpty;
    final Uri? prefixedUri = Uri.tryParse('https://$text');
    final bool looksLikeDomain =
        prefixedUri != null && prefixedUri.host.contains('.');

    if (!hasValidSchemeUrl && !looksLikeDomain) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: controller.isEdit ? "Update Business" : "Add New Business",
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // ----------------- Image Previews -----------------
                      Obx(
                        () => _coverAndLogoPreview(
                          coverFile: controller.businessCoverImageFile.value,
                          logoFile: controller.businessImageFile.value,
                          coverUrl:
                              controller.editingBusiness.value?.businessCoverImageUrl,
                          logoUrl:
                              controller.editingBusiness.value?.businessImageUrl,
                          onPickCover: controller.pickBusinessCoverImage,
                          onPickLogo: controller.pickBusinessImage,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ----------------- Required Fields -----------------
                      Text("Required Information", style: sectionTitleStyle),
                      const SizedBox(height: 15),

                      Text("Business Name", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: _businessNameFieldKey,
                        hintText: "Fixonto",
                        verticalPadding: 13,
                        controller: controller.businessNameController,
                        inputFormatters: <TextInputFormatter>[
                          _nameLimitFormatter,
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (value) => FormValidations.validateRequiredMin3(
                          value ?? '',
                          fieldName: 'Business Name',
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text("Business Address", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: _businessAddressFieldKey,
                        hintText: "123 Street, City",
                        verticalPadding: 13,
                        controller: controller.businessAddressController,
                        inputFormatters: <TextInputFormatter>[
                          _addressLimitFormatter,
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (value) => FormValidations.validateRequiredMin3(
                          value ?? '',
                          fieldName: 'Business Address',
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text("Phone Number", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: _phoneFieldKey,
                        hintText: "+92 300 1234567",
                        verticalPadding: 13,
                        controller: controller.phoneNumberController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d+\-\s()]'),
                          ),
                          _phoneDigitLimitFormatter,
                          LengthLimitingTextInputFormatter(22),
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validatePhoneNumber(
                          value,
                          fieldName: 'Phone Number',
                          isRequired: true,
                        ),
                      ),
                      // Currency is intentionally disabled for now.
                      // Keep this block commented for future re-enable.
                      // const SizedBox(height: 15),
                      //
                      // Text("Currency", style: requiredLabelStyle),
                      // const SizedBox(height: 8),
                      // CustomTextField(
                      //   fieldKey: _currencyFieldKey,
                      //   hintText: "PKR",
                      //   verticalPadding: 13,
                      //   controller: controller.currencyController,
                      //   textInputAction: TextInputAction.next,
                      //   validator: (value) => FormValidations.validateRequired(
                      //     value ?? '',
                      //     fieldName: 'Currency',
                      //   ),
                      // ),

                    const SizedBox(height: 25),

                      // ----------------- Optional Fields -----------------
                      Text("Optional Information", style: sectionTitleStyle),
                      const SizedBox(height: 15),

                      Text("Email Address", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: _emailFieldKey,
                        hintText: "example@mail.com",
                        verticalPadding: 13,
                        controller: controller.businessEmailController,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: <TextInputFormatter>[
                          _emailLimitFormatter,
                        ],
                        textInputAction: TextInputAction.next,
                        validator: _validateOptionalEmail,
                      ),
                      const SizedBox(height: 15),

                      Text("Tax / NTN Number", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "e.g., 1234567-8",
                        verticalPadding: 13,
                        controller: controller.taxNtnController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\-/]'),
                          ),
                          _taxLimitFormatter,
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),

                      Text("Website URL", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: _websiteFieldKey,
                        hintText: "https://www.example.com",
                        verticalPadding: 13,
                        controller: controller.websiteController,
                        keyboardType: TextInputType.url,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          _urlLimitFormatter,
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateOptionalUrl(
                          value,
                          fieldName: 'Website URL',
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text("Social Media URL", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: _socialFieldKey,
                        hintText: "https://facebook.com/example",
                        verticalPadding: 13,
                        controller: controller.socialMediaController,
                        keyboardType: TextInputType.url,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          _urlLimitFormatter,
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateOptionalUrl(
                          value,
                          fieldName: 'Social Media URL',
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text("Business Description", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "Short description about business",
                        verticalPadding: 13,
                        controller: controller.businessDescriptionController,
                        maxLine: 3,
                        inputFormatters: <TextInputFormatter>[
                          _descriptionLimitFormatter,
                        ],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                      const SizedBox(height: 15),

                      Text("Operating Hours", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: "Tap to select operating hours",
                        verticalPadding: 13,
                        controller: controller.operatingHoursController,
                        readOnly: true,
                        onTap: () => _pickOperatingHours(context),
                        suffixIcon: const Icon(
                          Icons.access_time_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text("Secondary Contact", style: requiredLabelStyle),
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldKey: _secondaryContactFieldKey,
                        hintText: "Optional: +92 300 7654321",
                        verticalPadding: 13,
                        controller: controller.secondaryContactController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d+\-\s()]'),
                          ),
                          _phoneDigitLimitFormatter,
                          LengthLimitingTextInputFormatter(22),
                        ],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        validator: (value) => _validatePhoneNumber(
                          value,
                          fieldName: 'Secondary Contact',
                          isRequired: false,
                        ),
                      ),


                      const SizedBox(height: 30),

                      // Create Button
                      Obx(
                        () => CustomButton(
                          text: controller.isEdit
                              ? "Update Business"
                              : "Create Business",
                          isLoading: controller.isLoading.value,
                          onPressed: () {
                            _submitForm();
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePickerTile({
    required String label,
    required VoidCallback onTap,
    String? filePath,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textField,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.image_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filePath ?? label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filePath == null ? Colors.grey.shade700 : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Select",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverAndLogoPreview({
    required File? coverFile,
    required File? logoFile,
    required String? coverUrl,
    required String? logoUrl,
    required VoidCallback onPickCover,
    required VoidCallback onPickLogo,
  }) {
    final bool hasCoverUrl = coverUrl != null && coverUrl.isNotEmpty;
    final bool hasLogoUrl = logoUrl != null && logoUrl.isNotEmpty;

    final ImageProvider<Object>? logoProvider = logoFile != null
        ? FileImage(logoFile)
        : (hasLogoUrl ? NetworkImage(logoUrl!) : null);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onPickCover,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.textField,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  image: coverFile != null
                      ? DecorationImage(
                          image: FileImage(coverFile),
                          fit: BoxFit.cover,
                        )
                      : (hasCoverUrl
                          ? DecorationImage(
                              image: NetworkImage(coverUrl!),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child: coverFile == null && !hasCoverUrl
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.photo_library_outlined,
                              color: AppColors.primary, size: 28),
                          SizedBox(height: 6),
                          Text(
                            "Select cover image (optional)",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            Positioned(
              left: 20,
              bottom: -35,
              child: GestureDetector(
                onTap: onPickLogo,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.textField,
                    backgroundImage: logoProvider,
                    child: logoProvider == null
                        ? const Icon(Icons.storefront_outlined,
                            color: AppColors.primary, size: 30)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Tap the circle to select business image (required)",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
