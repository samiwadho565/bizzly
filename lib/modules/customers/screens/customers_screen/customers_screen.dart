import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/modules/customers/controllers/customers_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bizly/assets/images.dart';
import '../../../../components/common/loader/loader.dart';
import 'customer_detail_screen.dart';
import '../../../../routes/routes.dart';

class CustomersScreen extends GetView<CustomersController> {
  const CustomersScreen({super.key});

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
            // ── Fixed Gradient Header ────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  // Decorative circles
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
                      // Title row
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
                            'Customers',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Text(
                                '${controller.filtered.length} total',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search field
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
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search customers...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 20,
                                ),
                                suffixIcon: controller
                                        .searchController.text.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          controller.searchController.clear();
                                          controller.filter('');
                                        },
                                        child: Icon(
                                          Icons.close_rounded,
                                          color:
                                              Colors.white.withOpacity(0.7),
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

            // ── Customer List ────────────────────────────────────
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
                                      Icons.people_outline_rounded,
                                      size: 40,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.error.value.isNotEmpty
                                        ? controller.error.value
                                        : 'No customers found',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap + to add your first customer',
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
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          itemCount: controller.filtered.length,
                          itemBuilder: (context, index) {
                            final CustomerModel customer =
                                controller.filtered[index];
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => CustomerDetailScreen(
                                    customer: customer),
                              ),
                              child: _customerCard(customer),
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
          onPressed: () => Get.toNamed(Routes.createCustomerScreen),
          child: const Icon(Icons.person_add_rounded,
              color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _customerCard(CustomerModel customer) {
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
          // Avatar
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: (customer.profileImage != null &&
                        customer.profileImage!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: customer.profileImage!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Image(
                          image:
                              AssetImage(AppImages.customerPicturePlaceholder),
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (_, __, ___) =>
                            _initialsWidget(customer.customerName, radius: 24),
                      )
                    : _initialsWidget(customer.customerName, radius: 24),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  customer.customerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                if ((customer.email ?? '').isNotEmpty)
                  Row(
                    children: <Widget>[
                      Icon(Icons.email_outlined,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer.email!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(Icons.phone_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      customer.phoneNumber,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsWidget(String name, {required double radius}) {
    final String letter =
        name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.12),
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
    );
  }
}
