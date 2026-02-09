import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';

class BusinessDetailController extends GetxController {
  /// Selected Tab
  var selectedTab = 'Invoices'.obs;
  final Rxn<BusinessModel> business = Rxn<BusinessModel>();
  final RxBool detailsExpanded = false.obs;
  final RxBool isDeleting = false.obs;

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

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is BusinessModel) {
      business.value = args;
    }
  }

  void toggleDetails() {
    detailsExpanded.value = !detailsExpanded.value;
  }

  Future<void> editBusiness() async {
    final BusinessModel? current = business.value;
    if (current == null) {
      await Get.toNamed(Routes.addNewBusiness);
      return;
    }

    final dynamic updated = await Get.toNamed(
      Routes.addNewBusiness,
      arguments: current,
    );
    if (updated is BusinessModel) {
      business.value = updated;
      _syncHomeBusiness(updated);
    }
  }

  Future<void> deleteBusiness() async {
    final int? id = business.value?.id;
    if (id == null || isDeleting.value) return;
    isDeleting.value = true;

    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.updateBusiness}/$id',
      isAuth: true,
    );
    AppDialogs.closeDialog();
    isDeleting.value = false;

    if (response.success) {
      _removeFromHome(id);
      Get.back();
      Future.microtask(() {
        Get.snackbar(
          "Success",
          "Business deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: const Color(0xFF16A34A),
          // colorText: Colors.white,
        );
      });
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  void _syncHomeBusiness(BusinessModel updated) {
    if (!Get.isRegistered<HomeScreenController>()) return;
    final HomeScreenController home = Get.find<HomeScreenController>();
    final int index = home.businesses.indexWhere((b) => b.id == updated.id);
    if (index >= 0) {
      home.businesses[index] = updated;
    }
  }

  void _removeFromHome(int id) {
    if (!Get.isRegistered<HomeScreenController>()) return;
    final HomeScreenController home = Get.find<HomeScreenController>();
    home.businesses.removeWhere((b) => b.id == id);
  }
}
