import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/business/controllers/business_controller.dart';
import 'package:bizly/components/common/task_card_widget.dart';
import 'package:bizly/utils/date_formats.dart';

class BusinessTasksTab extends StatelessWidget {
  const BusinessTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessDetailController>();
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
        final task = controller.tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCardWidget(
            priority: task.priority,
            title: task.title,
            subtitle: task.description,
            date: task.dueDate == null
                ? "-"
                : DateFormats.dMonY(task.dueDate!),
            assignTo: task.assignedTo,
            status: task.status,
          ),
        );
      }, childCount: controller.tasks.length),
    );
  }
}
