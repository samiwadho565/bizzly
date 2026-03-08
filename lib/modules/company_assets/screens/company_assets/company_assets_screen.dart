import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/modules/company_assets/controllers/company_assets_controller.dart';
import 'package:bizly/modules/company_assets/models/assets_model.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';

class CompanyAssetsScreen extends GetView<CompanyAssetsController> {
  const CompanyAssetsScreen({super.key});

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
                  title: "Company Assets",
                  backgroundColor: AppColors.primaryDense,
                  textColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomSearchField(
                    hintText: "Search Assets...",
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
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchAssets,
                child: controller.filtered.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                              child: Text(
                                controller.error.value.isNotEmpty
                                    ? controller.error.value
                                    : "No assets found",
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        itemCount: controller.filtered.length,
                        itemBuilder: (context, index) {
                          final AssetModel asset = controller.filtered[index];
                          return _assetCard(asset);
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
          controller.prepareForCreate();
          final dynamic result = await Get.toNamed(Routes.addCompanyAssetScreen);
          if (result is AssetModel) {
            controller.fetchAssets();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _assetCard(AssetModel asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryDense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primaryDense,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assetName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      asset.assetType,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPopupMenu(asset),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Value", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(height: 2),
                  Text(
                    "PKR ${asset.value}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDense,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _iconDetailRow(Icons.calendar_today, asset.purchaseDate),
                  const SizedBox(height: 6),
                  _iconDetailRow(Icons.person_outline, asset.assignedEmployeeName ?? "-"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconDetailRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 14, color: Colors.grey.shade400),
      ],
    );
  }

  Widget _buildPopupMenu(AssetModel asset) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_horiz, color: Colors.grey),
      onSelected: (String value) async {
        if (value == 'Edit') {
          controller.loadForEdit(asset);
          final dynamic result = await Get.toNamed(
            Routes.addCompanyAssetScreen,
            arguments: asset,
          );
          if (result is AssetModel) {
            controller.fetchAssets();
          }
          return;
        }
        if (value == 'Delete') {
          AppDialogs.showActionDialog(
            iconPath: AppImages.dialogTrash,
            title: "Delete Asset!",
            message: "Are you sure you want to delete ${asset.assetName}?",
            actions: [
              AppDialogAction(
                label: "Delete Asset",
                textColor: Colors.red,
                onPressed: () async {
                  await controller.deleteAsset(asset);
                },
              ),
              AppDialogAction(label: "Cancel"),
            ],
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'Edit',
          child: Row(
            children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text("Edit")],
          ),
        ),
        PopupMenuItem(
          value: 'Delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text("Delete", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
