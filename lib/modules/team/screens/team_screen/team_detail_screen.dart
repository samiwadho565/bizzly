import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDense,
      appBar: const CustomAppBar2(
        title: "Employee Detail",
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Obx(() {
              final EmployeeModel employee = currentEmployee.value;
              final bool isActive = employee.status.toLowerCase() == "active";

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            employee.fullName.isEmpty ? "-" : employee.fullName[0],
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.fullName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                employee.role,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade200),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoCard(
                            icon: Icons.phone,
                            title: "Phone Number",
                            value: employee.phoneNumber,
                          ),
                          _infoCard(
                            icon: Icons.email,
                            title: "Email",
                            value: employee.email,
                          ),
                          _infoCard(
                            icon: Icons.location_on,
                            title: "Address",
                            value: employee.address,
                          ),
                          _infoCard(
                            icon: Icons.badge,
                            title: "Role",
                            value: employee.role,
                          ),
                          _infoCard(
                            icon: Icons.attach_money,
                            title: "Salary",
                            value: employee.salary?.toString() ?? "-",
                          ),
                          _infoCard(
                            icon: Icons.info,
                            title: "Status",
                            value: isActive ? "Active" : "Inactive",
                            valueColor: isActive ? Colors.green : Colors.red,
                          ),
                          _infoCard(
                            icon: Icons.note,
                            title: "Notes",
                            value: employee.notes?.isNotEmpty == true
                                ? employee.notes!
                                : "-",
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            color: AppColors.textPrimary,
                            text: "Edit Employee",
                            onPressed: () async {
                              final dynamic result = await Get.to(
                                () =>  AddEmployeeScreen(),
                                arguments: employee,
                              );
                              if (result is EmployeeModel) {
                                currentEmployee.value = result;
                                controller.fetchEmployees();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: "Delete Employee",
                            color: Colors.white,
                            textColor: Colors.red,
                            borderColor: Colors.red,
                            onPressed: () {
                              AppDialogs.showActionDialog(
                                iconPath: AppImages.dialogTrash,
                                title: "Delete Employee!",
                                message:
                                    "Are you sure you want to delete ${employee.fullName}?",
                                actions: [
                                  AppDialogAction(
                                    label: "Delete Employee",
                                    textColor: Colors.red,
                                    onPressed: () async {
                                      await controller.deleteEmployee(employee);
                                      Get.back();
                                    },
                                  ),
                                  AppDialogAction(label: "Cancel"),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = Colors.black87,
    FontWeight valueFontWeight = FontWeight.w500,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: valueFontWeight,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
