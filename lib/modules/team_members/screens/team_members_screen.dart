import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/team_members/controllers/team_members_controller.dart';
import 'package:bizly/modules/team_members/models/team_member_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'add_team_member_screen.dart';

class TeamMembersScreen extends StatelessWidget {
  TeamMembersScreen({super.key});

  final TeamMembersController controller =
      Get.isRegistered<TeamMembersController>()
          ? Get.find<TeamMembersController>()
          : Get.put(TeamMembersController());

  static const LinearGradient _gradient = LinearGradient(
    colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Role badge colors ────────────────────────────────────────
  static Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'accounting_admin':
        return const Color(0xFF7B1FA2);
      case 'approver':
        return const Color(0xFF0277BD);
      case 'viewer_auditor':
        return const Color(0xFFE65100);
      default: // accountant
        return const Color(0xFF00695C);
    }
  }

  static String _roleLabel(String role, {String? roleName}) {
    // Prefer API-provided human readable name if available
    if (roleName != null && roleName.isNotEmpty) return roleName;
    switch (role.toLowerCase()) {
      case 'accounting_admin':
        return 'Accounting Admin';
      case 'approver':
        return 'Approver';
      case 'viewer_auditor':
        return 'Viewer / Auditor';
      default:
        return 'Accountant';
    }
  }

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
            // ── Gradient Header ────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 18),
              decoration: const BoxDecoration(gradient: _gradient),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (Get.previousRoute.isNotEmpty)
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          const Text(
                            'Team Members',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Text(
                                '${controller.filteredMembers.length} users',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search bar
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Obx(() => TextField(
                              controller: controller.searchController,
                              onChanged: (v) => controller.query.value = v,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search by name, email or role...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 20,
                                ),
                                suffixIcon:
                                    controller.query.value.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              controller.searchController
                                                  .clear();
                                              controller.query.value = '';
                                            },
                                            child: Icon(
                                              Icons.close_rounded,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: FinancePulseLoader());
                }
                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.error.value,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.fetchMembers,
                  child: controller.filteredMembers.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: <Widget>[
                            SizedBox(
                              height: 280,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1565C0)
                                          .withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.manage_accounts_outlined,
                                      size: 40,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No team members yet',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap + to invite the first user',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.filteredMembers.length,
                          itemBuilder: (context, index) {
                            final List<TeamMemberModel> list =
                                controller.filteredMembers;
                            if (index >= list.length) {
                              return const SizedBox.shrink();
                            }
                            final TeamMemberModel member = list[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showMemberBottomSheet(context, member),
                              child: _memberCard(member),
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),

      // ── Gradient FAB ──────────────────────────────────────────
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: _gradient,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.40),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            controller.prepareCreate();
            await Get.to(() => AddTeamMemberScreen());
            controller.fetchMembers();
          },
          child: const Icon(Icons.person_add_rounded,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }

  // ── Member card ───────────────────────────────────────────────
  Widget _memberCard(TeamMemberModel member) {
    final String letter =
        member.name.trim().isNotEmpty ? member.name[0].toUpperCase() : 'U';
    final bool isActive = member.status.toLowerCase() == 'active';
    final Color roleColor = _roleColor(member.accountingRole);
    final String roleLabel = _roleLabel(member.accountingRole, roleName: member.accountingRoleName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: <Widget>[
          // Gradient ring avatar
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradient,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Icon(Icons.email_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        member.email,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(Icons.phone_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      member.phone,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.10)
                      : Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green.shade700 : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet ──────────────────────────────────────────────
  void _showMemberBottomSheet(
      BuildContext context, TeamMemberModel member) {
    final String letter =
        member.name.trim().isNotEmpty ? member.name[0].toUpperCase() : 'U';
    final bool isActive = member.status.toLowerCase() == 'active';
    final Color roleColor = _roleColor(member.accountingRole);
    final String roleLabel = _roleLabel(member.accountingRole, roleName: member.accountingRoleName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.90,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F6FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: <Widget>[
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: _gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            member.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.25)
                            : Colors.red.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info group
              _infoGroup(<_InfoRow>[
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: member.phone,
                  color: const Color(0xFF00695C),
                ),
                _InfoRow(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Role',
                  value: roleLabel,
                  color: roleColor,
                  valueColor: roleColor,
                ),
                _InfoRow(
                  icon: Icons.business_outlined,
                  label: 'Business',
                  value: member.businessName ?? '—',
                  color: const Color(0xFF1565C0),
                ),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Joined',
                  value: member.createdAt != null
                      ? member.createdAt!.split('T').first
                      : '—',
                  color: const Color(0xFFE65100),
                ),
              ]),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: <Widget>[
                  // Edit button (gradient)
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          controller.prepareEdit(member);
                          Get.to(() => AddTeamMemberScreen());
                        },
                        icon: const Icon(Icons.edit_outlined,
                            size: 16, color: Colors.white),
                        label: const Text('Edit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Delete button (red outline)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _confirmDelete(context, member);
                      },
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 16, color: Colors.red),
                      label: const Text('Delete',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Toggle status button
              OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.toggleStatus(member);
                },
                icon: Icon(
                  isActive
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 16,
                  color: isActive ? Colors.orange : Colors.green.shade700,
                ),
                label: Text(
                  isActive ? 'Deactivate' : 'Activate',
                  style: TextStyle(
                    color: isActive ? Colors.orange : Colors.green.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isActive ? Colors.orange : Colors.green.shade700,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TeamMemberModel member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Member',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to delete "${member.name}"? This cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteMember(member);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _infoGroup(List<_InfoRow> rows) {
    return Container(
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
        children: List.generate(rows.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Divider(
                height: 1, thickness: 1, color: Colors.grey.shade100);
          }
          final _InfoRow row = rows[i ~/ 2];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: row.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(row.icon, size: 15, color: row.color),
                ),
                const SizedBox(width: 12),
                Text(
                  row.label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  row.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: row.valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? valueColor;
}
