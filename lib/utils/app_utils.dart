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
  static OverlayEntry? _topToastEntry;

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

  static void showTopToast(
    String message, {
    BuildContext? context,
    bool atBottom = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final BuildContext? resolvedContext =
        context ?? Get.overlayContext ?? Get.context;
    if (resolvedContext == null) return;
    final OverlayState? overlay =
        Overlay.maybeOf(resolvedContext, rootOverlay: true);
    if (overlay == null) return;

    _topToastEntry?.remove();
    _topToastEntry = null;

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext ctx) {
        final double topInset = MediaQuery.of(ctx).padding.top;
        final double bottomInset = MediaQuery.of(ctx).padding.bottom;
        return Positioned(
          top: atBottom ? null : topInset + 10,
          bottom: atBottom ? bottomInset + 14 : null,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _topToastEntry = entry;
    overlay.insert(entry);

    Future<void>.delayed(duration, () {
      if (_topToastEntry == entry) {
        entry.remove();
        _topToastEntry = null;
      }
    });
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(Get.context!).viewInsets.bottom + 32,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar picker
              Obx(() => GestureDetector(
                    onTap: onPickImage,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF0A2472)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.grey.shade300,
                            child: ClipOval(
                              child: avatarFile.value != null
                                  ? Image.file(avatarFile.value!,
                                      width: 92, height: 92, fit: BoxFit.cover)
                                  : (imageUrl != null && imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: 92,
                                          height: 92,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => const Image(
                                            image: AssetImage(
                                                AppImages.profilePlaceholder),
                                            fit: BoxFit.cover,
                                          ),
                                          errorWidget: (_, __, ___) =>
                                              const Image(
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
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1565C0), Color(0xFF0A2472)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                  color: Colors.white, width: 2.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 15, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 28),

              // Name field
              _buildEditField(
                controller: nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),

              // Email (disabled)
              _buildEditField(
                controller: emailController,
                label: 'Email',
                hint: 'Email address',
                icon: Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: 14),

              // Phone
              _buildEditField(
                controller: phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // Save button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: isSaving.value
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF1565C0),
                                  Color(0xFF0A2472),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: isSaving.value
                            ? Colors.grey.shade300
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSaving.value
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFF1565C0)
                                      .withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF7FAFC) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? const Color(0xFF111827)
                  : const Color(0xFF9CA3AF),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
              prefixIcon: Icon(icon,
                  size: 18,
                  color: enabled
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
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
