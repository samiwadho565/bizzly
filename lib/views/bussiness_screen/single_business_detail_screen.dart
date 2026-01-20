import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_button.dart';

class SingleBusinessDetailScreen extends StatelessWidget {
  SingleBusinessDetailScreen({super.key});

  // 🔹 Dummy Data (baad me controller / API se ayega)
  final Map<String, String> business = {
    "name": "Fixonto",
    "address": "123 Street, Karachi, Pakistan",
    "phone": "+92 300 1234567",
    "currency": "PKR",
    "email": "info@fixonto.com",
    "tax": "1234567",
    "website": "www.fixonto.com",
    "hours": "9 AM - 6 PM",
    "description": "Professional home services platform.",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Business Profile"),
      body: SafeArea(
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
          child: Column(
            children: [

              /// 🔹 Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        business["name"]![0],
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
                            business["name"]!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            business["address"]!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔹 Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.phone,
                        title: "Phone Number",
                        value: business["phone"]!,
                      ),
                      _infoCard(
                        icon: Icons.attach_money,
                        title: "Currency",
                        value: business["currency"]!,
                        valueColor: AppColors.primary,
                        valueFontWeight: FontWeight.bold,
                      ),
                      _infoCard(
                        icon: Icons.email,
                        title: "Email Address",
                        value: business["email"]!,
                      ),
                      _infoCard(
                        icon: Icons.confirmation_number,
                        title: "Tax / NTN Number",
                        value: business["tax"]!,
                      ),
                      _infoCard(
                        icon: Icons.language,
                        title: "Website",
                        value: business["website"]!,
                      ),
                      _infoCard(
                        icon: Icons.access_time,
                        title: "Operating Hours",
                        value: business["hours"]!,
                      ),
                      _infoCard(
                        icon: Icons.description,
                        title: "Business Description",
                        value: business["description"]!,
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
                        text: "Edit Business",
                        onPressed: () {
                          // TODO: Navigate to EditBusinessScreen
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Create Invoice",
                        onPressed: () {
                          // TODO: Navigate to CreateInvoiceScreen

                            Get.toNamed(Routes.createInvoiceScreen);

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
    );
  }

  /// 🔹 Info Card Widget (reuse invoice style)
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
            offset: const Offset(0, -4),
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
