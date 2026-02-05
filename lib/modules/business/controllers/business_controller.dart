import 'package:get/get.dart';

import 'package:bizly/models/tasks_model.dart';

class BusinessDetailController extends GetxController {
  /// Selected Tab
  var selectedTab = 'Overview'.obs;

  /// Tasks List
  RxList<TaskModel> tasks = <TaskModel>[
    TaskModel(
      title: "Inventory",
      description: "Manage inventory stock",
      dueDate: DateTime(2026, 12, 19),
      assignedTo: "John Deo",
      priority: 3,
      status: "Pending", id: '1', companyName: 'Fixdar',
      // createdAt: null,
    ),
    TaskModel(
      title: "Update Prices",
      description: "Revise product pricing",
      dueDate: DateTime(2026, 12, 20),
      assignedTo: "Ali Traders",
      priority: 2,
      status: "In Progress", id: '', companyName: 'Fixonto',
    ),
    TaskModel(
      title: "Server Backup",
      description: "Weekly system backup",
      dueDate: DateTime(2026, 12, 22),
      assignedTo: "Tech Team",
      priority: 1,
      status: "Pending", id: '', companyName: 'SilverSpoon',
    ),
    TaskModel(
      title: "UI Improvements",
      description: "Dashboard UI polishing",
      dueDate: DateTime(2026, 12, 25),
      assignedTo: "Design Team",
      priority:3,
      status: "Completed", id: '', companyName: 'AppxView',
    ),
  ].obs;
  /// Invoices List
  final invoices = <Map<String, String>>[
    {
      "client": "John Doe",
      "business": "TechNova",
      "item": "Website Design",
      "amount": "\$500",
      "status": "Paid",
    },
    {
      "client": "Robert De Niro",
      "business": "Crypto Trading",
      "item": "Mobile App",
      "amount": "\$1200",
      "status": "Paid",
    },
    {
      "client": "John Doe",
      "business": "TechNova",
      "item": "Website Design",
      "amount": "\$500",
      "status": "Paid",
    },
    {
      "client": "Robert De Niro",
      "business": "Crypto Trading",
      "item": "Mobile App",
      "amount": "\$1200",
      "status": "Paid",
    },
  ].obs;

  /// Tab change handler
  void changeTab(String tab) {
    selectedTab.value = tab;
  }
}
