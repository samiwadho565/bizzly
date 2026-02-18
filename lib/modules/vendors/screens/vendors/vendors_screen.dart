import 'package:bizly/modules/vendors/screens/vendors/vendor_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';
import 'package:bizly/modules/vendors/controllers/vendors_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import '../../../../components/common/loader/loader.dart';
import '../../../../routes/routes.dart';
// import 'vendor_detail_screen.dart';

class VendorsScreen extends GetView<VendorsController> {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          /// 🔹 Header + Search
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
                  title: "Vendors",
                  backgroundColor: AppColors.primaryDense,
                  textColor: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomSearchField(
                    hintText: "Search Vendors...",
                    controller: controller.searchController,
                    onChanged: controller.filter,
                    onClear: () => controller.filter(""),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 Vendors List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: FinancePulseLoader());
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchVendors,
                child: controller.filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                controller.error.value.isNotEmpty
                                    ? controller.error.value
                                    : "No vendors found",
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: controller.filtered.length,
                        itemBuilder: (context, index) {
                          final vendor = controller.filtered[index];
                          return InkWell(
                            onTap: () {
                              Get.to(() => VendorDetailScreen(vendor: vendor));
                            },
                            child: _vendorCard(vendor),
                          );
                        },
                      ),
              );
            }),
          ),
        ],
      ),

      /// ➕ Add Vendor
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
            Get.toNamed(Routes.createVendorScreen);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🔹 Vendor Card
  Widget _vendorCard(VendorModel vendor) {
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
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              vendor.vendorName.isNotEmpty ? vendor.vendorName[0] : "?",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.vendorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vendor.email ?? "-",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  vendor.phoneNumber,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
