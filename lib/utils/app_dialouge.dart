import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_colors.dart';

class AppDialogAction {
  AppDialogAction({
    required this.label,
    this.onPressed,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;
}

class AppDialogs {
  /// 🔹 Simple Alert Dialog
  static void showAlert({
    required String title,
    required String message,
    String okText = "OK",
    VoidCallback? onOk,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              if (onOk != null) onOk();
            },
            child: Text(okText, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// 🔹 Confirmation Dialog with Yes/No
  static void showConfirmation({
    required String title,
    required String message,
    String yesText = "Yes",
    String noText = "No",
    required VoidCallback onYes,
    VoidCallback? onNo,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              if (onNo != null) onNo();
            },
            child: Text(noText, style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onYes();
            },
            child: Text(yesText, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// 🔹 Input Dialog (TextField)
  static void showInputDialog({
    required String title,
    String hintText = "",
    String okText = "OK",
    String cancelText = "Cancel",
    required ValueChanged<String> onSubmit,
    TextEditingController? controller,
    bool barrierDismissible = true,
  }) {
    final TextEditingController _controller = controller ?? TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: hintText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(cancelText, style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onSubmit(_controller.text.trim());
            },
            child: Text(okText, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// 🔹 Loading Dialog
  static void showLoading({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(color: Colors.white)),
              ]
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 🔹 Close any open dialog
  static void closeDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// 🔹 Delete Confirmation Dialog
  static void showDeleteDialog({
    required String title,
    String? message,
    String deleteText = 'Delete',
    required VoidCallback onDelete,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          onDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          deleteText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// 🔹 Reject Dialog (icon + title + text input + buttons)
  static void showRejectDialog({
    required String title,
    String? message,
    required String iconPath,
    String hintText = 'Enter reason...',
    required ValueChanged<String> onReject,
    String rejectText = 'Reject',
    bool barrierDismissible = true,
  }) {
    final TextEditingController ctrl = TextEditingController();
    Get.dialog(
      _AppRejectDialog(
        iconPath: iconPath,
        title: title,
        message: message,
        hintText: hintText,
        rejectText: rejectText,
        controller: ctrl,
        onReject: onReject,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// 🔹 Custom Action Dialog (matches dialogbox.png style)
  static void showActionDialog({
    required String iconPath,
    required String title,
    String? message,
    required List<AppDialogAction> actions,
    bool barrierDismissible = false,
    bool backDismissible = false,
  }) {
    final Widget dialog = _AppActionDialog(
      iconPath: iconPath,
      title: title,
      message: message,
      actions: actions,
    );
    Get.dialog(
      backDismissible ? dialog : PopScope(canPop: false, child: dialog),
      barrierDismissible: barrierDismissible,
    );
  }
}

class _AppActionDialog extends StatelessWidget {
  const _AppActionDialog({
    required this.iconPath,
    required this.title,
    required this.actions,
    this.message,
  });

  final String iconPath;
  final String title;
  final String? message;
  final List<AppDialogAction> actions;

  // Detect icon type from path to colour the circle
  _IconTheme get _theme {
    if (iconPath.contains('success')) {
      return _IconTheme(bg: const Color(0xFFE8F5E9), icon: const Color(0xFF43A047));
    } else if (iconPath.contains('warning') || iconPath.contains('error')) {
      return _IconTheme(bg: const Color(0xFFFFF3E0), icon: const Color(0xFFFB8C00));
    } else if (iconPath.contains('trash')) {
      return _IconTheme(bg: const Color(0xFFFFEBEE), icon: const Color(0xFFE53935));
    }
    return _IconTheme(bg: const Color(0xFFE3F2FD), icon: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    final _IconTheme theme = _theme;
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon in coloured circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.bg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(iconPath, width: 30, height: 30),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              if (message != null && message!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (actions.isEmpty) {
      return _solidButton(
        label: 'OK',
        color: AppColors.primary,
        onPressed: () => Get.back(),
      );
    }

    if (actions.length == 1) {
      final AppDialogAction a = actions.first;
      return _solidButton(
        label: a.label,
        color: a.textColor ?? AppColors.primary,
        onPressed: () {
          Get.back();
          a.onPressed?.call();
        },
      );
    }

    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _outlinedButton(
              label: actions[0].label,
              color: actions[0].textColor ?? Colors.grey.shade600,
              onPressed: () {
                Get.back();
                actions[0].onPressed?.call();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _solidButton(
              label: actions[1].label,
              color: actions[1].textColor ?? AppColors.primary,
              onPressed: () {
                Get.back();
                actions[1].onPressed?.call();
              },
            ),
          ),
        ],
      );
    }

    // 3+ actions — stacked solid buttons
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          i == actions.length - 1
              ? _outlinedButton(
                  label: actions[i].label,
                  color: actions[i].textColor ?? Colors.grey.shade600,
                  onPressed: () {
                    Get.back();
                    actions[i].onPressed?.call();
                  },
                )
              : _solidButton(
                  label: actions[i].label,
                  color: actions[i].textColor ?? AppColors.primary,
                  onPressed: () {
                    Get.back();
                    actions[i].onPressed?.call();
                  },
                ),
        ],
      ],
    );
  }

  Widget _solidButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );

  Widget _outlinedButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      );
}

class _IconTheme {
  final Color bg;
  final Color icon;
  const _IconTheme({required this.bg, required this.icon});
}

class _AppRejectDialog extends StatelessWidget {
  const _AppRejectDialog({
    required this.iconPath,
    required this.title,
    required this.controller,
    required this.onReject,
    this.message,
    this.hintText = 'Enter reason...',
    this.rejectText = 'Reject',
  });

  final String iconPath;
  final String title;
  final String? message;
  final String hintText;
  final String rejectText;
  final TextEditingController controller;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(iconPath, width: 30, height: 30),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              if (message != null && message!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              // Input field
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 4,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final String reason = controller.text.trim();
                        if (reason.isEmpty) return;
                        Get.back();
                        onReject(reason);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        rejectText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
