import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/modules/categories/models/category_model.dart';

class CategoriesController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> filtered = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    final ApiResponse response = await ApiService().get(
      AppUrls.expenseCategories,
      isAuth: true,
    );

    if (response.success) {
      final dynamic raw = response.data;
      final List<dynamic> items = raw is List
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] as List : []);
      categories.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryModel.fromJson(e))
            .toList(),
      );
      filtered.assignAll(categories);
    } else {
      categories.clear();
      filtered.clear();
      error.value = response.message;
    }

    isLoading.value = false;
  }

  void filter(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(categories);
      return;
    }
    filtered.assignAll(
      categories
          .where((c) => c.name.toLowerCase().contains(q))
          .toList(),
    );
  }

  Future<void> deleteCategory(CategoryModel category) async {
    if (category.id == null) return;
    AppDialogs.showLoading(message: "Deleting...");
    final ApiResponse response = await ApiService().delete(
      '${AppUrls.deleteCategory}/${category.id}',
      isAuth: true,
    );
    AppDialogs.closeDialog();

    if (response.success) {
      await fetchCategories();
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  Future<bool> updateCategory(CategoryModel category, String name) async {
    if (category.id == null || isUpdating.value) return false;
    isUpdating.value = true;
    try {
      final ApiResponse response = await ApiService().post(
        '${AppUrls.updateCategory}/${category.id}',
        data: {'name': name.trim()},
        isAuth: true,
      );
      if (response.success) {
        await fetchCategories();
        return true;
      }
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  void confirmDelete(CategoryModel category) {
    AppDialogs.showActionDialog(
      iconPath: AppImages.dialogTrash,
      title: "Delete Category?",
      message: "Are you sure you want to delete this category?",
      actions: [
        AppDialogAction(label: "Cancel"),
        AppDialogAction(
          label: "Delete",
          textColor: Colors.red,
          onPressed: () {
            deleteCategory(category);
          },
        ),
      ],
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
