import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/chart_of_accounts/controllers/coa_controller.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/utils/app_colors.dart';

class CreateCoaScreen extends GetView<CoaController> {
  const CreateCoaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            GradientScreenHeader(
              title: controller.isEdit ? 'Update Account' : 'New Account',
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Form(
                    key: controller.formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Details',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                      // ── Parent Account (create only) ──────────
                      if (!controller.isEdit) ...[
                        const Text(
                          'Parent Account',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final CoaModel? selected =
                              controller.selectedParent.value;
                          final String err = controller.parentError.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _showParentPicker(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 15),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: err.isNotEmpty
                                          ? Colors.red
                                          : Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    color: AppColors.textField,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selected != null
                                              ? '${selected.accountCode}  ${selected.accountName}'
                                              : 'Select parent account (L2)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: selected == null
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down,
                                          color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              if (err.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6, left: 4),
                                  child: Text(
                                    err,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                ),
                            ],
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // ── Account Name ──────────────────────────
                      const Text(
                        'Account Name',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: 'Enter account name',
                        controller: controller.nameController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                              CoaController.nameMax),
                        ],
                        textInputAction: TextInputAction.done,
                        validator: controller.nameValidator,
                        verticalPadding: 15,
                      ),
                      const SizedBox(height: 32),

                          // ── Submit ────────────────────────────────
                          Obx(() => CustomButton(
                                text: controller.isEdit
                                    ? 'Update Account'
                                    : 'Create Account',
                                isLoading: controller.isSubmitting.value,
                                onPressed: controller.isSubmitting.value
                                    ? () {}
                                    : controller.submitForm,
                              )),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParentPicker(BuildContext context) async {
    await controller.fetchL2Accounts();
    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Parent Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      splashRadius: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Obx(() {
                  if (controller.isLoadingL2.value) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final List<CoaModel> l2 = controller.l2Accounts;
                  if (l2.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No parent accounts found')),
                    );
                  }
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: l2.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final CoaModel account = l2[i];
                        final bool isSelected =
                            controller.selectedParent.value?.id ==
                                account.id;
                        return ListTile(
                          onTap: () {
                            controller.selectedParent.value = account;
                            controller.parentError.value = '';
                            Navigator.of(context).pop();
                          },
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            account.accountName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            account.accountCode,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.primary)
                              : null,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
