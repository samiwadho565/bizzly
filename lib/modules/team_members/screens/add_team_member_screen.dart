import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/team_members/controllers/team_members_controller.dart';
import 'package:bizly/utils/app_colors.dart';

class AddTeamMemberScreen extends StatelessWidget {
  AddTeamMemberScreen({super.key});

  final TeamMembersController controller =
      Get.isRegistered<TeamMembersController>()
          ? Get.find<TeamMembersController>()
          : Get.put(TeamMembersController());

  static const List<Map<String, String>> _roles = [
    {'value': 'accountant',       'label': 'Accountant',       'sub': 'Create & submit vouchers'},
    {'value': 'approver',         'label': 'Approver',         'sub': 'Review & approve entries'},
    {'value': 'accounting_admin', 'label': 'Accounting Admin', 'sub': 'Full accounting access'},
    {'value': 'viewer_auditor',   'label': 'Viewer / Auditor', 'sub': 'Read-only access'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildGradientHeader(context),
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
                      const SizedBox(height: 28),

                      // ── Business ─────────────────────────────────
                      Obx(() => controller.isEdit
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel(
                                  'Business',
                                  Icons.business_rounded,
                                  const Color(0xFF1565C0),
                                ),
                                const SizedBox(height: 12),
                                _buildFormCard([
                                  _buildFieldLabel(
                                    'Select Business',
                                    Icons.domain_rounded,
                                    const Color(0xFF1565C0),
                                  ),
                                  const SizedBox(height: 8),
                                  _BusinessDropdown(controller: controller),
                                ]),
                                const SizedBox(height: 24),
                              ],
                            )),

                      // ── User Details ──────────────────────────────
                      _buildSectionLabel(
                        'User Details',
                        Icons.person_outline_rounded,
                        const Color(0xFF00897B),
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard([
                        _buildFieldLabel(
                          'Full Name',
                          Icons.badge_outlined,
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          key: controller.nameFieldKey,
                          hintText: 'Ahmed Ali',
                          verticalPadding: 13,
                          controller: controller.nameController,
                          inputFormatters: controller.nameFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.nameValidator,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Email Address',
                          Icons.email_outlined,
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          key: controller.emailFieldKey,
                          hintText: 'ahmed@company.com',
                          verticalPadding: 13,
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: controller.emailFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.emailValidator,
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel(
                          'Phone Number',
                          Icons.phone_outlined,
                          const Color(0xFFE53935),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          key: controller.phoneFieldKey,
                          hintText: '03XX XXXXXXX',
                          verticalPadding: 13,
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: controller.phoneFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.phoneValidator,
                        ),
                        // Password — create only
                        Obx(() => controller.isEdit
                            ? const SizedBox.shrink()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  _buildFieldLabel(
                                    'Password',
                                    Icons.lock_outline_rounded,
                                    const Color(0xFF8E24AA),
                                  ),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    key: controller.passwordFieldKey,
                                    hintText: 'Min. 6 characters',
                                    verticalPadding: 13,
                                    controller: controller.passwordController,
                                    isPassword: true,
                                    inputFormatters: controller.passwordFormatters,
                                    textInputAction: TextInputAction.next,
                                    validator: controller.passwordValidator,
                                  ),
                                ],
                              )),
                        const SizedBox(height: 4),
                      ]),

                      const SizedBox(height: 24),

                      // ── Role ──────────────────────────────────────
                      _buildSectionLabel(
                        'Accounting Role',
                        Icons.shield_outlined,
                        const Color(0xFF8E24AA),
                      ),
                      const SizedBox(height: 12),
                      _buildFormCard([
                        _buildFieldLabel(
                          'Select Role',
                          Icons.admin_panel_settings_outlined,
                          const Color(0xFF8E24AA),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => _RoleDropdown(
                              roles: _roles,
                              selected: controller.accountingRole.value,
                              onChanged: (v) =>
                                  controller.accountingRole.value = v,
                            )),
                        const SizedBox(height: 4),
                      ]),

                      // ── Settings (create only) ────────────────────
                      Obx(() => controller.isEdit
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                _buildSectionLabel(
                                  'Settings',
                                  Icons.tune_rounded,
                                  const Color(0xFF00897B),
                                ),
                                const SizedBox(height: 12),
                                _buildFormCard([
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00897B)
                                              .withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.person_add_outlined,
                                          size: 15,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Create Employee Record',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF374151),
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Also add this user as an HR employee',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Obx(() => Switch.adaptive(
                                            value: controller
                                                .createEmployeeRecord.value,
                                            onChanged: (v) => controller
                                                .createEmployeeRecord.value = v,
                                            activeColor: const Color(0xFF1565C0),
                                          )),
                                    ],
                                  ),
                                ]),
                              ],
                            )),

                      const SizedBox(height: 32),

                      // ── Submit ────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Obx(() => SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: controller.isSubmitting.value
                                      ? null
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF1565C0),
                                            Color(0xFF0A2472),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  color: controller.isSubmitting.value
                                      ? Colors.grey.shade300
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: controller.isSubmitting.value
                                      ? []
                                      : [
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
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : controller.submitAndClose,
                                  child: controller.isSubmitting.value
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
                                              ? 'Update Member'
                                              : 'Add Member',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            )),
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

  // ── Gradient Header ───────────────────────────────────────────────
  Widget _buildGradientHeader(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0A2472)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Obx(() => Text(
                      controller.isEdit ? 'Edit Team Member' : 'Add Team Member',
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

  // ── Section label ─────────────────────────────────────────────────
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

  // ── Form card ─────────────────────────────────────────────────────
  Widget _buildFormCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
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

  // ── Field label ───────────────────────────────────────────────────
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
}

// ── Business Dropdown ─────────────────────────────────────────────
class _BusinessDropdown extends StatelessWidget {
  const _BusinessDropdown({required this.controller});
  final TeamMembersController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<BusinessModel> businesses = controller.businesses;
      final bool hasError = controller.businessError.value.isNotEmpty;

      return Column(
        key: controller.businessFieldKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.textField,
              borderRadius: BorderRadius.circular(15),
              border: hasError
                  ? Border.all(color: Colors.red, width: 1)
                  : null,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BusinessModel>(
                value: controller.selectedBusiness.value,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    'Select a business',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14),
                  ),
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey, size: 20),
                ),
                padding: const EdgeInsets.only(left: 14),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(15),
                elevation: 3,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500),
                items: businesses
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b.businessName),
                        ))
                    .toList(),
                onChanged: (b) {
                  if (b != null) {
                    controller.selectedBusiness.value = b;
                    controller.businessError.value = '';
                  }
                },
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                controller.businessError.value,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      );
    });
  }
}

// ── Role Dropdown ─────────────────────────────────────────────────
class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({
    required this.roles,
    required this.selected,
    required this.onChanged,
  });

  final List<Map<String, String>> roles;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textField,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey, size: 20),
          ),
          padding: const EdgeInsets.only(left: 14),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(15),
          elevation: 3,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500),
          items: roles
              .map((r) => DropdownMenuItem<String>(
                    value: r['value'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(r['label']!,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        Text(r['sub']!,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ))
              .toList(),
          selectedItemBuilder: (_) => roles
              .map((r) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(r['label']!,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
