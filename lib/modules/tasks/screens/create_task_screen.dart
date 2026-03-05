import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_drop_down.dart';
import 'package:bizly/components/common/custom_text_field.dart';
import 'package:bizly/modules/tasks/controllers/create_task_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/date_formats.dart';
import 'package:bizly/utils/form_validations.dart';

class CreateTaskScreen extends GetView<CreateTaskController> {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle sectionTitleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:  CustomAppBar2(title:  controller.isEditMode ? "Update Task" : "Create New Task"),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Form(
                    key: controller.createFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Task Title", style: sectionTitleStyle),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: "Enter task title...",
                          controller: controller.titleController,
                          validator: (v) => FormValidations.validateRequiredMin3(
                            v ?? '',
                            fieldName: "Task Title",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Assign to", style: sectionTitleStyle),
                        const SizedBox(height: 10),
                        Obx(() {
                          final List<String> names = controller.employees
                              .map((e) => e.fullName)
                              .where((e) => e.isNotEmpty)
                              .toList();
                          String? selectedName;
                          if (controller.selectedEmployeeId.value != null) {
                            for (final emp in controller.employees) {
                              if (emp.id == controller.selectedEmployeeId.value) {
                                selectedName = emp.fullName;
                                break;
                              }
                            }
                          }
                          return CustomSearchDropdown(
                            height: 50,
                            horizontalPadding: 12,
                            verticalPadding: 20,
                            iconSize: 25,
                            textStyle:
                                const TextStyle(fontSize: 15, color: Colors.black),
                            hintText: "Select Employee",
                            items: names,
                            selectedItem: selectedName,
                            onChanged: (val) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              int? id;
                              for (final emp in controller.employees) {
                                if (emp.fullName == val) {
                                  id = emp.id;
                                  break;
                                }
                              }
                              controller.selectedEmployeeId.value = id;
                            },
                          );
                        }),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Priority", style: sectionTitleStyle),
                                  const SizedBox(height: 10),
                                  Obx(
                                    () => CustomSearchDropdown(
                                      height: 50,
                                      horizontalPadding: 12,
                                      verticalPadding: 20,
                                      iconSize: 25,
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                      hintText: "Select",
                                      items: const ["High", "Medium", "Low"],
                                      selectedItem: _cap(controller.selectedPriorityCreate.value),
                                      onChanged: (val) {
                                        if (val == null) return;
                                        controller.selectedPriorityCreate.value =
                                            val.toLowerCase();
                                      },
                                    ),
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
                                  Obx(
                                    () => GestureDetector(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        final DateTime? date =
                                            await AppUtils.pickDate();
                                        if (date != null) {
                                          controller.selectedDueDate.value = date;
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.textField,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              controller.selectedDueDate.value == null
                                                  ? "Pick Date"
                                                  : DateFormats.dMonY(
                                                      controller.selectedDueDate.value!),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: controller.selectedDueDate.value == null
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_month,
                                              size: 18,
                                              color: Colors.grey.shade600,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text("Status", style: sectionTitleStyle),
                        const SizedBox(height: 10),
                        Obx(
                          () => CustomSearchDropdown(
                            height: 50,
                            horizontalPadding: 12,
                            verticalPadding: 20,
                            iconSize: 25,
                            textStyle: const TextStyle(fontSize: 15, color: Colors.black),
                            hintText: "Select Status",
                            items: const ["To Do", "In Progress", "Done"],
                            selectedItem: _displayStatus(controller.selectedStatusCreate.value),
                            onChanged: (val) {
                              if (val == null) return;
                              final String normalized = val.toLowerCase() == 'to do'
                                  ? 'to do'
                                  : val.toLowerCase();
                              controller.selectedStatusCreate.value = normalized;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Description", style: sectionTitleStyle),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: "Write task details here...",
                          controller: controller.descriptionController,
                          maxLine: 4,
                          validator: (v) => FormValidations.validateRequired(
                            v ?? '',
                            fieldName: "Description",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Attachments", style: sectionTitleStyle),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: controller.pickAttachments,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: AppColors.greyCard.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Upload Images",
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.existingAttachments.isEmpty &&
                              controller.selectedAttachments.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final List<Widget> items = <Widget>[
                            ...controller.existingAttachments.map((attachment) {
                              final bool isRemoving = attachment.id != null &&
                                  controller.removingAttachmentIds
                                      .contains(attachment.id);
                              return GestureDetector(
                                onTap: () => _openNetworkImagePreview(
                                  context,
                                  attachment.fileUrl,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: attachment.fileUrl,
                                        width: 95,
                                        height: 95,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          width: 95,
                                          height: 95,
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 95,
                                          height: 95,
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: GestureDetector(
                                        onTap: isRemoving
                                            ? null
                                            : () => controller
                                                .removeExistingAttachment(attachment),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.black87,
                                            shape: BoxShape.circle,
                                          ),
                                          child: isRemoving
                                              ? const Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 1.5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ];

                          items.addAll(
                            List.generate(
                              controller.selectedAttachments.length,
                              (index) {
                                final File file = controller.selectedAttachments[index];
                                return GestureDetector(
                                  onTap: () => _openLocalImagePreview(context, file),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          file,
                                          width: 95,
                                          height: 95,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        right: 4,
                                        top: 4,
                                        child: GestureDetector(
                                          onTap: () => controller.removeAttachmentAt(index),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: Colors.black87,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );

                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: items,
                          );
                        }),
                        const SizedBox(height: 40),
                        Obx(
                          () => CustomButton(
                            text: controller.isEditMode ? "Update Task" : "Create Task",
                            isLoading: controller.isSubmitting.value,
                            onPressed: controller.isSubmitting.value
                                ? () {}
                                : () async {
                                    await controller.submitTask();
                                  },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _cap(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  String _displayStatus(String raw) {
    if (raw.toLowerCase() == 'to do') return 'To Do';
    if (raw.toLowerCase() == 'in progress') return 'In Progress';
    if (raw.toLowerCase() == 'done') return 'Done';
    return raw;
  }

  void _openLocalImagePreview(BuildContext context, File file) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () => _downloadLocalImage(file),
                icon: const Icon(Icons.download, color: Colors.white),
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(file, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadLocalImage(File source) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String ext = source.path.split('.').last;
      final String targetPath =
          '${dir.path}/task_local_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await source.copy(targetPath);
      AppUtils.showAppSnackbar(
        "Downloaded",
        "Saved to $targetPath",
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.success,
      );
    } catch (_) {
      AppUtils.showAppSnackbar(
        "Error",
        "Unable to save image",
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.error,
      );
    }
  }

  void _openNetworkImagePreview(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () => _downloadNetworkImage(imageUrl),
                icon: const Icon(Icons.download, color: Colors.white),
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadNetworkImage(String imageUrl) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String ext = _extractExt(imageUrl);
      final String filePath =
          '${dir.path}/task_image_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Dio().download(imageUrl, filePath);
      AppUtils.showAppSnackbar(
        "Downloaded",
        "Saved to $filePath",
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.success,
      );
    } catch (_) {
      AppUtils.showAppSnackbar(
        "Error",
        "Unable to download image",
        snackPosition: SnackPosition.BOTTOM,
        type: AppSnackType.error,
      );
    }
  }

  String _extractExt(String url) {
    final Uri? uri = Uri.tryParse(url);
    final String path = uri?.path ?? '';
    final String last = path.split('.').last.toLowerCase();
    if (last == 'png' || last == 'jpg' || last == 'jpeg' || last == 'webp') {
      return last;
    }
    return 'jpg';
  }
}
