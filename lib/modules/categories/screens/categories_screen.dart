import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/modules/categories/controllers/categories_controller.dart';
import 'package:bizly/modules/categories/models/category_model.dart';
import 'package:bizly/components/common/loader/loader.dart';

import '../../../components/common/custom_text_field.dart';

class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

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
                  title: "Categories",
                  backgroundColor: AppColors.primaryDense,
                  textColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomSearchField(
                    hintText: "Search Categories...",
                    controller: controller.searchController,
                    onChanged: controller.filter,
                    onClear: () => controller.filter(""),
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
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchCategories,
                child: controller.filtered.isEmpty
                    ? Center(
                        child: Text(
                          controller.error.value.isNotEmpty
                              ? controller.error.value
                              : "No categories found",
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: controller.filtered.length,
                        itemBuilder: (context, index) {
                          final CategoryModel category =
                              controller.filtered[index];
                          return _categoryTile(context, category);
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(BuildContext context, CategoryModel category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if ((category.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    category.description!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openEditSheet(context, category),
            icon: const Icon(Icons.edit, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () => controller.confirmDelete(category),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context, CategoryModel category) {
    final TextEditingController nameController =
        TextEditingController(text: category.name);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Edit Category",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: nameController,
                  hintText: "Category Name",
                  validator: (v) =>
                      FormValidations.validateRequiredMin3(v ?? '', fieldName: "Category"),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  verticalPadding: 15,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => CustomButton(
                    text: "Update",
                    isLoading: controller.isUpdating.value,
                    onPressed: controller.isUpdating.value
                        ? () {}
                        : () async {
                            final bool ok =
                                formKey.currentState?.validate() ?? false;
                            if (!ok) return;
                            final bool success = await controller.updateCategory(
                              category,
                              nameController.text.trim(),
                            );
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
