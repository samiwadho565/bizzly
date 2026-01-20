import 'package:bizly/views/team_screen/team_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_search_field.dart';
import 'create_team_member.dart';

class TeamEmployeesScreen extends StatefulWidget {
  const TeamEmployeesScreen({super.key});

  @override
  State<TeamEmployeesScreen> createState() => _TeamEmployeesScreenState();
}

class _TeamEmployeesScreenState extends State<TeamEmployeesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> employees = [
 {
    "name": "Ahmed Khan",
    "role": "Sales Manager",
    "phone": "+92 300 1234567",
    "email": "ahmed@bizly.com",
    "address": "Karachi, Pakistan",
    "tasks": ["Lead follow-up", "Monthly report", "Client meeting"],
    "joinDate": "01-01-2024",
    "salary": "150,000 PKR",
    "status": "Active",
    "notes": "Top performer",
  },

    {
      "name": "Sara Ali",
      "role": "Accountant",
      "phone": "+92 301 9876543",
      "email": "sara@bizly.com",
      "status": "Active",
      "tasks": ["Lead follow-up", "Monthly report", "Client meeting"],
      "joinDate": "01-01-2024",
      "salary": "150,000 PKR",
      // "status": "Active",
      "notes": "Top performer",
    },
    {
      "name": "Usman Raza",
      "role": "Technician",
      "phone": "+92 302 5544332",
      "email": "usman@bizly.com",
      "status": "Inactive",
      "tasks": ["Lead follow-up", "Monthly report", "Client meeting"],
      "joinDate": "01-01-2024",
      "salary": "150,000 PKR",
      // "status": "Active",
      "notes": "Top performer",
    },
  ];

  List<Map<String, dynamic>> filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    filteredEmployees = employees;
  }

  void _filterEmployees(String query) {
    setState(() {
      filteredEmployees = employees.where((e) {
        return e["name"].toLowerCase().contains(query.toLowerCase()) ||
            e["role"].toLowerCase().contains(query.toLowerCase()) ||
            e["phone"].contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          /// 🔹 Header + Search (same as Vendor)
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
                    controller: _searchController,
                    onChanged: _filterEmployees,
                    onClear: () => _filterEmployees(""),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 Employee List
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(child: Text("No employees found"))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                return _employeeCard(filteredEmployees[index]);
              },
            ),
          ),
        ],
      ),

      /// 🔹 Add Employee Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.to(()=>AddEmployeeScreen());
          // TODO: Navigate to AddEmployeeScreen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🔹 Employee Card (Enhanced)
  Widget _employeeCard(Map<String, dynamic> employee) {
    final bool isActive = employee["status"] == "Active";

    return GestureDetector(
      onTap: (){
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
            /// Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                employee["name"][0],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            /// Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee["role"],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee["phone"],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            /// Status Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                employee["status"],
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
