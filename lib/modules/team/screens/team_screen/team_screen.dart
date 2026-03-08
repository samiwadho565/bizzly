import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_search_field.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryDense,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const CustomAppBar2(
                  title: "Team / Employees",
                  backgroundColor: AppColors.primaryDense,
                  textColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomSearchField(
                    hintText: "Search employee...",
                    controller: controller.searchController,
                    onChanged: (value) => controller.query.value = value,
                    onClear: () => controller.query.value = '',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: FinancePulseLoader());
              }
              if (controller.error.value.isNotEmpty) {
                return Center(child: Text(controller.error.value));
              }
              if (controller.filteredEmployees.isEmpty) {
                return const Center(child: Text("No employees found"));
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchEmployees,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: controller.filteredEmployees.length,
                  itemBuilder: (context, index) {
                    return _employeeCard(controller.filteredEmployees[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final dynamic result = await Get.to(() =>  AddEmployeeScreen());
          if (result is EmployeeModel) {
            controller.fetchEmployees();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _employeeCard(EmployeeModel employee) {
    final bool isActive = employee.status.toLowerCase() == "active";
    return GestureDetector(
      onTap: () {
        Get.to(() => EmployeeDetailScreen(employee: employee));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                employee.fullName.isEmpty ? "-" : employee.fullName[0],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.role,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.phoneNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? "Active" : "Inactive",
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
