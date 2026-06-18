import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/profile/controllers/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  final bool showBackButton;

  @override
  ProfileController get controller {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>();
    }
    return Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = controller.user.value;
        final String? displayImageUrl = controller.displayImageUrl;

        return Column(
          children: [
            // ── Fixed Hero Header ─────────────────────────────────
            _ProfileHero(
              user: user,
              displayImageUrl: displayImageUrl,
              showBackButton: showBackButton,
              onEditTap: () => AppUtils.showEditProfileSheet(
                currentName: user?.name ?? '',
                currentEmail: user?.email ?? '',
                currentPhone: user?.phone ?? '',
                onPickImage: controller.pickAvatar,
                isSaving: controller.isUpdating,
                avatarFile: controller.avatarFile,
                imageUrl: displayImageUrl,
                onSave: (name, phone) async {
                  await controller.updateProfile(name: name, phone: phone);
                },
              ),
              controller: controller,
            ),

            // ── Scrollable Settings ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'Security'),
                    const SizedBox(height: 10),
                    _SettingsGroup(
                      tiles: [
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFF1E88E5),
                          title: 'Change Password',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _SectionLabel(label: 'Support & Legal'),
                    const SizedBox(height: 10),
                    _SettingsGroup(
                      tiles: [
                        _SettingsTile(
                          icon: Icons.headset_mic_outlined,
                          iconColor: const Color(0xFF00897B),
                          title: 'Contact Support',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.download_outlined,
                          iconColor: const Color(0xFF8E24AA),
                          title: 'Data Export',
                          trailing: 'CSV / PDF',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          iconColor: const Color(0xFFF57C00),
                          title: 'Terms & Conditions',
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _SectionLabel(label: 'Account'),
                    const SizedBox(height: 10),
                    _SettingsGroup(
                      tiles: [
                        _SettingsTile(
                          icon: Icons.logout_rounded,
                          iconColor: AppColors.primary,
                          title: 'Log Out',
                          titleColor: AppColors.primary,
                          onTap: controller.showLogoutSheet,
                        ),
                        _SettingsTile(
                          icon: Icons.delete_outline_rounded,
                          iconColor: Colors.red,
                          title: 'Delete Account',
                          titleColor: Colors.red,
                          onTap: controller.showDeleteAccountSheet,
                          isLast: true,
                          showArrow: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero Header
// ─────────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.displayImageUrl,
    required this.showBackButton,
    required this.onEditTap,
    required this.controller,
  });

  final dynamic user;
  final String? displayImageUrl;
  final bool showBackButton;
  final VoidCallback onEditTap;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient banner
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0A2472)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              // Back button
              if (showBackButton)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              // Title
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile card — overlapping the banner
        Positioned(
          top: 130,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF0A2472)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.grey.shade300,
                        child: ClipOval(
                          child: Obx(() => controller.avatarFile.value != null
                              ? Image.file(
                                  controller.avatarFile.value!,
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.cover,
                                )
                              : (displayImageUrl != null &&
                                      displayImageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: displayImageUrl!,
                                      width: 76,
                                      height: 76,
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
                                    ))),
                        ),
                      ),
                    ),
                    // Edit button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF0A2472)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '—',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.email_outlined,
                                size: 12, color: Color(0xFF1565C0)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user?.email ?? '—',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.phone_outlined,
                                size: 12, color: Color(0xFF1565C0)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (user?.phone ?? '').isNotEmpty ? user!.phone! : '—',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Spacer for the overlapping card
        const SizedBox(height: 310),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Settings group (iOS-style rounded container)
// ─────────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.tiles});
  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: tiles,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Settings tile
// ─────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
    this.isLast = false,
    this.showArrow = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final String? trailing;
  final Color? titleColor;
  final bool isLast;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(18))
              : BorderRadius.zero,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  Text(
                    trailing!,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 6),
                ],
                if (showArrow)
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 66,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}

// Keep ProfileTile for backward compatibility (used elsewhere)
class ProfileTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Color? textColor;

  const ProfileTile({
    super.key,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Colors.black87,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(trailingText!,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: textColor ?? Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
