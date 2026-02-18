import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/modules/customers/controllers/customers_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bizly/assets/images.dart';
import '../../../../components/common/loader/loader.dart';
import 'customer_detail_screen.dart';
import '../../../../routes/routes.dart';

class CustomersScreen extends GetView<CustomersController> {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: const
      body: Column(

        children: [
            Container(
              // color: Colors.red,
              decoration: BoxDecoration(
                  color: AppColors.primaryDense,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24),bottomRight:  Radius.circular(24),)
              ),
              child: Column(
                  children: [
                    CustomAppBar2(title: "Customers",backgroundColor: AppColors.primaryDense,textColor: Colors.white,),
                    // 🔹 Search Bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomSearchField(
                        hintText: "Search Customers...",
                        controller: controller.searchController,
                        onChanged: controller.filter,
                        onClear: () => controller.filter(""),
                      ),
                    ),
                  ],
              ),
            ),
          // const SizedBox(height: 15),

          // 🔹 Customers List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: FinancePulseLoader());
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchCustomers,
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
                                    : "No customers found",
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 100,
                          left: 20,
                          right: 20,
                          top: 20,
                        ),
                        itemCount: controller.filtered.length,
                        itemBuilder: (context, index) {
                          final customer = controller.filtered[index];
                          return InkWell(
                            onTap: () {
                              Get.to(() => CustomerDetailScreen(customer: customer));
                            },
                            child: _customerCard(customer),
                          );
                        },
                      ),
              );
            }),
          ),
        ],
      ),

      // 🔹 Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
           Get.toNamed(Routes.createCustomerScreen);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🔹 Customer Card
  Widget _customerCard(CustomerModel customer) {
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
            child: ClipOval(
              child: (customer.profileImage != null &&
                      customer.profileImage!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: customer.profileImage!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Image(
                        image: AssetImage(AppImages.profilePlaceholder),
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (_, __, ___) => _initialsAvatar(
                        customer.customerName,
                        18,
                      ),
                    )
                  : _initialsAvatar(customer.customerName, 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.email ?? "-",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  customer.phoneNumber,
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

  Widget _initialsAvatar(String name, double fontSize) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Text(
        name.isNotEmpty ? name[0] : "?",
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
