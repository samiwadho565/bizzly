import 'package:bizly/models/api_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/auth/models/user_model.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:bizly/app/constants/app_urls.dart';

class SignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final RxBool isLoading = false.obs;

  Future<UserModel?> signUp() async {
    //if (isLoading.value) return;
    isLoading.value = true;

    ApiResponse response = await ApiService().post(
      AppUrls.signUp,
      data: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
      },
    );

    UserModel? user;
    if (response.success && response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data =
          response.data as Map<String, dynamic>;
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await LocalStorage.saveAuthToken(token);
      }
      if (data['user'] is Map<String, dynamic>) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
    }

    Get.snackbar(response.success ? 'Success' : 'Error', response.message);
    isLoading.value = false;
    return user;
  }

  @override
  void onClose() {
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
