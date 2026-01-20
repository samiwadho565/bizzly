import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

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
}
