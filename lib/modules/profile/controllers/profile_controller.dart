import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bizly/modules/auth/models/user_model.dart';
import 'package:bizly/modules/home/controllers/home_controller.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:bizly/services/api_service.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/components/common/custom_button.dart';

import '../../../utils/app_colors.dart';

class ProfileController extends GetxController {
  final Rxn<UserModel> user = Rxn<UserModel>();
  final Rxn<File> avatarFile = Rxn<File>();
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isLoggingOut = false.obs;
  final RxString imageCacheBuster = ''.obs;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController deletePasswordController =
      TextEditingController();
  final GlobalKey<FormState> deleteFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _bootstrapProfile();
  }

  Future<void> _bootstrapProfile() async {
    await _loadFromLocal();
    await fetchProfile();
  }

  Future<void> _loadFromLocal() async {
    final UserModel? local = await LocalStorage.getUser();
    if (local != null) {
      user.value = local;
    }
  }

  Future<void> fetchProfile() async {
    if (isLoading.value) return;
    isLoading.value = true;
    final String? previousImage = user.value?.imageUrl;
    final ApiResponse response = await ApiService().get(
      AppUrls.profile,
      isAuth: true,
    );
    if (response.success && response.data is Map) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(response.data as Map);
      final Map<String, dynamic> payload =
          map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
      final UserModel updated = UserModel.fromJson(payload);
      user.value = updated;
      if (_didImageChange(previousImage, updated.imageUrl)) {
        _bustCache();
      }
      await LocalStorage.saveUser(updated);
    }
    isLoading.value = false;
  }

  Future<void> pickAvatar() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      avatarFile.value = await _compressImageFile(File(picked.path));

    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (isUpdating.value) return;
    isUpdating.value = true;

    final Map<String, dynamic> data = {
      'name': name.trim(),
      'phone': phone.trim(),
      if (avatarFile.value != null) 'image': avatarFile.value,
    };



    final ApiResponse response = await ApiService().postMultipart(
      AppUrls.profile,
      data: data,
      isAuth: true,
    );

    if (response.success) {
      final String? previousImage = user.value?.imageUrl;
      UserModel? updated;
      if (response.data is Map) {
        final Map<String, dynamic> map =
            Map<String, dynamic>.from(response.data as Map);
        final Map<String, dynamic> payload =
            map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
        updated = UserModel.fromJson(payload);
      } else {

        final UserModel? current = user.value;
        if (current != null) {
          updated = current.copyWith(
            name: name.trim(),
            phone: phone.trim(),
          );
        }
      }

      if (updated != null) {
        user.value = updated;
        user.refresh();
        if (_didImageChange(previousImage, updated.imageUrl)) {
          _bustCache();
        }
        await LocalStorage.saveUser(updated);
        if (Get.isRegistered<HomeScreenController>()) {
          Get.find<HomeScreenController>().setUser(updated);
        }

        if (previousImage != null && previousImage.isNotEmpty) {
          _evictImage(previousImage);
        }

        if (updated.imageUrl != null && updated.imageUrl!.isNotEmpty) {

          _evictImage(updated.imageUrl!);
        }
      }

      // Clear local preview after a successful update so network image shows.
      avatarFile.value = null;

      Future.microtask(() {
        AppUtils.showAppSnackbar(
          "Success",
          "Profile updated successfully",
          snackPosition: SnackPosition.TOP,
          type: AppSnackType.success,
        );
      });
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }



    isUpdating.value = false;
  }

  void showDeleteAccountSheet() {
    deletePasswordController.clear();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: deleteFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delete Account",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Enter your password to confirm account deletion.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: deletePasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Password is required";
                    }
                    if (value.trim().length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.textField,
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isDeleting.value
                          ? null
                          : () {
                              if (deleteFormKey.currentState?.validate() ??
                                  false) {
                                deleteAccount();
                              }
                            },
                      child: isDeleting.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Delete Account",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> deleteAccount() async {
    final String password = deletePasswordController.text.trim();
    if (password.isEmpty || isDeleting.value) return;
    isDeleting.value = true;

    final ApiResponse response = await ApiService().post(
      AppUrls.deleteAccount,
      data: {'password': password},
      isAuth: true,
    );

    isDeleting.value = false;

    if (response.success) {
      await LocalStorage.clearAuthToken();
      await LocalStorage.clearUser();
      Get.offAllNamed(Routes.loginScreen);
      AppUtils.showAppSnackbar(
        "Success",
        "Account deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.success,
      );
    } else {
      AppDialogs.showActionDialog(
        iconPath: AppImages.dialogWarning,
        title: "Error!",
        message: response.message,
        actions: [AppDialogAction(label: "Ok")],
      );
    }
  }

  void showLogoutSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Logout?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Are you sure you want to logout?",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomButton(
                        text: "Confirm",
                        isLoading: isLoggingOut.value,
                        onPressed: () async {
                          if (isLoggingOut.value) return;
                          isLoggingOut.value = true;
                          final ApiResponse response = await ApiService().post(
                            AppUrls.logout,
                            isAuth: true,
                          );
                          isLoggingOut.value = false;

                          if (response.success) {
                            Get.back();
                            await LocalStorage.clearAuthToken();
                            await LocalStorage.clearUser();
                            Get.offAllNamed(Routes.loginScreen);
                          } else {
                            AppDialogs.showActionDialog(
                              iconPath: AppImages.dialogWarning,
                              title: "Error!",
                              message: response.message,
                              actions: [AppDialogAction(label: "Ok")],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      color: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.lightGrey,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    deletePasswordController.dispose();
    super.onClose();
  }

  String? get displayImageUrl {
    final String? url = user.value?.imageUrl;
    if (url == null || url.isEmpty) return null;
    final String buster = imageCacheBuster.value;
    if (buster.isEmpty) return url;
    final String separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$buster';
  }

  void _bustCache() {
    imageCacheBuster.value = DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool _didImageChange(String? previous, String? current) {
    final String before = (previous ?? '').trim();
    final String after = (current ?? '').trim();
    return before != after;
  }

  void _evictImage(String url) {
    try {
      PaintingBinding.instance.imageCache.evict(NetworkImage(url));
    } catch (_) {}
  }

  Future<File> _compressImageFile(File file) async {
    final Directory dir = await getTemporaryDirectory();
    int quality = 85;
    File? compressed = file;

    while (compressed != null &&
        await compressed.length() > 2048 * 1024 &&
        quality >= 40) {
      final String targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (result == null) {
        break;
      }
      compressed = File(result.path);
      quality -= 10;
    }

    return compressed ?? file;
  }
}
