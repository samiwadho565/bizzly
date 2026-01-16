import 'package:bizly/widgets/add_button.dart';
import 'package:bizly/widgets/custom_button.dart';
import 'package:bizly/widgets/home_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:get/get.dart';

import '../../controllers/task_detail_controller.dart';
import '../../widgets/custom_app_bar_2.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskDetailController controller = Get.put(TaskDetailController());

  TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = controller.task;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(title: "Task Detail"),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: addButton(
                  "Edit",
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black54,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              /// Title + Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                  _priorityChip(task.priority),
                ],
              ),

              const SizedBox(height: 25),

              /// Company
              Text(
                "Company",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                task.companyName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              /// Assigned To
              Text(
                "Assigned To",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                task.assignedTo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 25),

              /// Description
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greyCard.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Due Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.dueDate != null
                        ? "${task.dueDate!.day}-${task.dueDate!.month}-${task.dueDate!.year}"
                        : "-",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Attachments
              if (task.attachments.isNotEmpty) ...[
                const Text(
                  "Attachments",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90, // thoda zyada height taake file name bhi dikh sake
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: task.attachments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      String file = task.attachments[index];
                      return GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.greyCard,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60, // same width as container
                              child: Text(
                                file,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
              ],

              /// Status
              const Text(
                "Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _statusSlider(controller.statusText, context),

              const SizedBox(height: 25),

              /// 🔹 Action Buttons
              CustomButton(
                text: "Update",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Priority Chip
  Widget _priorityChip(int priority) {
    String text =
    priority == 1 ? "High" : priority == 2 ? "Medium" : "Low";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: priority==1?AppColors.priorityHigh:priority==2?AppColors.priorityMedium:priority==3?AppColors.priorityLow:AppColors.greyCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 🔹 Status Selector (UI only)
  Widget _statusSelector(String currentStatus,) {
    final statuses = ["To-Do", "In Progress", "Done"];

    return Row(
      children: statuses.map((s) {
        bool selected = s == currentStatus;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: change status via controller
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                s,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statusSlider(String currentStatus,BuildContext context) {
    int statusValue = currentStatus == "To-Do"
        ? 0
        : currentStatus == "In Progress"
        ? 1
        : 2;

    Color statusColor = statusValue == 0
        ? Colors.orange
        : statusValue == 1
        ? Colors.blue
        : Colors.green;

    String statusText = statusValue == 0
        ? "To-Do"
        : statusValue == 1
        ? "In Progress"
        : "Done";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.tune, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    "Update Status",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              /// 🔹 Current Status Chip
      Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: controller.statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          controller.statusText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: controller.statusColor,
          ),
        ),
      ))
      ],
          ),

          const SizedBox(height: 18),

          /// 🔹 Slider
        Obx(() {
          return SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: controller.statusColor,
              inactiveTrackColor: controller.statusColor.withOpacity(0.2),
              thumbColor: controller.statusColor,
              overlayColor: controller.statusColor.withOpacity(0.15),
              trackHeight: 7,
            ),
            child: Slider(
              value: controller.statusValue.value.toDouble(),
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (value) {
                controller.statusValue.value = value.toInt();
              },
            ),
          );
        }),


          const SizedBox(height: 6),

          /// 🔹 Labels
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusLabel("To-Do", 0, controller.statusValue.value),
              _statusLabel("In Progress", 1, controller.statusValue.value),
              _statusLabel("Done", 2, controller.statusValue.value),
            ],
          )),

        ],
      ),
    );
  }

  /// 🔹 Label Widget
  Widget _statusLabel(String text, int index, int currentIndex) {
    bool isActive = index == currentIndex;

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        color: isActive ? Colors.black : Colors.grey,
      ),
    );
  }


}
