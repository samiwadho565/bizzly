import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth/signin_controller.dart';
import '../../routes/routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/form_validations.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends GetView<SignInController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    controller.emailController.text = "wadho.dev@gmail.com";
    controller.passwordController.text = "12345678";

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
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                    // State variable screen ke upar define karein
                        // LineChart ko aise data provide karein taake crash na ho


// Widget tree mein call karein
//                         CustomSearchDropdown(
//                           hintText: "Select Business",
//                           items: ["Apple", "Google", "Microsoft", "Amazon"],
//                           selectedItem: selectedValue,
//                           onChanged: (value) {
//                             // setState(() {
//                             //   selectedValue = value;
//                             // });
//                           },
//                         ),
                        // Responsive Spacing: Bari screen par ziada, choti par kam
                        SizedBox(height: screenHeight * 0.04),
                        const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Hi, Welcome Back!",
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
                        CustomTextField(
                          hintText: "Enter your Email",
                          controller: controller.emailController,
                          focusNode: controller.emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            controller.passwordFocusNode.requestFocus();
                          },
                          validator: (value) =>
                              FormValidations.validateEmail(value ?? ""),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: "Enter your Password",
                          isPassword: true,
                          controller: controller.passwordController,
                          focusNode: controller.passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) async {
                            FocusScope.of(context).unfocus();
                            if (!(controller.formKey.currentState?.validate() ??
                                false)) {
                              return;
                            }
                             await controller.signIn();

                          },
                          validator: (value) =>
                              FormValidations.validatePassword(value ?? ""),
                        ),
                        const SizedBox(height: 12),

                        // Remember Me Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Obx(
                                  () => SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: controller.rememberMe.value,
                                      activeColor: AppColors.primary,
                                      onChanged: (val) {
                                        if (val == null) {
                                          return;
                                        }
                                        controller.setRememberMe(val);
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text("Remember Me"),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot Password",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.04), // Ye bari screen par extra space ko fill kar lega

                        // Sign In Button
                        // Login Screen mein Sign In button ki jagah ye use karein:
                        Obx(
                          () => CustomButton(
                            text: "Sign In",
                            // height: 55, // Aap apni marzi ki height de sakte hain
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? () {}
                                : () async {

                                    if (!(controller.formKey.currentState
                                            ?.validate() ??
                                        false)) {
                                      return;
                                    }
                                     await controller.signIn();

                                  },
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Bottom Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Get.offAllNamed(Routes.sigUpScreen);
                              },
                              child: const Text(
                                "Sign Up",
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
            ),
            );
          },
        ),
      ),
    );
  }
}
