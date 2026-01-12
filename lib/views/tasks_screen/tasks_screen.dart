import 'package:bizly/widgets/home_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tasks_screen_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_search_field.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/task_card_widget.dart';
// import 'tasks_screen_controller.dart';

class TasksScreen extends StatelessWidget {
  TasksScreen({super.key});

  final TasksScreenController controller = Get.put(TasksScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:CustomAppBar(title: "Tasks"),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(40), topLeft: Radius.circular(40)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Add Task Button
              addButton("Add Task"),
              const SizedBox(height: 20),

              /// Search + Filter Row
              Row(
                children: [
                  Expanded(
                    child: CustomSearchField(
                      hintText: "Search here...",
                      controller: controller.searchController,
                      onChanged: (val) {
                        print("Searching: $val");
                      },
                      onClear: () {
                        print("Search cleared");
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Filter Icon
                  Obx(() => GestureDetector(
                    onTap: controller.toggleFilter,
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list_outlined,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                controller.showFilter.value
                                    ? "Hide"
                                    : "Filters",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),

              const SizedBox(height: 20),

              /// Filters
              Obx(() => controller.showFilter.value
                  ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Due Date",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        CustomTabBar(
                          isSmall: true,
                          options: const ["Today", "Tomorrow", "This Week"],
                          selectedOption: controller.selectedDue.value,
                          onSelect: controller.setDue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Priority",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        CustomTabBar(
                          isSmall: true,
                          options: const ["Low", "Medium", "High"],
                          selectedOption: controller.selectedPriority.value,
                          onSelect: controller.setPriority,
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : const SizedBox()),

              const SizedBox(height: 20),

              /// Status Tab
              const Text("Status",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => CustomTabBar(
                options: const ["To-Do", "In Progress", "Done"],
                selectedOption: controller.selectedStatus.value,
                onSelect: controller.setStatus,
              )),

              const SizedBox(height: 20),

              /// Task List
              Expanded(
                child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.only(top: 20, bottom: 130),
                  itemCount: controller.tasks.length,
                  itemBuilder: (context, index) {
                    final task = controller.tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TaskCardWidget(
                        title: task["title"]!,
                        subtitle: task["subtitle"]!,
                        date: task["date"]!,
                        userName: task["user"]!,
                        status: task["status"]!,
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
