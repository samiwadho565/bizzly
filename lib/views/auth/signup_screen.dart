import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../routes/routes.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen ki height aur width nikalne ke liye
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Agar screen choti ho to scroll enable rahega (safety ke liye)
              // magar hum padding aur spacing ko flexible banayenge.
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Responsive Spacing: Bari screen par ziada, choti par kam


                        SizedBox(height: screenHeight * 0.04),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Create an Account!",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Manage your businesses, invoices, and sales in one place",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05), // Flexible Space

                        // Input Fields
                        const CustomTextField(hintText: "Enter your Name"),
                        const SizedBox(height: 16),
                        const CustomTextField(hintText: "Enter your Email"),
                        const SizedBox(height: 16),
                        const CustomTextField(
                          hintText: "Enter New Password",
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),
                        const CustomTextField(
                          hintText: "Confirm  Password",
                          isPassword: true,
                        ),

                        SizedBox(height: screenHeight * 0.05), // Ye bari screen par extra space ko fill kar lega

                        // Sign In Button
                        // Login Screen mein Sign In button ki jagah ye use karein:
                        CustomButton(
                          text: "Create Account",
                          // height: 55, // Aap apni marzi ki height de sakte hain
                          onPressed: () {
                            print("Sign In Pressed");
                          },
                        ),
                        // const SizedBox(height: 20),
                        SizedBox(height: screenHeight * 0.05),

                        // Bottom Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            GestureDetector(
                              onTap: () {
                                Get.offAllNamed(Routes.loginScreen);
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontSize: 13),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("Or Sign Up with", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Google Icon
                        Center(
                          child: Container(
                            height: 55, width: 55,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF5F7F8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}