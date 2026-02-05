import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';

class VendorDetailScreen extends StatelessWidget {
  final VendorModel vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDense,
      appBar: const CustomAppBar2(
        title: "Vendor Detail",
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                /// 🔹 Header
                Padding(
                  padding: const EdgeInsets.only(
                      top: 40, left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor:
                        AppColors.primary.withOpacity(0.1),
                        child: Text(
                          vendor.name[0],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendor.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vendor.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔹 Menu
                      PopupMenuButton<String>(
                        color: AppColors.textField,
                        icon: const Icon(Icons.more_vert, size: 28),
                        onSelected: (value) {
                          if (value == 'Edit') {
                            // TODO: Navigate to EditVendorScreen
                          } else if (value == 'Delete') {
                            AppDialogs.showConfirmation(
                              title: "Delete Vendor",
                              message:
                              "Are you sure you want to delete ${vendor.name}?",
                              onYes: () {
                                Get.back();
                              },
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'Edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'Delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(color: Colors.grey.shade200),

                /// 🔹 Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                    const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoCard(
                          icon: Icons.phone,
                          title: "Phone Number",
                          value: vendor.phone,
                        ),
                        _infoCard(
                          icon: Icons.email,
                          title: "Email",
                          value: vendor.email,
                        ),
                        _infoCard(
                          icon: Icons.location_on,
                          title: "Address",
                          value: vendor.address,
                        ),

                        if (vendor.secondaryPhone.isNotEmpty)
                          _infoCard(
                            icon: Icons.phone_android,
                            title: "Secondary Phone",
                            value: vendor.secondaryPhone,
                          ),
                        if (vendor.companyName.isNotEmpty)
                          _infoCard(
                            icon: Icons.business,
                            title: "Company Name",
                            value: vendor.companyName,
                          ),
                        if (vendor.taxNumber.isNotEmpty)
                          _infoCard(
                            icon: Icons.confirmation_number,
                            title: "Tax / NTN",
                            value: vendor.taxNumber,
                          ),
                        if (vendor.website.isNotEmpty)
                          _infoCard(
                            icon: Icons.language,
                            title: "Website",
                            value: vendor.website,
                          ),
                        if (vendor.notes.isNotEmpty)
                          _infoCard(
                            icon: Icons.note,
                            title: "Notes",
                            value: vendor.notes,
                          ),
                        if (vendor.city.isNotEmpty)
                          _infoCard(
                            icon: Icons.location_city,
                            title: "City",
                            value: vendor.city,
                          ),
                        if (vendor.country.isNotEmpty)
                          _infoCard(
                            icon: Icons.flag,
                            title: "Country",
                            value: vendor.country,
                          ),
                      ],
                    ),
                  ),
                ),

                /// 🔹 Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          color: AppColors.textPrimary,
                          text: "Edit Vendor",
                          onPressed: () {
                            // TODO: Edit Vendor
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: "Add Bill",
                          onPressed: () {
                            Get.toNamed(Routes.addExpenseScreen);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Info Card
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
