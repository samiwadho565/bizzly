import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/auth/controllers/signin_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/form_validations.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/services/local_storage.dart';

class LoginScreen extends GetView<SignInController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    controller.emailController.text = "mohammadwadho5@gmail.com";
    controller.passwordController.text = "12345678";
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF64B5F6).withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
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
                    flex: 38,
                    child: SafeArea(
                      bottom: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'bizzly_logo',
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF64B5F6).withOpacity(0.20),
                                      blurRadius: 40,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(AppImages.bizzlyLogo,
                                    fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bizzly',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your Smart Business Partner',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Glassy Form Card ──────────────────────
                  Expanded(
                    flex: 62,
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
                            padding: EdgeInsets.fromLTRB(
                              28,
                              36,
                              28,
                              24 + MediaQuery.of(context).viewInsets.bottom,
                            ),
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
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),

                                  const Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Sign in to manage your businesses & finances',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Email
                                  const _FieldLabel('Email Address'),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    hintText: 'Enter your email',
                                    controller: controller.emailController,
                                    focusNode: controller.emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        controller.passwordFocusNode
                                            .requestFocus(),
                                    validator: (v) =>
                                        FormValidations.validateEmail(v ?? ''),
                                  ),
                                  const SizedBox(height: 18),

                                  // Password
                                  const _FieldLabel('Password'),
                                  const SizedBox(height: 6),
                                  CustomTextField(
                                    hintText: 'Enter your password',
                                    isPassword: true,
                                    controller: controller.passwordController,
                                    focusNode: controller.passwordFocusNode,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) async {
                                      FocusScope.of(context).unfocus();
                                      if (controller.formKey.currentState
                                              ?.validate() ??
                                          false) {
                                        await controller.signIn();
                                      }
                                    },
                                    validator: (v) =>
                                        FormValidations.validatePassword(
                                            v ?? ''),
                                  ),
                                  const SizedBox(height: 12),

                                  // Remember me + Forgot
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Obx(() => SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Checkbox(
                                                  value: controller
                                                      .rememberMe.value,
                                                  activeColor:
                                                      AppColors.primary,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  onChanged: (v) =>
                                                      controller.setRememberMe(
                                                          v ?? false),
                                                ),
                                              )),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Remember me',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 28),

                                  // Sign In Button
                                  Obx(() => CustomButton(
                                        text: 'Sign In',
                                        isLoading:
                                            controller.isLoading.value,
                                        onPressed: controller.isLoading.value
                                            ? () {}
                                            : () async {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                if (controller
                                                        .formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  await controller.signIn();
                                                }
                                              },
                                      )),

                                  const SizedBox(height: 28),

                                  // Sign up link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Don't have an account?  ",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          Get.offAllNamed(Routes.sigUpScreen);
                                        },
                                        child: const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // ── DEV: Reset Onboarding ─────────────
                                  Center(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await LocalStorage.setOnboardingSeen(
                                            false);
                                        Get.offAllNamed(
                                            Routes.onBoardingScreen);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.red
                                                  .withOpacity(0.30),
                                              width: 1),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.bug_report_rounded,
                                                size: 14, color: Colors.red),
                                            SizedBox(width: 6),
                                            Text(
                                              'DEV: Reset Onboarding',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
