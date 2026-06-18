import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:bizly/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════════
// SHARED: Date Range Chips (Trial Balance & Income Statement)
// ═══════════════════════════════════════════════════════════════

class ReportRangeChip {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  const ReportRangeChip({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.gradientEnd,
  });
}

const List<ReportRangeChip> rangeChips = [
  ReportRangeChip(
    key: 'this_month',
    label: 'This Month',
    icon: Icons.today_rounded,
    color: Color(0xFF00897B),
    gradientEnd: Color(0xFF004D40),
  ),
  ReportRangeChip(
    key: 'last_month',
    label: 'Last Month',
    icon: Icons.history_rounded,
    color: Color(0xFF1E88E5),
    gradientEnd: Color(0xFF0D47A1),
  ),
  ReportRangeChip(
    key: 'this_quarter',
    label: 'This Quarter',
    icon: Icons.date_range_rounded,
    color: Color(0xFF8E24AA),
    gradientEnd: Color(0xFF4A148C),
  ),
  ReportRangeChip(
    key: 'this_year',
    label: 'This Year',
    icon: Icons.calendar_month_rounded,
    color: Color(0xFFFF7043),
    gradientEnd: Color(0xFFBF360C),
  ),
  ReportRangeChip(
    key: 'custom',
    label: 'Custom',
    icon: Icons.tune_rounded,
    color: Color(0xFF546E7A),
    gradientEnd: Color(0xFF263238),
  ),
];

class ReportRangeChips extends StatelessWidget {
  final RxString selectedPreset;
  final void Function(String preset) onPresetSelected;
  final VoidCallback onCustom;

  const ReportRangeChips({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.onCustom,
  });

  void _applyPreset(String preset) {
    if (preset == 'custom') {
      onCustom();
      return;
    }
    onPresetSelected(preset);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox(
        height: 56,
        child: Obx(() {
          final String selected = selectedPreset.value;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: rangeChips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final ReportRangeChip chip = rangeChips[i];
              final bool isSelected = selected == chip.key;
              return GestureDetector(
                onTap: () => _applyPreset(chip.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [chip.color, chip.gradientEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : chip.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: chip.gradientEnd.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.20)
                              : chip.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          chip.icon,
                          size: 12,
                          color: isSelected ? Colors.white : chip.color,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        chip.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : chip.color,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED: Custom Date Range Bottom Sheet
// ═══════════════════════════════════════════════════════════════

class CustomRangeSheet extends StatefulWidget {
  final DateTime initialFrom;
  final DateTime initialTo;
  final void Function(DateTime from, DateTime to) onApply;

  const CustomRangeSheet({
    super.key,
    required this.initialFrom,
    required this.initialTo,
    required this.onApply,
  });

  @override
  State<CustomRangeSheet> createState() => _CustomRangeSheetState();
}

class _CustomRangeSheetState extends State<CustomRangeSheet> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
  }

  Future<void> _pickDate(bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
          if (_to.isBefore(_from)) _to = _from;
        } else {
          _to = picked;
          if (_from.isAfter(_to)) _from = _to;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fromStr = DateFormat('dd MMM yyyy').format(_from);
    final String toStr = DateFormat('dd MMM yyyy').format(_to);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
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
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Custom Date Range',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          DateTile(
            label: 'From',
            dateStr: fromStr,
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF1E88E5),
            onTap: () => _pickDate(true),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_downward_rounded,
                  size: 16, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          DateTile(
            label: 'To',
            dateStr: toStr,
            icon: Icons.event_rounded,
            color: const Color(0xFF00897B),
            onTap: () => _pickDate(false),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                widget.onApply(_from, _to);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Range',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateTile extends StatelessWidget {
  final String label;
  final String dateStr;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DateTile({
    super.key,
    required this.label,
    required this.dateStr,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_calendar_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
