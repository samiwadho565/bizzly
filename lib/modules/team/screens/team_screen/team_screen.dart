import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/team/controllers/team_controller.dart';
import 'package:bizly/modules/team/models/employee_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'create_team_member.dart';
import 'team_detail_screen.dart';

class TeamEmployeesScreen extends StatelessWidget {
  TeamEmployeesScreen({super.key});

  final TeamController controller = Get.isRegistered<TeamController>()
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: <Widget>[
            // ── Fixed Gradient Header ───────────────────────────
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
                            'Team',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Text(
                                '${controller.filteredEmployees.length} members',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: (v) => controller.query.value = v,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search team members...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                            suffixIcon: controller
                                    .searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      controller.searchController.clear();
                                      controller.query.value = '';
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 18,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────
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
                  onRefresh: controller.fetchEmployees,
                  child: controller.filteredEmployees.isEmpty
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
                                      Icons.group_outlined,
                                      size: 40,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No team members found',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap + to add your first member',
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
                          itemCount: controller.filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final List<EmployeeModel> list =
                                controller.filteredEmployees;
                            if (index >= list.length) {
                              return const SizedBox.shrink();
                            }
                            final EmployeeModel emp = list[index];
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => EmployeeDetailScreen(employee: emp),
                              ),
                              child: _employeeCard(emp),
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────
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
            final dynamic result = await Get.to(() => AddEmployeeScreen());
            if (result is EmployeeModel) {
              controller.fetchEmployees();
            }
          },
          child: const Icon(Icons.person_add_rounded,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _employeeCard(EmployeeModel employee) {
    final String rawName = employee.fullName.trim();
    final String letter = rawName.isNotEmpty ? rawName[0].toUpperCase() : 'T';
    final bool isActive = employee.status.toLowerCase() == 'active';

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
          // Gradient ring initials
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
                  employee.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Icon(Icons.badge_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      employee.role,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
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
                      employee.phoneNumber,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),

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
        ],
      ),
    );
  }
}
