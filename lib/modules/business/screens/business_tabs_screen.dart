import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_tab_bar.dart';
import 'package:bizly/modules/business/controllers/business_activity_controller.dart';
import 'package:bizly/modules/expense/controllers/expenses_list_controller.dart';
import 'package:bizly/modules/expense/screens/expense_screen.dart';
import 'package:bizly/modules/invoice/controllers/invoice_screen_controller.dart';
import 'package:bizly/modules/invoice/screens/invoice_screen.dart';
import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:bizly/modules/tasks/screens/tasks_screen.dart';

class BusinessTabsScreen extends StatefulWidget {
  const BusinessTabsScreen({super.key});

  @override
  State<BusinessTabsScreen> createState() => _BusinessTabsScreenState();
}

class _BusinessTabsScreenState extends State<BusinessTabsScreen> {
  late final BusinessActivityController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BusinessActivityController>();
    _syncDashboardScopes();
  }

  void _syncDashboardScopes() {
    final Map<String, dynamic> scopedArgs = <String, dynamic>{
      'businessId': controller.business.value?.id,
      'businessName': controller.business.value?.businessName,
    };
    if (Get.isRegistered<InvoiceScreenController>()) {
      Get.find<InvoiceScreenController>().applyScopeFromArgs(scopedArgs);
    }
    if (Get.isRegistered<ExpensesListController>()) {
      Get.find<ExpensesListController>().applyScopeFromArgs(scopedArgs);
    }
    if (Get.isRegistered<TasksScreenController>()) {
      Get.find<TasksScreenController>().applyScopeFromArgs(scopedArgs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String businessName =
        controller.business.value?.businessName.toString().trim() ?? '';
    final String title = businessName.isNotEmpty
        ? "$businessName Activity"
        : "Business Activity";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar2(
        title: title,
        actions: [
          Obx(() {
            final String tab = controller.selectedTab.value;
            return IconButton(
              onPressed: () {
                switch (tab) {
                  case 'Invoices':
                    if (Get.isRegistered<InvoiceScreenController>()) {
                      Get.find<InvoiceScreenController>().fetchInvoices();
                    }
                    break;
                  case 'Expenses':
                    if (Get.isRegistered<ExpensesListController>()) {
                      Get.find<ExpensesListController>().fetchExpenses();
                    }
                    break;
                  case 'Tasks':
                    if (Get.isRegistered<TasksScreenController>()) {
                      Get.find<TasksScreenController>().fetchTasks();
                    }
                    break;
                }
              },
              icon: const Icon(Icons.refresh, color: Colors.black54),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Obx(
              () => CustomTabBar(
                options: const [
                  "Invoices",
                  "Expenses",
                  "Tasks",
                ],
                selectedOption: controller.selectedTab.value,
                onSelect: controller.changeTab,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 'Invoices':
                  return InvoiceScreen(embedded: true);
                case 'Expenses':
                  return ExpenseScreen(embedded: true);
                case 'Tasks':
                  return TasksScreen(embedded: true);
                default:
                  return const Center(child: Text("No data available"));
              }
            }),
          ),
        ],
      ),
    );
  }
}
