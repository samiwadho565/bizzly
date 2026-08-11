import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/modules/company_assets/controllers/company_assets_controller.dart';
import 'package:bizly/modules/company_assets/models/assets_model.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';

class CompanyAssetsScreen extends GetView<CompanyAssetsController> {
  const CompanyAssetsScreen({super.key});

  static const LinearGradient _gradient = LinearGradient(
    colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: <Widget>[
            // ── Gradient Header ────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 18),
              decoration: const BoxDecoration(gradient: _gradient),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (Get.previousRoute.isNotEmpty)
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          const Text(
                            'Company Assets',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Text(
                                '${controller.filtered.length} assets',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.filter,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search assets...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                            suffixIcon:
                                controller.searchController.text.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          controller.searchController.clear();
                                          controller.filter('');
                                        },
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 18,
                                        ),
                                      )
                                    : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: FinancePulseLoader());
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.fetchAssets,
                  child: controller.filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: <Widget>[
                            SizedBox(
                              height: 280,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1565C0)
                                          .withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 40,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.error.value.isNotEmpty
                                        ? controller.error.value
                                        : 'No assets found',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap + to add your first asset',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.filtered.length,
                          itemBuilder: (context, index) {
                            final AssetModel asset =
                                controller.filtered[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showAssetBottomSheet(context, asset),
                              child: _assetCard(asset),
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),

      // ── FAB ───────────────────────────────────────────────
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: _gradient,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.40),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            controller.prepareForCreate();
            final dynamic result =
                await Get.toNamed(Routes.addCompanyAssetScreen);
            if (result is AssetModel) {
              controller.fetchAssets();
            }
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  // ── Asset Card ───────────────────────────────────────────
  Widget _assetCard(AssetModel asset) {
    final String letter =
        asset.assetName.trim().isNotEmpty ? asset.assetName[0].toUpperCase() : 'A';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Gradient ring avatar
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradient,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  asset.assetName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Icon(Icons.category_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      asset.assetType,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(Icons.attach_money_rounded,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'PKR ${asset.value}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (asset.assignedEmployeeName != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      Icon(Icons.person_outline,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        asset.assignedEmployeeName!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Purchase date badge + chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  asset.purchaseDate,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  // ── Detail Bottom Sheet ──────────────────────────────────
  void _showAssetBottomSheet(BuildContext context, AssetModel asset) {
    final double bottomPad = MediaQuery.of(context).padding.bottom;
    final String letter =
        asset.assetName.trim().isNotEmpty ? asset.assetName[0].toUpperCase() : 'A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.25),
                        ),
                        child: Container(
                          width: 54,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.18),
                          ),
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              asset.assetName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: <Widget>[
                                Icon(Icons.category_outlined,
                                    size: 13,
                                    color: Colors.white.withOpacity(0.75)),
                                const SizedBox(width: 4),
                                Text(
                                  asset.assetType,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.80),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Detail rows
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _infoGroup(<_InfoRow>[
                _InfoRow(
                  icon: Icons.payments_rounded,
                  label: 'Value',
                  value: 'PKR ${asset.value}',
                  color: Colors.teal.shade700,
                  valueColor: const Color(0xFF1565C0),
                ),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Purchase Date',
                  value: asset.purchaseDate,
                  color: Colors.orange.shade700,
                ),
                _InfoRow(
                  icon: Icons.person_rounded,
                  label: 'Assigned To',
                  value: asset.assignedEmployeeName ?? '—',
                  color: Colors.purple.shade700,
                ),
              ]),
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 20),
              child: Row(
                children: <Widget>[
                  // Edit
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          controller.loadForEdit(asset);
                          final dynamic result = await Get.toNamed(
                            Routes.addCompanyAssetScreen,
                            arguments: asset,
                          );
                          if (result is AssetModel) {
                            controller.fetchAssets();
                          }
                        },
                        icon: const Icon(Icons.edit_rounded,
                            size: 17, color: Colors.white),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        AppDialogs.showActionDialog(
                          iconPath: AppImages.dialogTrash,
                          title: 'Delete Asset!',
                          message:
                              'Are you sure you want to delete ${asset.assetName}?',
                          actions: <AppDialogAction>[
                            AppDialogAction(
                              label: 'Delete Asset',
                              textColor: Colors.red,
                              onPressed: () async {
                                await controller.deleteAsset(asset);
                              },
                            ),
                            AppDialogAction(label: 'Cancel'),
                          ],
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 17),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoGroup(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List<Widget>.generate(rows.length, (i) {
          final _InfoRow row = rows[i];
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: row.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(row.icon, color: row.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            row.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            row.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: row.valueColor ?? AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade100,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? valueColor;
}
