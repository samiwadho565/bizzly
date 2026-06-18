import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/business_picker_bottom_sheet.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/team/controllers/team_controller.dart';
import 'package:bizly/utils/app_colors.dart';

class AddEmployeeScreen extends GetView<TeamController> {
  AddEmployeeScreen({super.key}) {
    controller.prepareCreateForm(Get.arguments);
  }

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
            // ── Fixed Gradient Header ──────────────────────────
            _buildGradientHeader(topPad),

            // ── Scrollable Form ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Form(
                  key: controller.createFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ─── Required Details ──────────────────
                      _buildSectionLabel(
                          'Required Details', Icons.person_outline_rounded),
                      const SizedBox(height: 10),
                      _buildFormCard(<Widget>[
                        // Business picker
                        _buildFieldLabel(
                            'Business', Icons.business_outlined, Colors.blue.shade700),
                        const SizedBox(height: 8),
                        Obx(() {
                          final BusinessModel? selected =
                              controller.selectedBusiness.value;
                          final String error = controller.businessError.value;
                          return Column(
                            key: controller.businessFieldKey,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () async {
                                  final businesses = controller.businesses;
                                  if (businesses.isEmpty) return;
                                  final BusinessModel? picked =
                                      await showBusinessPickerBottomSheet(
                                    context,
                                    businesses: businesses,
                                    selectedBusinessId: selected?.id,
                                    title: 'Select Business',
                                  );
                                  if (picked != null) {
                                    controller.selectedBusiness.value = picked;
                                    controller.businessError.value = '';
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: error.isNotEmpty
                                          ? Colors.red
                                          : Colors.grey.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          selected?.businessName ??
                                              'Select a business',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: selected == null
                                                ? Colors.grey.shade400
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey.shade400),
                                    ],
                                  ),
                                ),
                              ),
                              if (error.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6, left: 4),
                                  child: Text(
                                    error,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                ),
                            ],
                          );
                        }),

                        const SizedBox(height: 16),
                        _buildFieldLabel(
                            'Full Name', Icons.person_rounded, Colors.indigo.shade600),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.nameFieldKey,
                          controller: controller.nameController,
                          inputFormatters: controller.employeeNameInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.employeeNameValidator,
                          decoration: _fieldDecoration('Enter full name'),
                        ),

                        const SizedBox(height: 16),
                        _buildFieldLabel(
                            'Email Address', Icons.email_outlined, Colors.orange.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.emailFieldKey,
                          controller: controller.emailController,
                          inputFormatters: controller.employeeEmailInputFormatters,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.employeeEmailValidator,
                          decoration: _fieldDecoration('Enter email address'),
                        ),

                        const SizedBox(height: 16),
                        _buildFieldLabel(
                            'Phone Number', Icons.phone_outlined, Colors.green.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.phoneFieldKey,
                          controller: controller.phoneController,
                          inputFormatters: controller.employeePhoneInputFormatters,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          validator: controller.employeePhoneValidator,
                          decoration: _fieldDecoration('Enter phone number'),
                        ),

                        const SizedBox(height: 16),
                        _buildFieldLabel(
                            'Address', Icons.location_on_outlined, Colors.red.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.addressFieldKey,
                          controller: controller.addressController,
                          inputFormatters: controller.employeeAddressInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.employeeAddressValidator,
                          decoration: _fieldDecoration('Enter address'),
                        ),

                        const SizedBox(height: 16),
                        _buildFieldLabel(
                            'Role / Designation', Icons.badge_outlined, Colors.purple.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.roleFieldKey,
                          controller: controller.roleController,
                          inputFormatters: controller.employeeRoleInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.employeeRoleValidator,
                          decoration: _fieldDecoration('Enter role / designation'),
                        ),

                        const SizedBox(height: 16),
                        _buildFieldLabel(
                            'Salary', Icons.payments_outlined, Colors.teal.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.salaryFieldKey,
                          controller: controller.salaryController,
                          inputFormatters: controller.employeeSalaryInputFormatters,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: controller.employeeSalaryValidator,
                          decoration: _fieldDecoration('Enter salary'),
                        ),

                        const SizedBox(height: 16),
                        _buildFieldLabel(
                            'Status', Icons.toggle_on_outlined, Colors.blueGrey.shade600),
                        const SizedBox(height: 8),
                        Obx(() => CustomSearchDropdown(
                              height: 50,
                              horizontalPadding: 12,
                              verticalPadding: 15,
                              iconSize: 25,
                              hintText: 'Select Status',
                              items: const <String>['Active', 'Inactive'],
                              selectedItem: controller.status.value == 'active'
                                  ? 'Active'
                                  : 'Inactive',
                              onChanged: (value) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                controller.status.value =
                                    (value ?? 'Active').toLowerCase();
                              },
                            )),
                      ]),

                      const SizedBox(height: 20),

                      // ─── Optional Details ──────────────────
                      _buildSectionLabel('Optional Details', Icons.notes_rounded),
                      const SizedBox(height: 10),
                      _buildFormCard(<Widget>[
                        _buildFieldLabel(
                            'Notes', Icons.notes_rounded, Colors.blueGrey.shade500),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.notesFieldKey,
                          controller: controller.notesController,
                          inputFormatters: controller.employeeNotesInputFormatters,
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                          validator: controller.employeeNotesValidator,
                          decoration: _fieldDecoration('Add notes (optional)'),
                        ),
                      ]),

                      const SizedBox(height: 30),

                      // ─── Submit Button ─────────────────────
                      Obx(() => DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _gradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: const Color(0xFF1565C0).withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : controller.submitEmployeeAndClose,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: controller.isSubmitting.value
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
                                          ? 'Update Employee'
                                          : 'Create Employee',
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

  Widget _buildGradientHeader(double topPad) {
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
                controller.isEdit ? 'Update Employee' : 'Create Employee',
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
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }
}
