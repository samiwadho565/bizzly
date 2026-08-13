import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/chart_of_accounts/controllers/coa_controller.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/modules/chart_of_accounts/screens/create_coa_screen.dart';
import 'package:bizly/modules/chart_of_accounts/screens/coa_detail_screen.dart';
import 'package:bizly/utils/app_colors.dart';

class ChartOfAccountsScreen extends GetView<CoaController> {
  const ChartOfAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          GradientScreenHeader(
            title: 'Chart of Accounts',
            actions: [
              _StatusFilterButton(controller: controller),
            ],
            bottom: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: CustomSearchField(
                hintText: 'Search accounts...',
                controller: controller.searchController,
                onChanged: (v) => controller.searchQuery.value = v,
                isDark: true,
                onClear: () {
                  controller.searchController.clear();
                  controller.searchQuery.value = '';
                },
              ),
            ),
          ),

          // ── Nature Chips ─────────────────────────────────────
          const _NatureChips(),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: FinancePulseLoader());
              }
              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.error.value,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: controller.fetchAccounts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final List<CoaModel> l1List = controller.filteredL1;
              if (l1List.isEmpty) {
                return const Center(child: Text('No accounts found'));
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchAccounts,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: l1List.length,
                  itemBuilder: (_, i) => _L1Section(
                    l1: l1List[i],
                    controller: controller,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          controller.prepareCreate();
          final bool? created = await Get.to(() => const CreateCoaScreen());
          if (created == true) controller.fetchAccounts();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ── L1 Section ──────────────────────────────────────────────────
class _L1Section extends StatelessWidget {
  const _L1Section({required this.l1, required this.controller});
  final CoaModel l1;
  final CoaController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // L1 Header
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryDense.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _natureColor(l1.nature),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l1.accountName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDense,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _natureColor(l1.nature).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l1.nature.capitalize!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _natureColor(l1.nature),
                  ),
                ),
              ),
            ],
          ),
        ),

        // L2 children
        ...l1.children.map((l2) => _L2Group(
              l2: l2,
              controller: controller,
            )),

        const SizedBox(height: 12),
      ],
    );
  }
}

// ── L2 Group (expandable) ───────────────────────────────────────
class _L2Group extends StatelessWidget {
  const _L2Group({required this.l2, required this.controller});
  final CoaModel l2;
  final CoaController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded = controller.expandedL2.contains(l2.id);
      return Column(
        children: [
          // L2 row
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => controller.toggleL2(l2.id),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_right,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${l2.accountCode}  ${l2.accountName}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  if (l2.children.isNotEmpty)
                    Text(
                      '${l2.children.length}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
          ),

          // L3 items (animated)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: l2.children
                  .map((l3) => _L3Tile(l3: l3))
                  .toList(),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}

// ── L3 Tile (tappable) — matches the account-picker card style used
// in the Ledger module, so the same account visual language is used
// app-wide. ─────────────────────────────────────────────────────
class _L3Tile extends StatelessWidget {
  const _L3Tile({required this.l3});
  final CoaModel l3;

  @override
  Widget build(BuildContext context) {
    final List<Color> grad = _natureGradient(l3.nature);
    final String initials = l3.accountCode.isNotEmpty
        ? l3.accountCode.substring(0, l3.accountCode.length >= 2 ? 2 : 1)
        : (l3.accountName.isNotEmpty ? l3.accountName[0] : '?');

    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 12, top: 4, bottom: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            // Set reactive account so detail screen reflects live updates
            Get.find<CoaController>().currentDetailAccount.value = l3;
            Get.to(() => CoaDetailScreen(account: l3));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: l3.isActive ? grad : [Colors.grey.shade400, Colors.grey.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l3.accountName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            l3.accountCode,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          if (!l3.isGlobal) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.person_outline, size: 12, color: Colors.grey.shade400),
                          ],
                          if (!l3.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Inactive',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status Filter (active/inactive/all) ──────────────────────────
class _StatusFilterButton extends StatelessWidget {
  const _StatusFilterButton({required this.controller});
  final CoaController controller;

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _StatusFilterSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool active = controller.selectedStatus.value != 'active';
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(
              active ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            onPressed: () => _open(context),
          ),
          if (active)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    });
  }
}

// ── Status Filter Bottom Sheet ────────────────────────────────────
class _StatusFilterSheet extends StatefulWidget {
  const _StatusFilterSheet({required this.controller});
  final CoaController controller;

  @override
  State<_StatusFilterSheet> createState() => _StatusFilterSheetState();
}

class _StatusFilterSheetState extends State<_StatusFilterSheet> {
  late String _status;

  static const List<_StatusOption> _options = [
    _StatusOption(key: 'active',   label: 'Active',   icon: Icons.check_circle_rounded, color: Color(0xFF2E7D32), gradientEnd: Color(0xFF43A047)),
    _StatusOption(key: 'inactive', label: 'Inactive', icon: Icons.block_rounded,        color: Color(0xFF78909C), gradientEnd: Color(0xFF455A64)),
    _StatusOption(key: 'all',      label: 'All',      icon: Icons.grid_view_rounded,    color: Color(0xFF5C6BC0), gradientEnd: Color(0xFF3949AB)),
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.controller.selectedStatus.value;
  }

