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

// ── L3 Tile (tappable) ──────────────────────────────────────────
class _L3Tile extends StatelessWidget {
  const _L3Tile({required this.l3});
  final CoaModel l3;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        // Set reactive account so detail screen reflects live updates
        Get.find<CoaController>().currentDetailAccount.value = l3;
        Get.to(() => CoaDetailScreen(account: l3));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 48, right: 12, top: 9, bottom: 9),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l3.accountName,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l3.accountCode,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (!l3.isActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade600),
                ),
              ),
            if (!l3.isGlobal)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.person_outline,
                    size: 13, color: Colors.grey.shade400),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
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
Color _natureColor(String nature) {
  switch (nature.toLowerCase()) {
    case 'asset':
      return const Color(0xFF1976D2);
    case 'liability':
      return const Color(0xFFE53935);
    case 'equity':
      return const Color(0xFF7B1FA2);
    case 'income':
      return const Color(0xFF388E3C);
    case 'expense':
      return const Color(0xFFF57C00);
    default:
      return Colors.grey;
  }
}
