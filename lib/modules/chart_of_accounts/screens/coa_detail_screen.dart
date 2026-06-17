import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/modules/chart_of_accounts/controllers/coa_controller.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/modules/chart_of_accounts/screens/create_coa_screen.dart';
import 'package:bizly/utils/app_colors.dart';

class CoaDetailScreen extends StatelessWidget {
  const CoaDetailScreen({super.key, required this.account});
  final CoaModel account;

  @override
  Widget build(BuildContext context) {
    final CoaController c = Get.find<CoaController>();
    // Ensure reactive account is set (coa_screen sets it before navigation,
    // but this is a safety fallback)
    if (c.currentDetailAccount.value?.id != account.id) {
      c.currentDetailAccount.value = account;
    }

    return Obx(() {
      final CoaModel current = c.currentDetailAccount.value ?? account;
      final bool loading = c.isTogglingActive.value; // observe toggle state too
      final bool canEdit = current.isEditable;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar2(
          title: 'Account Detail',
          backgroundColor: AppColors.primaryDense,
          textColor: Colors.white,
          actions: canEdit
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () async {
                      c.prepareEdit(current);
                      final bool? updated =
                          await Get.to(() => const CreateCoaScreen());
                      if (updated == true) Get.back();
                    },
                  ),
                ]
              : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Account Card ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            current.accountName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDense,
                            ),
                          ),
                        ),
                        if (!current.isGlobal)
                          Tooltip(
                            message: 'Custom Account',
                            child: Icon(Icons.person_outline,
                                size: 16, color: Colors.grey.shade400),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.accountCode,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),
                    _detailRow('Nature', current.nature.capitalize!),
                    _detailRow('Level', 'Level ${current.level}'),
                    if (current.parentName != null)
                      _detailRow('Parent', current.parentName!),
                    _detailRow(
                      'Status',
                      current.isActive ? 'Active' : 'Inactive',
                      valueColor: current.isActive
                          ? Colors.green.shade600
                          : Colors.grey.shade500,
                    ),
                  ],
                ),
              ),

              if (!canEdit) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a system account and cannot be edited.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.amber.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (canEdit) ...[
                const SizedBox(height: 24),
                Builder(builder: (_) {
                  final bool active = current.isActive;
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: loading ? null : () => c.toggleActive(current),
                      icon: loading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: active ? Colors.red : Colors.green,
                              ),
                            )
                          : Icon(
                              active ? Icons.block_outlined : Icons.check_circle_outline,
                              size: 18,
                              color: active ? Colors.red : Colors.green,
                            ),
                      label: Text(
                        loading
                            ? (active ? 'Deactivating...' : 'Activating...')
                            : (active ? 'Deactivate Account' : 'Activate Account'),
                        style: TextStyle(
                          color: active ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: active ? Colors.red.shade300 : Colors.green.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
