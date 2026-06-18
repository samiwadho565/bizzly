import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/modules/vendors/controllers/create_vendor_controller.dart';

class CreateVendorScreen extends GetView<CreateVendorController> {
  const CreateVendorScreen({super.key});

  static const LinearGradient _gradient = LinearGradient(
    colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: <Widget>[
            // ── Fixed Gradient Header ──────────────────────────────
            _buildGradientHeader(context, topPad),

            // ── Scrollable Form ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ─── Vendor Information ───────────────────
                      _buildSectionLabel(
                          'Vendor Information', Icons.local_shipping_outlined),
                      const SizedBox(height: 10),
                      _buildFormCard(<Widget>[
                        _buildFieldLabel('Vendor Name', Icons.badge_outlined,
                            Colors.blue.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.nameFieldKey,
                          controller: controller.nameController,
                          inputFormatters: controller.nameInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.vendorNameValidator,
                          decoration: _fieldDecoration('Enter vendor name'),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Phone Number', Icons.phone_outlined,
                            Colors.green.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.phoneFieldKey,
                          controller: controller.phoneController,
                          inputFormatters: controller.phoneInputFormatters,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: controller.phoneValidator,
                          decoration: _fieldDecoration('Enter phone number'),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Email Address (Optional)',
                            Icons.email_outlined, Colors.orange.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.emailFieldKey,
                          controller: controller.emailController,
                          inputFormatters: controller.emailInputFormatters,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: controller.optionalEmailValidator,
                          decoration: _fieldDecoration('Enter email address'),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Company Name',
                            Icons.business_outlined, Colors.purple.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.companyFieldKey,
                          controller: controller.companyController,
                          inputFormatters: controller.companyInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.companyNameValidator,
                          decoration: _fieldDecoration('Enter company name'),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Tax Number (NTN / GST)',
                            Icons.confirmation_number_outlined,
                            Colors.teal.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.taxFieldKey,
                          controller: controller.taxController,
                          inputFormatters: controller.taxInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.taxNumberValidator,
                          decoration: _fieldDecoration('Enter tax number'),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ─── Address Details ──────────────────────
                      _buildSectionLabel(
                          'Address Details', Icons.location_on_outlined),
                      const SizedBox(height: 10),
                      _buildFormCard(<Widget>[
                        _buildFieldLabel('Vendor Address',
                            Icons.location_on_outlined, Colors.red.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.addressFieldKey,
                          controller: controller.addressController,
                          inputFormatters: controller.addressInputFormatters,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          validator: controller.addressValidator,
                          decoration: _fieldDecoration('Enter vendor address'),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ─── Optional Details ─────────────────────
                      _buildSectionLabel(
                          'Optional Details', Icons.notes_rounded),
                      const SizedBox(height: 10),
                      _buildFormCard(<Widget>[
                        _buildFieldLabel('Notes', Icons.notes_rounded,
                            Colors.blueGrey.shade600),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.notesFieldKey,
                          controller: controller.notesController,
                          inputFormatters: controller.notesInputFormatters,
                          maxLines: 4,
                          textInputAction: TextInputAction.done,
                          validator: controller.notesValidator,
                          decoration: _fieldDecoration('Add notes (optional)'),
                        ),
                      ]),

                      const SizedBox(height: 30),

                      // ─── Submit Button ────────────────────────
                      Obx(() => DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _gradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color:
                                      const Color(0xFF1565C0).withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.submitForm,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      controller.isEdit
                                          ? 'Update Vendor'
                                          : 'Save Vendor',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context, double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 20),
      decoration: const BoxDecoration(gradient: _gradient),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                controller.isEdit ? 'Edit Vendor' : 'Add Vendor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon, Color color) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 13),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF1565C0), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }
}
