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

  /// 🔹 Custom Action Dialog (matches dialogbox.png style)
  static void showActionDialog({
    required String iconPath,
    required String title,
    String? message,
    required List<AppDialogAction> actions,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      _AppActionDialog(
        iconPath: iconPath,
        title: title,
        message: message,
        actions: actions,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            SvgPicture.asset(iconPath, width: 36, height: 36),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (message != null && message!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
             Divider(height: 1, thickness: 1, color:Colors.grey.shade200),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (actions.length <= 1) {
      final AppDialogAction action =
          actions.isNotEmpty ? actions.first : AppDialogAction(label: 'OK');
      return _DialogActionButton(
        label: action.label,
        textColor: action.textColor ?? AppColors.primary,
        onPressed: () {
          Get.back();
          action.onPressed?.call();
        },
      );
    }

    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _DialogActionButton(
              label: actions[0].label,
              textColor: actions[0].textColor ?? AppColors.primary,
              onPressed: () {
                Get.back();
                actions[0].onPressed?.call();
              },
            ),
          ),
           SizedBox(
            height: 44,
            child: VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade200),
          ),
          Expanded(
            child: _DialogActionButton(
              label: actions[1].label,
              textColor: actions[1].textColor ?? AppColors.primary,
              onPressed: () {
                Get.back();
                actions[1].onPressed?.call();
              },
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0)
             Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          _DialogActionButton(
            label: actions[i].label,
            textColor: actions[i].textColor ?? AppColors.viewAll,
            onPressed: () {
              Get.back();
              actions[i].onPressed?.call();
            },
          ),
        ],
      ],
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onPressed,
    required this.textColor,
  });

  final String label;
  final VoidCallback onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
