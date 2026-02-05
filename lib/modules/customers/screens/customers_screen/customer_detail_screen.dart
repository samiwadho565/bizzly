import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_drop_down.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDense,
      appBar: const CustomAppBar2(title: "Customer Detail",backgroundColor: AppColors.primaryDense,textColor: Colors.white,),
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
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            customer.name[0],
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
                                customer.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                customer.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🔹 Vertical menu icon
                        PopupMenuButton<String>(
                          color:  AppColors.textField,
                          icon: const Icon(Icons.more_vert, size: 28),
                          onSelected: (value) {
                            if (value == 'Edit') {
                              // TODO: Navigate to Edit Customer Screen
                              print("Edit customer tapped");
                            } else if (value == 'Delete') {
                              AppDialogs.showConfirmation(
                                title: "Delete Customer",
                                message: "Are you sure you want to delete ${customer.name}?",
                                onYes: () {
                                  // ✅ Delete logic
                                  print("${customer.name} deleted!");
                                  Get.back(); // optional, close detail screen after delete
                                },
                                onNo: () {
                                  print("Delete cancelled");
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'Edit',
                              child: Text('Edit'),

                            ),
                            const PopupMenuItem<String>(
                              value: 'Delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey.shade200,),
                  // SizedBox(height: 10,),
                  /// 🔹 Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Required Fields
                          _infoCard(
                            icon: Icons.phone,
                            title: "Phone Number",
                            value: customer.phone,
                          ),
                          _infoCard(
                            icon: Icons.email,
                            title: "Email",
                            value: customer.email,
                          ),
                          _infoCard(
                            icon: Icons.location_on,
                            title: "Address",
                            value: customer.address,
                          ),

                          /// Optional Fields (show only if available)
                          if (customer.secondaryPhone != null)
                            _infoCard(
                              icon: Icons.phone_android,
                              title: "Secondary Phone",
                              value: customer.secondaryPhone!,
                            ),
                          if (customer.companyName != null)
                            _infoCard(
                              icon: Icons.business,
                              title: "Company Name",
                              value: customer.companyName!,
                            ),
                          if (customer.taxNumber != null)
                            _infoCard(
                              icon: Icons.confirmation_number,
                              title: "Tax / NTN",
                              value: customer.taxNumber!,
                            ),
                          if (customer.website != null)
                            _infoCard(
                              icon: Icons.language,
                              title: "Website",
                              value: customer.website!,
                            ),
                          if (customer.socialLink != null)
                            _infoCard(
                              icon: Icons.link,
                              title: "Social Link",
                              value: customer.socialLink!,
                            ),
                          if (customer.notes != null)
                            _infoCard(
                              icon: Icons.note,
                              title: "Notes",
                              value: customer.notes!,
                            ),
                          if (customer.city != null)
                            _infoCard(
                              icon: Icons.location_city,
                              title: "City",
                              value: customer.city!,
                            ),
                          if (customer.country != null)
                            _infoCard(
                              icon: Icons.flag,
                              title: "Country",
                              value: customer.country!,
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  /// 🔹 Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            color: AppColors.textPrimary,
                            text: "Edit Customer",
                            onPressed: () {
                              // TODO: Navigate to EditCustomerScreen
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: "Create Invoice",
                            onPressed: () {

                                Get.toNamed(Routes.createInvoiceScreen);

                              // TODO: Navigate to CreateInvoiceScreen
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

  /// 🔹 Info Card Widget (reuse same style as invoice/business screens)
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = Colors.black87,
    FontWeight valueFontWeight = FontWeight.w500,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: valueFontWeight,
                    color: valueColor,
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
