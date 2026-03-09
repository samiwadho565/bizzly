import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/business/controllers/business_activity_controller.dart';
import 'package:bizly/components/common/task_card_widget.dart';
import 'package:bizly/components/common/loader/loader.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/date_formats.dart';

class BusinessTasksTab extends StatelessWidget {
  const BusinessTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessActivityController>();
    return Obx(() {
      if (controller.isTasksLoading.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: FinancePulseLoader()),
          ),
        );
      }

      if (controller.tasksError.value.isNotEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(child: Text(controller.tasksError.value)),
          ),
        );
      }

      if (controller.tasks.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text("No tasks available")),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final TaskModel task = controller.tasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Get.toNamed(
                  Routes.taskDetailScreen,
                  arguments: task,
                );
              },
              child: TaskCardWidget(
                priority: task.priorityLevel,
                title: task.taskTitle,
                subtitle: task.description,
                date: _taskDate(task),
                assignTo: task.assignedEmployeeName ?? "-",
                status: task.displayStatus,
              ),
            ),
          );
        }, childCount: controller.tasks.length),
      );
    });
  }

  String _taskDate(TaskModel task) {
    final DateTime? parsed = task.dueDateParsed;
    if (parsed != null) return DateFormats.dMonY(parsed);
    final String raw = task.dueDate.trim();
    return raw.isEmpty ? "-" : raw;
  }
}
