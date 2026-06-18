import 'dart:io';

import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Fixed Gradient Header ──────────────────────────────
          _buildGradientHeader(context),

          // ── Scrollable Form ────────────────────────────────────
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Cover + Logo Picker ──────────────────
                      Obx(
                        () => _coverAndLogoPreview(
                          coverFile: controller.businessCoverImageFile.value,
                          logoFile: controller.businessImageFile.value,
                          coverUrl: controller.editingBusiness.value
                              ?.businessCoverImageUrl,
                          logoUrl:
                              controller.editingBusiness.value?.businessImageUrl,
                          onPickCover: controller.pickBusinessCoverImage,
                          onPickLogo: controller.pickBusinessImage,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Required Section ─────────────────────
                      _buildSectionLabel(
                        'Required Information',
                        Icons.check_circle_outline_rounded,
                        const Color(0xFF1565C0),
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard([
                        _buildFieldLabel(
                          'Business Name',
                          Icons.business_rounded,
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _businessNameFieldKey,
                          hintText: 'Fixonto',
                          verticalPadding: 13,
                          controller: controller.businessNameController,
                          inputFormatters: <TextInputFormatter>[
                            _nameLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              FormValidations.validateRequiredMin3(
                            value ?? '',
                            fieldName: 'Business Name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Business Address',
                          Icons.location_on_rounded,
                          const Color(0xFF00897B),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _businessAddressFieldKey,
                          hintText: '123 Street, City',
                          verticalPadding: 13,
                          controller: controller.businessAddressController,
                          inputFormatters: <TextInputFormatter>[
                            _addressLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              FormValidations.validateRequiredMin3(
                            value ?? '',
                            fieldName: 'Business Address',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Phone Number',
                          Icons.phone_rounded,
                          const Color(0xFFE53935),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _phoneFieldKey,
                          hintText: '+92 300 1234567',
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
                        const SizedBox(height: 4),
                      ]),

                      const SizedBox(height: 24),

                      // ── Optional Section ─────────────────────
                      _buildSectionLabel(
                        'Optional Information',
                        Icons.tune_rounded,
                        const Color(0xFF8E24AA),
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard([
                        _buildFieldLabel(
                          'Email Address',
                          Icons.email_rounded,
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _emailFieldKey,
                          hintText: 'example@mail.com',
                          verticalPadding: 13,
                          controller: controller.businessEmailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: <TextInputFormatter>[
                            _emailLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                          validator: _validateOptionalEmail,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Tax / NTN Number',
                          Icons.numbers_rounded,
                          const Color(0xFFF57C00),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'e.g., 1234567-8',
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
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Website URL',
                          Icons.language_rounded,
                          const Color(0xFF00897B),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _websiteFieldKey,
                          hintText: 'https://www.example.com',
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
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Social Media URL',
                          Icons.share_rounded,
                          const Color(0xFF8E24AA),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _socialFieldKey,
                          hintText: 'https://facebook.com/example',
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
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Business Description',
                          Icons.description_rounded,
                          const Color(0xFF546E7A),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Short description about business',
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
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Operating Hours',
                          Icons.access_time_rounded,
                          const Color(0xFFE53935),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Tap to select operating hours',
                          verticalPadding: 13,
                          controller: controller.operatingHoursController,
                          readOnly: true,
                          onTap: () => _pickOperatingHours(context),
                          suffixIcon: const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Secondary Contact',
                          Icons.contact_phone_rounded,
                          const Color(0xFF00897B),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _secondaryContactFieldKey,
                          hintText: 'Optional: +92 300 7654321',
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
                        const SizedBox(height: 4),
                      ]),

                      const SizedBox(height: 28),

                      // ── Submit Button ────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: controller.isLoading.value
                                    ? null
                                    : const LinearGradient(
                                        colors: <Color>[
                                          Color(0xFF1565C0),
                                          Color(0xFF0A2472),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                color: controller.isLoading.value
                                    ? Colors.grey.shade300
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: controller.isLoading.value
                                    ? <BoxShadow>[]
                                    : <BoxShadow>[
                                        BoxShadow(
                                          color: const Color(0xFF1565C0)
                                              .withOpacity(0.35),
                                          blurRadius: 12,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : _submitForm,
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        controller.isEdit
                                            ? 'Update Business'
                                            : 'Create Business',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Gradient Header
  // ─────────────────────────────────────────────────────────────────

  Widget _buildGradientHeader(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Text(
                  controller.isEdit ? 'Update Business' : 'Add New Business',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Section label
  // ─────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Form card container
  // ─────────────────────────────────────────────────────────────────

  Widget _buildFormCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Field label with icon
  // ─────────────────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Cover + Logo picker
  // ─────────────────────────────────────────────────────────────────

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
    final bool hasCover = coverFile != null || hasCoverUrl;

    final ImageProvider<Object>? logoProvider = logoFile != null
        ? FileImage(logoFile)
        : (hasLogoUrl ? NetworkImage(logoUrl!) : null);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover image area
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onPickCover,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: !hasCover
                      ? const LinearGradient(
                          colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: hasCover ? AppColors.textField : null,
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
                child: Stack(
                  children: [
                    // Placeholder content (no cover)
                    if (!hasCover)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white.withOpacity(0.7),
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add cover image',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Dark gradient overlay when cover exists
                    if (hasCover)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    // Camera icon (bottom-right)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Logo avatar with gradient ring
            Positioned(
              left: 20,
              bottom: -38,
              child: GestureDetector(
                onTap: onPickLogo,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.textField,
                          backgroundImage: logoProvider,
                          child: logoProvider == null
                              ? const Icon(
                                  Icons.storefront_outlined,
                                  color: AppColors.primary,
                                  size: 26,
                                )
                              : null,
                        ),
                      ),
                    ),
                    // Camera badge
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF1565C0),
                              Color(0xFF0A2472),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 50),

        // Hint
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 5),
              Text(
                'Tap cover to change  •  Tap circle to set logo',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
