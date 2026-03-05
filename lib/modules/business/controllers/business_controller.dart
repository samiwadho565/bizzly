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
import 'package:bizly/utils/app_utils.dart';

class BusinessDetailController extends GetxController {
  /// Selected Tab
  var selectedTab = 'Invoices'.obs;
  final Rxn<BusinessModel> business = Rxn<BusinessModel>();
  final RxBool detailsExpanded = false.obs;
  final RxBool isDeleting = false.obs;

  /// Tasks List
  RxList<TaskModel> tasks = <TaskModel>[
    TaskModel(
      id: 1,
      taskTitle: "Inventory",
      description: "Manage inventory stock",
      dueDate: "2026-12-19",
      assignedEmployeeName: "John Deo",
      priority: "low",
      status: "to do",
    ),
    TaskModel(
      id: 2,
      taskTitle: "Update Prices",
      description: "Revise product pricing",
      dueDate: "2026-12-20",
      assignedEmployeeName: "Ali Traders",
      priority: "medium",
      status: "in progress",
    ),
    TaskModel(
      id: 3,
      taskTitle: "Server Backup",
      description: "Weekly system backup",
      dueDate: "2026-12-22",
      assignedEmployeeName: "Tech Team",
      priority: "high",
      status: "to do",
    ),
    TaskModel(
      id: 4,
      taskTitle: "UI Improvements",
      description: "Dashboard UI polishing",
      dueDate: "2026-12-25",
      assignedEmployeeName: "Design Team",
      priority: "medium",
      status: "done",
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

  void applyUpdatedBusiness(BusinessModel updated) {
    business.value = updated;
    _syncHomeBusiness(updated);
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
      applyUpdatedBusiness(updated);
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
        AppUtils.showAppSnackbar(
          "Success",
          "Business deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          type: AppSnackType.success,
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
