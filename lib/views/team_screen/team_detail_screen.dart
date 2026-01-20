import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dialouge.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_button.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    bool isActive = employee["status"] == "Active";

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
            child: Column(
              children: [
                /// 🔹 Header (Avatar + Name + Role)
                Padding(
                  padding:
                  const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          employee["name"][0],
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee["name"],
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              employee["role"],
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      /// Vertical menu
                      PopupMenuButton<String>(
                        color: Colors.white,
                        icon: const Icon(Icons.more_vert, size: 28),
                        onSelected: (value) {
                          if (value == 'Edit') {
                            print("Edit employee tapped");
                          } else if (value == 'Delete') {
                            AppDialogs.showConfirmation(
                              title: "Delete Employee",
                              message:
                              "Are you sure you want to delete ${employee["name"]}?",
                              onYes: () {
                                print("${employee["name"]} deleted!");
                                Get.back();
                              },
                              onNo: () => print("Delete cancelled"),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                 Divider(color: Colors.grey.shade200),

                /// 🔹 Scrollable Profile Content
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
                            value: employee["phone"]),
                        _infoCard(
                            icon: Icons.email,
                            title: "Email",
                            value: employee["email"]),
                        _infoCard(
                            icon: Icons.location_on,
                            title: "Address",
                            value: employee["address"] ?? "-"),
                        _infoCard(
                            icon: Icons.badge,
                            title: "Role",
                            value: employee["role"]),
                        _infoCard(
                            icon: Icons.work_outline,
                            title: "Assigned Tasks",
                            value: employee["tasks"]?.join(", ") ?? "-"),
                        _infoCard(
                            icon: Icons.date_range,
                            title: "Join Date",
                            value: employee["joinDate"] ?? "-"),
                        _infoCard(
                            icon: Icons.attach_money,
                            title: "Salary",
                            value: employee["salary"] ?? "-"),
                        _infoCard(
                            icon: Icons.info,
                            title: "Status",
                            value: isActive ? "Active" : "Inactive",
                            valueColor: isActive ? Colors.green : Colors.red),
                        _infoCard(
                            icon: Icons.note,
                            title: "Notes",
                            value: employee["notes"] ?? "-"),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                /// 🔹 Action Buttons
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          color: AppColors.textPrimary,
                          text: "Edit Employee",
                          onPressed: () {
                            // TODO: Navigate to Edit Employee
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: "Assign Task",
                          onPressed: () {
                            // TODO: Navigate to Assign Task screen
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Info Card Widget
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: valueFontWeight,
                        color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
