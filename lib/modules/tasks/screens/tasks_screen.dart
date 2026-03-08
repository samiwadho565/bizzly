import 'package:bizly/components/home/custom_app_bar.dart';
import 'package:bizly/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/add_button.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/custom_tab_bar.dart';
import 'package:bizly/components/common/task_card_widget.dart';
import 'package:bizly/components/common/top_border_ccontainer.dart';
import 'package:bizly/utils/date_formats.dart';

import '../../../components/common/loader/loader.dart';
import '../../business/screens/business_detail_screen.dart';
// import 'tasks_screen_controller.dart';

class TasksScreen extends GetView<TasksScreenController> {
  final VoidCallback? openDrawer;

  TasksScreen({super.key, this.openDrawer});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Tasks",
        leading: Image.asset(AppImages.menu, height: 40),
        onLeadingTap: () {
          openDrawer?.call();
        },
      ),
      body:  TopBorderContainer(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            controller.clearSelectedFilters();
            await controller.fetchTasks();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            /// 🔹 Top Section (Add button, search, filters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 20),

                    addButton(
                      "Add Task",
                      onTap: () async {
                        final dynamic result =
                            await Get.toNamed(Routes.createTaskScreen);
                        if (result != null) {
                          controller.fetchTasks();
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    /// Search + Filter
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchField(
                            hintText: "Search here...",
                            controller: controller.searchController,
                            onChanged: (_) => controller.tasks.refresh(),
                            onClear: () => controller.tasks.refresh(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Obx(() => GestureDetector(
                          onTap: controller.toggleFilter,
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300,width: 0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 9, horizontal: 5),
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_list_outlined,
                                        size: 20,
                                        color: Colors.grey.shade600),
                                    const SizedBox(width: 5),
                                    Text(
                                      controller.showFilter.value
                                          ? "Hide"
                                          : "Filters",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                    /// Filters (Responsive)
                    Obx(
                      () => controller.showFilter.value
                          ? const SizedBox(height: 15)
                          : const SizedBox.shrink(),
                    ),
                    Obx(() => controller.showFilter.value
                        ? LayoutBuilder(
                      builder: (context, constraints) {
                        bool isSmallScreen = constraints.maxWidth <= 335;

                        Widget dueDateWidget = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Due Date",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                           Obx(()=> CustomTabBar(
                                isSmall: true,
                             allowUnselectOnReselect: true,
                             options: const ["Today", "Tomorrow", "This Week"],
                                selectedOption: controller.selectedDue.value,
                                onSelect: controller.setDue,
                              ),
                            ),
                          ],
                        );

                        Widget priorityWidget = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Priority",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.center,
                              child:  Obx(()=>  CustomTabBar(
                                allowUnselectOnReselect: true,
                                  isSmall: true,
                                  options: const ["Low", "Medium", "High"],
                                  selectedOption: controller.selectedPriority.value,
                                  onSelect: controller.setPriority,
                                ),
                              ),
                            ),
                          ],
                        );

                        /// Small Screen → Column
                        if (isSmallScreen) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dueDateWidget,
                              const SizedBox(height: 20),
                              priorityWidget,
                            ],
                          );
                        }

                        /// Normal Screen → Row
                        return Row(
                          children: [
                            Expanded(child: dueDateWidget),
                            const SizedBox(width: 20),
                            Expanded(child: priorityWidget),
                          ],
                        );
                      },
                    )
                        : const SizedBox()),
                    const SizedBox(height: 20),

                    /// Filters
                    // Obx(() => controller.showFilter.value
                    //     ? const SizedBox(height: 20)
                    //     : const SizedBox()),
                  ],
                ),
              ),
            ),

            /// 🔥 STICKY STATUS TAB
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabBarDelegate(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Obx(() => CustomTabBar(
                        options: const ["To-Do", "In Progress", "Done"],
                        selectedOption:
                        controller.selectedStatus.value,
                        onSelect: controller.setStatus,
                      )),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔹 Task List
            SliverPadding(
              // padding:
            padding: EdgeInsets.only(top: 20,bottom: 100,left: 20,right: 20),
              sliver: Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: FinancePulseLoader(),
                      ),
                    ),
                  );
                }
                if (controller.error.value.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(child: Text(controller.error.value)),
                    ),
                  );
                }
                if (controller.filteredTasks.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: Text("No tasks found")),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = controller.filteredTasks[index];
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            Routes.taskDetailScreen,
                            arguments: task,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
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
                    },
                    childCount: controller.filteredTasks.length,
                  ),
                );
              }),
            ),
            ],
          ),
        ),
      ),

    );
  }

  String _taskDate(TaskModel task) {
    final DateTime? parsed = task.dueDateParsed;
    if (parsed != null) return DateFormats.dMonY(parsed);
    final String raw = task.dueDate.toString().trim();
    return raw.isEmpty ? "-" : raw;
  }
}
