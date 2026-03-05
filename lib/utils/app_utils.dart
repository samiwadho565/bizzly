// # Toasts, validation, helpers

import 'dart:io';

import 'package:bizly/assets/images.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:bizly/components/common/custom_tab_bar.dart';
import 'app_colors.dart';

enum AppSnackType { info, success, error, warning }

class AppUtils {
  static void showAppSnackbar(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.TOP,
    AppSnackType type = AppSnackType.info,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color textColor = Colors.white,
  }) {
    Color resolvedBackground = backgroundColor ?? AppColors.primary.withAlpha(220);
    if (backgroundColor == null) {
      if (type == AppSnackType.success) {
        resolvedBackground = AppColors.primary.withAlpha(220);
      } else if (type == AppSnackType.error) {
        resolvedBackground = Colors.red.shade600;
      } else if (type == AppSnackType.warning) {
        resolvedBackground = Colors.orange.shade700;
      }
    }

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: resolvedBackground,
      colorText: textColor,
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderRadius: 12,
    );
  }

  /// 🔹 Reusable Date Picker
  static Future<DateTime?> pickDate({
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDatePicker(
      context: Get.context!,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }
  static void showEditProfileSheet({
    required String currentName,
    required String currentEmail,
    required String currentPhone,
    required VoidCallback onPickImage,
    required Future<void> Function(String name, String phone) onSave,
    required RxBool isSaving,
    required Rxn<File> avatarFile,
    required String? imageUrl,
  }) {
    final TextEditingController nameController =
    TextEditingController(text: currentName);
    final TextEditingController emailController =
    TextEditingController(text: currentEmail);
    final TextEditingController phoneController =
    TextEditingController(text: currentPhone);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Drag handle
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              /// Title
              // const Text(
              //   "Edit Profile",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 20),

              /// Profile Image
              Obx(
                () => Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade400,
                      child: ClipOval(
                        child: avatarFile.value != null
                            ? Image.file(
                                avatarFile.value!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : (imageUrl != null && imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Image(
                                      image: AssetImage(
                                          AppImages.profilePlaceholder),
                                      fit: BoxFit.cover,
                                    ),
                                    errorWidget: (_, __, ___) => const Image(
                                      image: AssetImage(
                                          AppImages.profilePlaceholder),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Image(
                                    image: AssetImage(
                                        AppImages.profilePlaceholder),
                                    fit: BoxFit.cover,
                                  )),
                      ),
                    ),
                    // Edit icon
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onPickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.blue, // primary color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// Name Field
              CustomTextField(
                controller: nameController,
               hintText: 'Name',
              ),
              const SizedBox(height: 15),

              /// Email Field
              CustomTextField(
                controller: emailController,
          hintText: "Email",
                enabled: false,
                // keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              /// Phone Number Field
              CustomTextField(
                controller: phoneController,

          hintText: 'Phone Number',
              ),
              const SizedBox(height: 25),

              /// Save Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isSaving.value
                        ? null
                        : () async {
                            await onSave(
                              nameController.text.trim(),
                              phoneController.text.trim(),
                            );
                            Get.back();
                          },
                    child: isSaving.value
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
                            "Save Changes",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
  void openFilterBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Drag Handle
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// Due Date
                  const Text(
                    "Due Date",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // CustomTabBar(
                  //   isSmall: true,
                  //   options: const ["Today", "Tomorrow", "This Week"],
                  //   selectedOption: selectedDue,
                  //   onSelect: (val) {
                  //     setModalState(() => selectedDue = val);
                  //     setState(() {});
                  //   },
                  // ),

                  const SizedBox(height: 20),

                  /// Priority
                  const Text(
                    "Priority",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // CustomTabBar(
                  //   isSmall: true,
                  //   options: const ["Low", "Medium", "High"],
                  //   selectedOption: selectedPriority,
                  //   onSelect: (val) {
                  //     setModalState(() => selectedPriority = val);
                  //     setState(() {});
                  //   },
                  // ),

                  const SizedBox(height: 30),

                  /// Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },

    );
  }
}
