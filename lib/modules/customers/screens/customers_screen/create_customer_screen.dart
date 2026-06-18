import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/customers/controllers/create_customer_controller.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/assets/images.dart';

class _PhoneDigitLimitFormatter extends TextInputFormatter {
  _PhoneDigitLimitFormatter({this.maxDigits = 15});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int digitsCount = newValue.text.replaceAll(RegExp(r'\D'), '').length;
    if (digitsCount > maxDigits) return oldValue;
    return newValue;
  }
}

class CreateCustomerScreen extends GetView<CreateCustomerController> {
  CreateCustomerScreen({super.key});

  final _PhoneDigitLimitFormatter _phoneDigitLimitFormatter =
      _PhoneDigitLimitFormatter(maxDigits: 15);
  final TextInputFormatter _nameLimitFormatter =
      LengthLimitingTextInputFormatter(60);
  final TextInputFormatter _emailLimitFormatter =
      LengthLimitingTextInputFormatter(80);
  final TextInputFormatter _addressLimitFormatter =
      LengthLimitingTextInputFormatter(160);
  final TextInputFormatter _companyLimitFormatter =
      LengthLimitingTextInputFormatter(80);
  final TextInputFormatter _taxLimitFormatter =
      LengthLimitingTextInputFormatter(30);
  final TextInputFormatter _urlLimitFormatter =
      LengthLimitingTextInputFormatter(120);
  final TextInputFormatter _notesLimitFormatter =
      LengthLimitingTextInputFormatter(300);
  final GlobalKey<FormFieldState<String>> _nameFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _phoneFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _addressFieldKey =
      GlobalKey<FormFieldState<String>>();

  Future<void> _scrollToFirstError() async {
    for (final GlobalKey<FormFieldState<String>> key in <GlobalKey<FormFieldState<String>>>[
      _nameFieldKey,
      _phoneFieldKey,
      _addressFieldKey,
    ]) {
      final FormFieldState<String>? state = key.currentState;
      final BuildContext? ctx = key.currentContext;
      if (state?.hasError == true && ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
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
    await controller.createCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: <Widget>[
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
                    children: <Widget>[
                      const SizedBox(height: 28),

                      // ── Avatar picker ──────────────────────────
                      _buildAvatarPicker(),

                      const SizedBox(height: 28),

                      // ── Customer Info section ──────────────────
                      _buildSectionLabel(
                        'Customer Information',
                        Icons.person_outline_rounded,
                        const Color(0xFF1565C0),
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard(<Widget>[
                        _buildFieldLabel('Customer Name',
                            Icons.badge_outlined, const Color(0xFF1565C0)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _nameFieldKey,
                          hintText: 'e.g. Ahmed Ali',
                          verticalPadding: 13,
                          controller: controller.nameController,
                          inputFormatters: <TextInputFormatter>[
                            _nameLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (v) => FormValidations.validateRequiredMin3(
                            v ?? '',
                            fieldName: 'Customer name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Phone Number',
                            Icons.phone_rounded, const Color(0xFFE53935)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _phoneFieldKey,
                          hintText: '+92 300 1234567',
                          verticalPadding: 13,
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d+\-\s()]')),
                            _phoneDigitLimitFormatter,
                            LengthLimitingTextInputFormatter(22),
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Email Address',
                            Icons.email_rounded, const Color(0xFF1565C0)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'email@example.com (optional)',
                          verticalPadding: 13,
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: <TextInputFormatter>[
                            _emailLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Secondary Phone',
                            Icons.phone_android_rounded, const Color(0xFF00897B)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Secondary number (optional)',
                          verticalPadding: 13,
                          controller: controller.secondaryPhoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d+\-\s()]')),
                            _phoneDigitLimitFormatter,
                            LengthLimitingTextInputFormatter(22),
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 4),
                      ]),

                      const SizedBox(height: 24),

                      // ── Address section ────────────────────────
                      _buildSectionLabel(
                        'Address Details',
                        Icons.location_on_rounded,
                        const Color(0xFF00897B),
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard(<Widget>[
                        _buildFieldLabel('Customer Address',
                            Icons.home_rounded, const Color(0xFF00897B)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          fieldKey: _addressFieldKey,
                          hintText: '123 Street, City, Country',
                          verticalPadding: 13,
                          maxLine: 3,
                          controller: controller.addressController,
                          inputFormatters: <TextInputFormatter>[
                            _addressLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (v) => FormValidations.validateRequiredMin3(
                            v ?? '',
                            fieldName: 'Address',
                          ),
                        ),
                        const SizedBox(height: 4),
                      ]),

                      const SizedBox(height: 24),

                      // ── Optional section ───────────────────────
                      _buildSectionLabel(
                        'Optional Details',
                        Icons.tune_rounded,
                        const Color(0xFF8E24AA),
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard(<Widget>[
                        _buildFieldLabel('Company Name',
                            Icons.business_rounded, const Color(0xFF1565C0)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Company name (optional)',
                          verticalPadding: 13,
                          controller: controller.companyController,
                          inputFormatters: <TextInputFormatter>[
                            _companyLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Tax / NTN',
                            Icons.numbers_rounded, const Color(0xFFF57C00)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'e.g. 1234567-8',
                          verticalPadding: 13,
                          controller: controller.taxController,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9\-/]')),
                            _taxLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Website',
                            Icons.language_rounded, const Color(0xFF00897B)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'https://example.com',
                          verticalPadding: 13,
                          controller: controller.websiteController,
                          keyboardType: TextInputType.url,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            _urlLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Social Link',
                            Icons.share_rounded, const Color(0xFF8E24AA)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'https://facebook.com/...',
                          verticalPadding: 13,
                          controller: controller.socialController,
                          keyboardType: TextInputType.url,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            _urlLimitFormatter,
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Notes',
                            Icons.notes_rounded, const Color(0xFF546E7A)),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Any additional notes...',
                          verticalPadding: 13,
                          maxLine: 4,
                          controller: controller.notesController,
                          inputFormatters: <TextInputFormatter>[
                            _notesLimitFormatter,
                          ],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                        const SizedBox(height: 4),
                      ]),

                      const SizedBox(height: 28),

                      // ── Submit button ──────────────────────────
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
                                            ? 'Update Customer'
                                            : 'Save Customer',
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
  // Gradient header
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
        children: <Widget>[
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
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Obx(() => Text(
                      controller.isEdit ? 'Edit Customer' : 'Add Customer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Avatar picker
  // ─────────────────────────────────────────────────────────────────

  Widget _buildAvatarPicker() {
    return Center(
      child: Obx(() {
        final bool hasLocalImage = controller.profileImageFile.value != null;
        final String remoteImage =
            controller.editingCustomer.value?.profileImage ?? '';
        final bool hasRemoteImage = remoteImage.isNotEmpty;
        final ImageProvider? imageProvider = hasLocalImage
            ? FileImage(controller.profileImageFile.value!)
            : (hasRemoteImage ? NetworkImage(remoteImage) : null);

        return GestureDetector(
          onTap: controller.pickProfileImage,
          child: Stack(
            children: <Widget>[
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
                    radius: 44,
                    backgroundColor: AppColors.textField,
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? ClipOval(
                            child: Image.asset(
                              AppImages.profilePlaceholder,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              // Camera badge
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Section label
  // ─────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
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
  // Form card
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
      children: <Widget>[
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
}
