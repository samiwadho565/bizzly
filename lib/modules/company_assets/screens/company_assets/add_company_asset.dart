import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/company_assets/controllers/company_assets_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/date_formats.dart';

class AddAssetScreen extends GetView<CompanyAssetsController> {
  AddAssetScreen({super.key}) {
    controller.openAddAssetForm(Get.arguments);
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
            // ── Gradient Header ────────────────────────────────
            _buildGradientHeader(topPad),

            // ── Scrollable Form ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ── Asset Details Section ──────────────
                      _buildSectionLabel(
                          'Asset Details', Icons.inventory_2_outlined),
                      const SizedBox(height: 10),
                      _buildFormCard(<Widget>[
                        // Asset Name
                        _buildFieldLabel('Asset Name',
                            Icons.label_outline_rounded, Colors.blue.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.assetNameFieldKey,
                          controller: controller.assetNameController,
                          inputFormatters: controller.assetNameInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.assetNameValidator,
                          decoration: _fieldDecoration('Enter asset name'),
                        ),

                        const SizedBox(height: 16),

                        // Asset Type
                        _buildFieldLabel('Asset Type',
                            Icons.category_outlined, Colors.indigo.shade600),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.assetTypeFieldKey,
                          controller: controller.assetTypeController,
                          inputFormatters: controller.assetTypeInputFormatters,
                          textInputAction: TextInputAction.next,
                          validator: controller.assetTypeValidator,
                          decoration: _fieldDecoration('Enter asset type'),
                        ),

                        const SizedBox(height: 16),

                        // Value
                        _buildFieldLabel('Value (PKR)',
                            Icons.payments_outlined, Colors.teal.shade700),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: controller.valueFieldKey,
                          controller: controller.valueController,
                          inputFormatters: controller.assetValueInputFormatters,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          validator: controller.assetValueValidator,
                          decoration: _fieldDecoration('Enter asset value'),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── Assignment Section ─────────────────
                      _buildSectionLabel(
                          'Assignment & Date', Icons.assignment_outlined),
                      const SizedBox(height: 10),
                      _buildFormCard(<Widget>[
                        // Assigned To
                        _buildFieldLabel('Assigned To',
                            Icons.person_outline, Colors.purple.shade700),
                        const SizedBox(height: 8),
                        Container(
                          key: controller.assignedToFieldKey,
                          child: Obx(() {
                            final List<String> names = controller.employees
                                .map((EmployeeModel e) => e.fullName)
                                .where((String e) => e.isNotEmpty)
                                .toList();
                            String? selectedName;
                            if (controller.selectedEmployeeId.value != null) {
                              for (final EmployeeModel emp
                                  in controller.employees) {
                                if (emp.id ==
                                    controller.selectedEmployeeId.value) {
                                  selectedName = emp.fullName;
                                  break;
                                }
                              }
                            }
                            return CustomSearchDropdown(
                              hintText: controller.isEmployeesLoading.value
                                  ? 'Loading employees...'
                                  : 'Select employee',
                              items: names,
                              selectedItem: selectedName,
                              height: 50,
                              horizontalPadding: 12,
                              verticalPadding: 15,
                              iconSize: 22,
                              enableSearch: true,
                              onChanged: (String? value) {
                                int? id;
                                for (final EmployeeModel emp
                                    in controller.employees) {
                                  if (emp.fullName == value) {
                                    id = emp.id;
                                    break;
                                  }
                                }
                                controller.selectedEmployeeId.value = id;
                              },
                            );
                          }),
                        ),
                        Obx(() => controller.showFieldErrors.value &&
                                controller.selectedEmployeeId.value == null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  'Assigned To is required',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error),
                                ),
                              )
                            : const SizedBox.shrink()),

                        const SizedBox(height: 16),

                        // Purchase Date
                        _buildFieldLabel('Purchase Date',
                            Icons.calendar_today_outlined,
                            Colors.orange.shade700),
                        const SizedBox(height: 8),
                        Obx(() {
                          final bool hasDate =
                              controller.selectedPurchaseDate.value != null;
                          final bool showError =
                              controller.showFieldErrors.value && !hasDate;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                key: controller.purchaseDateFieldKey,
                                onTap: () async {
                                  final DateTime? date =
                                      await AppUtils.pickDate();
                                  if (date == null) return;
                                  controller.selectedPurchaseDate.value = date;
                                  controller.purchaseDateController.text =
                                      DateFormats.yyyyMmDd(date);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color: showError
                                          ? Colors.red
                                          : Colors.grey.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          controller.purchaseDateController
                                                  .text.isNotEmpty
                                              ? controller
                                                  .purchaseDateController.text
                                              : 'Select purchase date',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: controller
                                                    .purchaseDateController
                                                    .text
                                                    .isNotEmpty
                                                ? AppColors.textPrimary
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      Image.asset(
                                        AppImages.calendar,
                                        width: 16,
                                        height: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (showError)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6, left: 4),
                                  child: Text(
                                    'Purchase Date is required',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ]),

                      const SizedBox(height: 30),

                      // ── Submit Button ──────────────────────
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
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : controller.submitAssetFromForm,
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
                                          ? 'Update Asset'
                                          : 'Add Asset',
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
              Obx(() => Text(
                    controller.isEdit ? 'Update Asset' : 'Add Asset',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  )),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }
}
