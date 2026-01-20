import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_app_bar_2.dart';

class AllBusinessesScreen extends StatelessWidget {
  AllBusinessesScreen({super.key});

  // Dummy data (API se baad me ayega)
  final List<Map<String, String>> businesses = [
    {
      "name": "Fixonto",
      "phone": "+92 300 1234567",
      "currency": "PKR",
      "address": "Karachi, Pakistan",
    },
    {
      "name": "Bizly Tech",
      "phone": "+92 301 9876543",
      "currency": "USD",
      "address": "Lahore, Pakistan",
    },
    {
      "name": "SoftHub",
      "phone": "+92 302 1122334",
      "currency": "PKR",
      "address": "Islamabad",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDense,
      appBar: const CustomAppBar2(title: "My Businesses",backgroundColor: AppColors.primaryDense,textColor: Colors.white,),
      body: SafeArea(
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
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return InkWell(
                  onTap: (){
                    Get.toNamed(Routes.singleBusinessDetailScreen,);
                  },
                  child: _businessCard(business));
            },
          ),
        ),
      ),

      /// 🔹 Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.toNamed(Routes.addNewBusiness);
          // TODO: Navigate to AddNewBusinessScreen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🔹 Business Card Widget
  Widget _businessCard(Map<String, String> business) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),       BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0,-2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔹 Leading Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              business["name"]![0],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),

          /// 🔹 Business Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business["name"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  business["address"]!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      business["phone"]!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        business["currency"]!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔹 Arrow
          const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
