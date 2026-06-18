import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/team/controllers/team_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import '../../../../assets/images.dart';
import 'create_team_member.dart';

class EmployeeDetailScreen extends GetView<TeamController> {
  EmployeeDetailScreen({super.key, required EmployeeModel employee})
      : currentEmployee = employee.obs;

  final Rx<EmployeeModel> currentEmployee;

  @override
  TeamController get controller => Get.isRegistered<TeamController>()
      ? Get.find<TeamController>()
      : Get.put(TeamController());

  static const LinearGradient _gradient = LinearGradient(
    colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
    final double bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final EmployeeModel employee = currentEmployee.value;
        final bool isActive = employee.status.toLowerCase() == 'active';

        return Column(
          children: <Widget>[
            // ── Fixed Gradient Hero ─────────────────────────
            _buildHero(employee, isActive, topPad),

            // ── Scrollable Content ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    // Contact info
                    _infoGroup(<_InfoRow>[
                      _InfoRow(
                        icon: Icons.phone_rounded,
                        label: 'Phone Number',
                        value: employee.phoneNumber,
                        color: Colors.green.shade700,
                      ),
                      _InfoRow(
                        icon: Icons.email_rounded,
                        label: 'Email',
                        value: employee.email,
                        color: Colors.orange.shade700,
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // Work info
                    _infoGroup(<_InfoRow>[
                      _InfoRow(
                        icon: Icons.badge_rounded,
                        label: 'Role / Designation',
                        value: employee.role,
                        color: Colors.purple.shade700,
                      ),
                      _InfoRow(
                        icon: Icons.payments_rounded,
                        label: 'Salary',
                        value: employee.salary?.toString() ?? '-',
                        color: Colors.teal.shade700,
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // Address
                    _infoGroup(<_InfoRow>[
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Address',
                        value: employee.address,
                        color: Colors.red.shade600,
                      ),
                    ]),

                    // Notes
                    if ((employee.notes ?? '').trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      _infoGroup(<_InfoRow>[
                        _InfoRow(
                          icon: Icons.notes_rounded,
                          label: 'Notes',
                          value: employee.notes!,
                          color: Colors.blueGrey.shade600,
                        ),
                      ]),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Fixed Bottom Action Bar ─────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  // Edit (gradient)
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
                        onPressed: () async {
                          final dynamic result = await Get.to(
                            () => AddEmployeeScreen(),
                            arguments: currentEmployee.value,
                          );
                          if (result is EmployeeModel) {
                            currentEmployee.value = result;
                            controller.fetchEmployees();
                          }
                        },
                        icon: const Icon(Icons.edit_rounded,
                            size: 17, color: Colors.white),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete (red outline)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppDialogs.showActionDialog(
                          iconPath: AppImages.dialogTrash,
                          title: 'Delete Employee!',
                          message:
                              'Are you sure you want to delete ${currentEmployee.value.fullName}?',
                          actions: <AppDialogAction>[
                            AppDialogAction(
                              label: 'Delete Employee',
                              textColor: Colors.red,
                              onPressed: () async {
                                await controller
                                    .deleteEmployee(currentEmployee.value);
                                Get.back();
                              },
                            ),
                            AppDialogAction(label: 'Cancel'),
                          ],
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 17),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHero(EmployeeModel employee, bool isActive, double topPad) {
    final String rawName = employee.fullName.trim();
    final String letter = rawName.isNotEmpty ? rawName[0].toUpperCase() : 'T';

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: const BoxDecoration(gradient: _gradient),
      child: Stack(
        children: <Widget>[
          // Decorative circles
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Back button row
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
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.25)
                          : Colors.red.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? Colors.green.withOpacity(0.50)
                            : Colors.red.withOpacity(0.50),
                      ),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Avatar + info
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    child: Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          employee.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Icon(Icons.badge_rounded,
                                color: Colors.white.withOpacity(0.70),
                                size: 13),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                employee.role,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.80),
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: <Widget>[
                            Icon(Icons.email_rounded,
                                color: Colors.white.withOpacity(0.70),
                                size: 13),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                employee.email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
        children: List<Widget>.generate(rows.length, (i) {
          final _InfoRow row = rows[i];
          return Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: row.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(row.icon, color: row.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            row.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            row.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: row.valueColor ?? AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade100,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
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
