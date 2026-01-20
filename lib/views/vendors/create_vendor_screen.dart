import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateVendorScreen extends StatelessWidget {
  CreateVendorScreen({super.key});

  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(title: "Add Vendor"),

      body: SafeArea(
        child: SingleChildScrollView(
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
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔹 Vendor Basic Info
                  Text("Vendor Information", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(
                    hintText: "Vendor Name",
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Phone Number",
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Email (Optional)",
                    verticalPadding: 15,
                  ),

                  const SizedBox(height: 25),

                  /// 🔹 Address
                  Text("Address Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(
                    hintText: "Vendor Address",
                    verticalPadding: 15,
                    maxLine: 3,
                  ),

                  const SizedBox(height: 25),

                  /// 🔹 Optional Info
                  Text("Optional Details", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  CustomTextField(
                    hintText: "Company Name",
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Tax Number (NTN / GST)",
                    verticalPadding: 15,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    hintText: "Notes",
                    verticalPadding: 15,
                    maxLine: 4,
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Save Button
                  CustomButton(
                    text: "Save Vendor",
                    onPressed: () {
                      Get.back();
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
