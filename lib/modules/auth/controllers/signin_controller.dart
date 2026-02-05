import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/modules/auth/models/user_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/services/local_storage.dart';

class SignInController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final bool storedValue = await LocalStorage.getRememberMe();
    rememberMe.value = storedValue;
    if (storedValue) {
      final String? storedEmail = await LocalStorage.getRememberedEmail();
      final String? storedPassword = await LocalStorage.getRememberedPassword();
      if (storedEmail != null && storedEmail.isNotEmpty) {
        emailController.text = storedEmail;
      }
      if (storedPassword != null && storedPassword.isNotEmpty) {
        passwordController.text = storedPassword;
      }
    }
  }

  Future<UserModel?> signIn() async {
    if (isLoading.value) return null;
    isLoading.value = true;

    ApiResponse response = await ApiService().post(
      AppUrls.signIn,
      data: {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      },
    );

    UserModel? user;
    if (response.success && response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data =
          response.data as Map<String, dynamic>;
      final String? token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await LocalStorage.saveAuthToken(token);
      }
      if (data['user'] is Map<String, dynamic>) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        if (rememberMe.value) {
          await LocalStorage.saveRememberedEmail(
            emailController.text.trim(),
          );
          await LocalStorage.saveRememberedPassword(
            passwordController.text,
          );
        } else {
          await LocalStorage.clearRememberedCredentials();
        }

          Get.offAllNamed(Routes.homeScreen);
      }

    }else{
      Get.snackbar(
          'Error',
          response.message,snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red
      );
    }


    isLoading.value = false;
    return user;
  }

  Future<void> setRememberMe(bool value) async {
    rememberMe.value = value;
    await LocalStorage.saveRememberMe(value);
    if (!value) {
      await LocalStorage.clearRememberedCredentials();
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.onClose();
  }
}
