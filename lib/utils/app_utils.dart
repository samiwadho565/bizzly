// # Toasts, validation, helpers

import 'package:bizly/assets/images.dart';
import 'package:bizly/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../widgets/custom_tab_bar.dart';
import 'app_colors.dart';

class AppUtils {

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
    required VoidCallback onSave,
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
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                    AssetImage(AppImages.profilePlaceholder), // Replace with user's image
                  ),
                  // Edit icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        print("Edit profile image tapped");
                        // AppUtils.showEditProfileSheet(currentName: "Lisa Smith", currentEmail: "LisaSmith@gmail.com", currentPhone: "+1 (212) 555-0147", onSave: (){});
                        // TODO: Open image picker or edit profile sheet
                      },
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
                    // TODO: Add save logic
                    print(
                        "Saved: ${nameController.text}, ${emailController.text}, ${phoneController.text}");
                    onSave();
                    Get.back();
                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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