  void _apply() {
    widget.controller.selectedStatus.value = _status;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ─────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.filter_alt_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Status',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                      ),
                      Text(
                        'Show active, inactive, or all accounts',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: Colors.grey.shade100),
          const SizedBox(height: 20),

          // ── Segmented options ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: _options.map((o) {
                final bool sel = _status == o.key;
                return GestureDetector(
                  onTap: () => setState(() => _status = o.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: sel
                          ? LinearGradient(
                              colors: [o.color, o.gradientEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: sel ? null : o.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel ? Colors.transparent : o.color.withOpacity(0.18),
                      ),
                      boxShadow: sel
                          ? [BoxShadow(color: o.gradientEnd.withOpacity(0.32), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: sel ? Colors.white.withOpacity(0.20) : o.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(o.icon, size: 16, color: sel ? Colors.white : o.color),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          o.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        if (sel)
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Apply button ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: _apply,
              child: Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0D47A1).withOpacity(0.32), blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Apply',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  const _StatusOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.gradientEnd,
  });
}

// ── Nature Chips ────────────────────────────────────────────────
class _NatureChips extends GetView<CoaController> {
  const _NatureChips();

  static const List<_NatureItem> _natures = [
    _NatureItem(key: 'all',       label: 'All',       icon: Icons.grid_view_rounded,        color: Color(0xFF5C6BC0), gradientEnd: Color(0xFF3949AB)),
    _NatureItem(key: 'asset',     label: 'Asset',     icon: Icons.account_balance_rounded,  color: Color(0xFF1976D2), gradientEnd: Color(0xFF0D47A1)),
    _NatureItem(key: 'liability', label: 'Liability', icon: Icons.trending_down_rounded,    color: Color(0xFFE53935), gradientEnd: Color(0xFFB71C1C)),
    _NatureItem(key: 'equity',    label: 'Equity',    icon: Icons.pie_chart_rounded,        color: Color(0xFF8E24AA), gradientEnd: Color(0xFF4A148C)),
    _NatureItem(key: 'income',    label: 'Income',    icon: Icons.trending_up_rounded,      color: Color(0xFF43A047), gradientEnd: Color(0xFF1B5E20)),
    _NatureItem(key: 'expense',   label: 'Expense',   icon: Icons.receipt_long_rounded,     color: Color(0xFFF57C00), gradientEnd: Color(0xFFE65100)),
    _NatureItem(key: 'contra',    label: 'Contra',    icon: Icons.swap_horiz_rounded,       color: Color(0xFF6D4C41), gradientEnd: Color(0xFF3E2723)),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String selected = controller.selectedNature.value;
      return Container(
        color: Colors.white,
        child: SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            itemCount: _natures.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final _NatureItem item = _natures[i];
              final bool isSelected = selected == item.key;
              return GestureDetector(
                onTap: () => controller.selectedNature.value = item.key,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [item.color, item.gradientEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : item.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [BoxShadow(color: item.gradientEnd.withOpacity(0.38), blurRadius: 10, offset: const Offset(0, 4))]
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
                              : item.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 12,
                          color: isSelected ? Colors.white : item.color,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : item.color,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _NatureItem {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  const _NatureItem({required this.key, required this.label, required this.icon, required this.color, required this.gradientEnd});
}

// ── Helpers ─────────────────────────────────────────────────────
List<Color> _natureGradient(String nature) {
  switch (nature.toLowerCase().trim()) {
    case 'asset':
      return const [Color(0xFF1976D2), Color(0xFF0D47A1)];
    case 'liability':
      return const [Color(0xFFE53935), Color(0xFFB71C1C)];
    case 'equity':
    case 'capital':
      return const [Color(0xFF8E24AA), Color(0xFF4A148C)];
    case 'income':
    case 'revenue':
      return const [Color(0xFF43A047), Color(0xFF1B5E20)];
    case 'expense':
      return const [Color(0xFFF57C00), Color(0xFFE65100)];
    case 'contra':
      return const [Color(0xFF6D4C41), Color(0xFF3E2723)];
    default:
      return const [Color(0xFF5C6BC0), Color(0xFF3949AB)];
  }
}

Color _natureColor(String nature) {
  switch (nature.toLowerCase().trim()) {
    case 'asset':
      return const Color(0xFF1976D2);
    case 'liability':
      return const Color(0xFFE53935);
    case 'equity':
    case 'capital':
      return const Color(0xFF7B1FA2);
    case 'income':
    case 'revenue':
      return const Color(0xFF388E3C);
    case 'expense':
      return const Color(0xFFF57C00);
    case 'contra':
      return const Color(0xFF6D4C41);
    default:
      return Colors.grey;
  }
}
