import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/custom_button.dart';
import 'package:bizly/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar_2.dart';

class AddNewBusinessScreen extends StatelessWidget {
  AddNewBusinessScreen({super.key});

  // ✅ Common TextStyles
  final TextStyle requiredLabelStyle =
  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black);


  final TextStyle sectionTitleStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(title: "Add New Business"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(40),
                topLeft: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------------- Required Fields -----------------
                  Text("Required Information", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  Text("Business Name", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "Fixonto", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Business Address", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "123 Street, City", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Phone Number", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "+92 300 1234567", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Currency", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "PKR", verticalPadding: 13),
                  const SizedBox(height: 25),

                  // ----------------- Optional Fields -----------------
                  Text("Optional Information", style: sectionTitleStyle),
                  const SizedBox(height: 15),

                  Text("Email Address", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "example@mail.com", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Tax / NTN Number", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "1234567", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Website", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "www.example.com", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Social Media Link", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "https://facebook.com/example", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Business Description", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "Short description about business", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Operating Hours", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "9 AM - 6 PM", verticalPadding: 13),
                  const SizedBox(height: 15),

                  Text("Secondary Contact", style: requiredLabelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(hintText: "+92 300 7654321", verticalPadding: 13),

                  const SizedBox(height: 30),

                  // Create Button
           CustomButton(text: "Create Business", onPressed: (){}),

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
