import 'dart:ui';
import 'package:bizly/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/auth/controllers/signup_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';

class SignUpScreen extends GetView<SignupController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDense,
                Color(0xFF0A1F5C),
                Color(0xFF0D2F80),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative blobs ─────────────────────────
              Positioned(
                top: -50,
                left: -70,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF81C784).withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                right: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),

              // ── Main content ──────────────────────────────
              Column(
                children: [
                  // ── Branding Header ───────────────────────
                  Expanded(
                    flex: 22,
                    child: SafeArea(
                      bottom: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'bizzly_logo',
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF64B5F6)
                                          .withOpacity(0.20),
                                      blurRadius: 36,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(AppImages.bizzlyLogo,
                                    fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bizzly',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Glassy Form Card ──────────────────────
                  Expanded(
                    flex: 78,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.91),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                            border: const Border(
                              top: BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 40,
                                spreadRadius: -8,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding:
                                const EdgeInsets.fromLTRB(28, 32, 28, 24),
                            child: Form(
                              key: controller.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pill handle
                                  Center(
                                    child: Container(
                                      width: 36,
                                      height: 4,
                                      margin:
                                          const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),

                                  const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Join Bizzly and take control of your business',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Full Name
                                  const _FieldLabel('Full Name'),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    hintText: 'Enter your name',
                                    controller: controller.nameController,
                                    focusNode: controller.nameFocusNode,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) =>
                                        FormValidations.validateName(v ?? ''),
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  const _FieldLabel('Email Address'),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    hintText: 'Enter your email',
                                    controller: controller.emailController,
                                    focusNode: controller.emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) =>
                                        FormValidations.validateEmail(v ?? ''),
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  const _FieldLabel('Password'),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    hintText: 'Create a password',
                                    isPassword: true,
                                    controller: controller.passwordController,
                                    focusNode: controller.passwordFocusNode,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => controller
                                        .confirmPasswordFocusNode
                                        .requestFocus(),
                                    validator: (v) =>
                                        FormValidations.validatePassword(
                                            v ?? ''),
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm Password
                                  const _FieldLabel('Confirm Password'),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    hintText: 'Re-enter your password',
                                    isPassword: true,
                                    controller:
                                        controller.confirmPasswordController,
                                    focusNode:
                                        controller.confirmPasswordFocusNode,
                                    textInputAction: TextInputAction.done,
                                    validator: (v) =>
                                        FormValidations.validateConfirmPassword(
                                      controller.passwordController.text,
                                      v ?? '',
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Create Account Button
                                  Obx(() => CustomButton(
                                        text: 'Create Account',
                                        isLoading:
                                            controller.isLoading.value,
                                        onPressed: controller.isLoading.value
                                            ? () {}
                                            : () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                if (controller
                                                        .formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  controller.signUp();
                                                }
                                              },
                                      )),

                                  const SizedBox(height: 24),

                                  // Login link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Already have an account?  ',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          Get.offAllNamed(Routes.loginScreen);
                                        },
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
