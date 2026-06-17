import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/modules/vouchers/controllers/voucher_controller.dart';
import 'package:bizly/modules/vouchers/models/voucher_model.dart';
import 'package:bizly/utils/app_colors.dart';

class CreateVoucherScreen extends StatefulWidget {
  const CreateVoucherScreen({super.key});

  @override
  State<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends State<CreateVoucherScreen> {
  final VoucherController _c = Get.find<VoucherController>();
  final ScrollController _scroll = ScrollController();

  // Keys for scroll-to-error
  final GlobalKey _narrationKey = GlobalKey();
  final GlobalKey _linesKey = GlobalKey();
  final GlobalKey _balanceKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToFirstError() {
    GlobalKey? targetKey;

    // 1. Narration empty?
    if (_c.narrationController.text.trim().isEmpty) {
      targetKey = _narrationKey;
    }
    // 2. Any line invalid?
    else if (_c.lines.any((l) => !l.isValid)) {
      targetKey = _linesKey;
    }
    // 3. Not balanced?
    else if (!_c.isBalanced) {
      targetKey = _balanceKey;
    }

    if (targetKey == null) return;
    final BuildContext? ctx = targetKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDense,
      appBar: CustomAppBar2(
        title: _c.isEdit ? 'Update Voucher' : 'New Voucher',
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Obx(() {
            if (_c.isLoadingInitial) {
              return const Center(child: FinancePulseLoader());
            }
            return Form(
              key: _c.formKey,
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Voucher Type ──────────────────────────────
                    const _Label('Voucher Type'),
                    const SizedBox(height: 8),
                    Obx(() => _TypeSelector(
                          selected: _c.selectedType.value,
                          onChanged: (v) => _c.selectedType.value = v,
                        )),
                    const SizedBox(height: 16),

                    // ── Date ──────────────────────────────────────
                    const _Label('Voucher Date'),
                    const SizedBox(height: 8),
                    Obx(() => _DatePicker(
                          date: _c.selectedDate.value,
                          onChanged: (d) => _c.selectedDate.value = d,
                        )),
                    const SizedBox(height: 16),

                    // ── Narration ─────────────────────────────────
                    const _Label('Narration *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: _narrationKey,
                      controller: _c.narrationController,
                      maxLines: 2,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Narration is required' : null,
                      decoration: InputDecoration(
                        hintText: 'Enter narration...',
                        filled: true,
                        fillColor: AppColors.textField,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.red, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── CRM Links (Optional) ──────────────────────
                    const _SectionHeader('CRM Links', subtitle: 'Optional'),
                    const SizedBox(height: 10),
                    Obx(() => _CrmPicker(
                          label: 'Business',
                          icon: Icons.business_outlined,
                          selected: _c.selectedBusiness.value,
                          items: _c.businessList,
                          onSelect: (item) => _c.selectedBusiness.value = item,
                          onClear: () => _c.selectedBusiness.value = null,
                        )),
                    const SizedBox(height: 10),
                    Obx(() => _CrmPicker(
                          label: 'Customer',
                          icon: Icons.person_outline,
                          selected: _c.selectedCustomer.value,
                          items: _c.customerList,
                          onSelect: (item) => _c.selectedCustomer.value = item,
                          onClear: () => _c.selectedCustomer.value = null,
                        )),
                    const SizedBox(height: 10),
                    Obx(() => _CrmPicker(
                          label: 'Vendor',
                          icon: Icons.store_outlined,
                          selected: _c.selectedVendor.value,
                          items: _c.vendorList,
                          onSelect: (item) => _c.selectedVendor.value = item,
                          onClear: () => _c.selectedVendor.value = null,
                        )),
                    const SizedBox(height: 24),

                    // ── Lines ─────────────────────────────────────
                    Row(
                      key: _linesKey,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _Label('Journal Lines *'),
                        TextButton.icon(
                          onPressed: _c.addLine,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Line'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Obx(() {
                      return Column(
                        children: List.generate(
                          _c.lines.length,
                          (i) {
                            final DraftLine line = _c.lines[i];
                            return _LineRow(
                              key: ValueKey(line.uid),
                              index: i,
                              line: line,
                              showError: _c.showLineErrors.value,
                              canRemove: _c.lines.length > 2,
                              coaList: _c.coaDropdown,
                              isLoadingCoa: _c.isLoadingCoa.value,
                              disabledAccountIds: const <int>{},
                              onUpdate: (updated) => _c.updateLine(i, updated),
                              onRemove: () => _c.removeLine(i),
                            );
                          },
                        ),
                      );
                    }),

                    // ── Balance indicator ─────────────────────────
                    const SizedBox(height: 12),
                    Obx(() {
                      final double dr = _c.totalDebit;
                      final double cr = _c.totalCredit;
                      final bool balanced = _c.isBalanced;
                      final bool showErr = _c.showLineErrors.value && !balanced;
                      return Column(
                        key: _balanceKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: balanced
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  balanced ? '✓ Balanced' : '✗ Not Balanced',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: balanced
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                Text(
                                  'Dr ${_fmt(dr)}  |  Cr ${_fmt(cr)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          if (showErr) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                'Total debit must equal total credit',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                    const SizedBox(height: 28),

                    // ── Submit ────────────────────────────────────
                    Obx(() => CustomButton(
                          text: _c.isEdit ? 'Update Voucher' : 'Save as Draft',
                          isLoading: _c.isSubmitting.value,
                          onPressed: _c.isSubmitting.value
                              ? () {}
                              : () => _c.submitForm(
                                    onScrollToError: _scrollToFirstError,
                                  ),
                        )),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Type Selector ─────────────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VoucherController.voucherTypes.map((t) {
        final bool isSelected = t == selected;
        return GestureDetector(
          onTap: () => onChanged(t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryDense : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              t.capitalize!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Date Picker ───────────────────────────────────────────────────
class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryDense),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.textField,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('MMM d, yyyy').format(date),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── Line Row ──────────────────────────────────────────────────────
class _LineRow extends StatefulWidget {
  const _LineRow({
    super.key,
    required this.index,
    required this.line,
    required this.showError,
    required this.canRemove,
    required this.coaList,
    required this.isLoadingCoa,
    required this.disabledAccountIds,
    required this.onUpdate,
    required this.onRemove,
  });

  final int index;
  final DraftLine line;
  final bool showError;
  final bool canRemove;
  final List<CoaDropdownItem> coaList;
  final bool isLoadingCoa;
  final Set<int> disabledAccountIds;
  final ValueChanged<DraftLine> onUpdate;
  final VoidCallback onRemove;

  @override
  State<_LineRow> createState() => _LineRowState();
}

class _LineRowState extends State<_LineRow> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.line.amount);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _update({int? accountId, String? accountCode, String? accountName, String? lineType, String? amount}) {
    widget.onUpdate(DraftLine(
      accountId: accountId ?? widget.line.accountId,
      accountCode: accountCode ?? widget.line.accountCode,
      accountName: accountName ?? widget.line.accountName,
      lineType: lineType ?? widget.line.lineType,
      amount: amount ?? widget.line.amount,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool accountMissing =
        widget.showError && widget.line.accountId == null;
    final bool amountMissing =
        widget.showError && widget.line.parsedAmount <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account picker + remove
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showAccountPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accountMissing
                            ? Colors.red
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.line.accountId != null
                                ? '${widget.line.accountCode}  ${widget.line.accountName}'
                                : 'Select account',
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.line.accountId != null
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.canRemove) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Icon(Icons.remove_circle_outline,
                      color: Colors.red, size: 22),
                ),
              ],
            ],
          ),
          if (accountMissing) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Please select an account',
                style: TextStyle(fontSize: 11, color: Colors.red.shade600),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Debit/Credit toggle + Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle
              _Toggle(
                isDebit: widget.line.isDebit,
                onChanged: (isDebit) =>
                    _update(lineType: isDebit ? 'debit' : 'credit'),
              ),
              const SizedBox(width: 12),
              // Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'))
                      ],
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: amountMissing
                                ? Colors.red
                                : Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: amountMissing
                                ? Colors.red
                                : Colors.grey.shade200,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onChanged: (v) => _update(amount: v),
                    ),
                    if (amountMissing) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Amount must be greater than 0',
                          style:
                              TextStyle(fontSize: 11, color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAccountPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
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
                    child: Text('Select Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (widget.isLoadingCoa)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.coaList.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final CoaDropdownItem item = widget.coaList[i];
                      final bool isSelected =
                          widget.line.accountId == item.id;
                      final bool isDisabled =
                          widget.disabledAccountIds.contains(item.id);
                      return ListTile(
                        onTap: isDisabled
                            ? null
                            : () {
                                _update(
                                  accountId: item.id,
                                  accountCode: item.accountCode,
                                  accountName: item.accountName,
                                );
                                Navigator.pop(context);
                              },
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.accountName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDisabled
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          item.accountCode,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : isDisabled
                                ? Icon(Icons.block_outlined,
                                    size: 16,
                                    color: Colors.grey.shade300)
                                : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Debit/Credit Toggle ───────────────────────────────────────────
class _Toggle extends StatelessWidget {
  const _Toggle({required this.isDebit, required this.onChanged});
  final bool isDebit;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(label: 'Dr', active: isDebit, onTap: () => onChanged(true)),
          _Btn(label: 'Cr', active: !isDebit, onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDense : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black));
  }
}

String _fmt(double v) => NumberFormat('#,##0.##').format(v);

// ── Section Header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
        if (subtitle != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(subtitle!,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ),
        ],
      ],
    );
  }
}

// ── CRM Picker ────────────────────────────────────────────────────
class _CrmPicker extends StatelessWidget {
  const _CrmPicker({
    required this.label,
    required this.icon,
    required this.selected,
    required this.items,
    required this.onSelect,
    required this.onClear,
  });

  final String label;
  final IconData icon;
  final CrmDropdownItem? selected;
  final List<CrmDropdownItem> items;
  final ValueChanged<CrmDropdownItem> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected?.name ?? 'Select $label',
                style: TextStyle(
                  fontSize: 14,
                  color: selected != null ? Colors.black87 : Colors.black45,
                ),
              ),
            ),
            if (selected != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
              )
            else
              Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ${label.toLowerCase()}s found')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Select $label',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final CrmDropdownItem item = items[i];
                    final bool isSel = selected?.id == item.id;
                    return ListTile(
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(context);
                      },
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name,
                          style: const TextStyle(fontSize: 14)),
                      trailing: isSel
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
