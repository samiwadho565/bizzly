import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/components/common/custom_drop_down.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle sectionTitleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: AppColors.background, // Grayish background
      appBar: const CustomAppBar2(title: "Create New Task"),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 Task Title
                    Text("Task Title", style: sectionTitleStyle),
                    const SizedBox(height: 10),
                    CustomTextField(
                      hintText: "Enter task title...",
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 Company Selection
                    Text("Assign to", style: sectionTitleStyle),
                    const SizedBox(height: 10),
                    CustomSearchDropdown(
                      height: 50,
                      horizontalPadding: 12,
                      verticalPadding: 20,
                      iconSize: 25,
                      textStyle: const TextStyle(fontSize: 15, color: Colors.black),

                      hintText: "Select Employee",
                      items: const ["Employee A", "Employee B", "Employee X"],
                      onChanged: (val) {},
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 Priority & Due Date Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Priority", style: sectionTitleStyle),
                              const SizedBox(height: 10),
                              CustomSearchDropdown(
                                height: 50,
                                horizontalPadding: 12,
                                verticalPadding: 20,
                                iconSize: 25,
                                textStyle: const TextStyle(fontSize: 15, color: Colors.black),

                                hintText: "Select",
                                items: const ["High", "Medium", "Low"],
                                onChanged: (val) {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Due Date", style: sectionTitleStyle),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => AppUtils.pickDate(),
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.textField,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Pick Date", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                      Icon(Icons.calendar_month, size: 18, color: Colors.grey.shade600),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 Description
                    Text("Description", style: sectionTitleStyle),
                    const SizedBox(height: 10),
                    CustomTextField(
                      hintText: "Write task details here...",
                      maxLine: 4,
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 Attachments UI
                    Text("Attachments", style: sectionTitleStyle),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        // File picker logic
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.greyCard.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 30),
                            SizedBox(height: 8),
                            Text("Upload Files (PDF, JPG, PNG)", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// 🔹 Create Button
                    CustomButton(
                      text: "Create Task",
                      onPressed: () {
                        Get.back(); // Task create hone ke baad wapis jane ke liye
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}