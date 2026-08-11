import 'package:bizly/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/tasks/controllers/tasks_screen_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/task_card_widget.dart';
import 'package:bizly/utils/date_formats.dart';
import 'package:bizly/components/common/loader/loader.dart';

class TasksScreen extends StatelessWidget {
  final VoidCallback? openDrawer;
  final bool embedded;

  TasksScreen({super.key, this.openDrawer, this.embedded = false});

  final TasksScreenController controller =
      Get.isRegistered<TasksScreenController>()
          ? Get.find<TasksScreenController>()
          : Get.put(TasksScreenController());

  @override
  Widget build(BuildContext context) {
    final Widget body = AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Column(
        children: [
          // ── Gradient Header ──────────────────────────────────
          _Header(
            controller: controller,
            openDrawer: openDrawer,
            embedded: embedded,
          ),

          // ── Status Tabs ──────────────────────────────────────
          _StatusBar(controller: controller),

          // ── Task List ────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                controller.clearSelectedFilters();
                await controller.fetchTasks();
              },
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: FinancePulseLoader());
                }
                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.error.value,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                final List<TaskModel> tasks = controller.filteredTasks;
                if (tasks.isEmpty) {
                  return _EmptyState(
                    status: controller.selectedStatus.value,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final TaskModel task = tasks[i];
                    return GestureDetector(
                      onTap: () =>
                          Get.toNamed(Routes.taskDetailScreen, arguments: task),
                      child: TaskCardWidget(
                        priority: task.priorityLevel,
                        title: task.taskTitle,
                        subtitle: task.description,
                        date: _taskDate(task),
                        assignTo: task.assignedEmployeeName ?? '—',
                        status: task.displayStatus,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );

    if (embedded) return body;
    return Scaffold(backgroundColor: const Color(0xFFF4F6FA), body: body);
  }

  String _taskDate(TaskModel task) {
    final DateTime? parsed = task.dueDateParsed;
    if (parsed != null) return DateFormats.dMonY(parsed);
    final String raw = task.dueDate.toString().trim();
    return raw.isEmpty ? '—' : raw;
  }
}

// ── Gradient Header ───────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.openDrawer,
    required this.embedded,
  });

  final TasksScreenController controller;
  final VoidCallback? openDrawer;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: menu + title + add
          Row(
            children: [
              if (!embedded)
                GestureDetector(
                  onTap: openDrawer,
                  child: Image.asset(AppImages.menu, height: 28,
                      color: Colors.white),
                ),
              if (!embedded) const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final String name =
                      controller.scopedBusinessName.value.trim();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tasks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (name.isNotEmpty)
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  );
                }),
              ),
              // Add button
              GestureDetector(
                onTap: () async {
                  final dynamic result = controller.isBusinessScoped
                      ? await Get.toNamed(
                          Routes.createTaskScreen,
                          arguments: <String, dynamic>{
                            'businessId': controller.scopedBusinessId.value,
                            'businessName': controller.scopedBusinessName.value,
                            'lockBusiness': true,
                          },
                        )
                      : await Get.toNamed(Routes.createTaskScreen);
                  if (result != null) controller.fetchTasks();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 16, color: AppColors.primaryDense),
                      SizedBox(width: 4),
                      Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDense,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search + filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.15), width: 1),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (_) => controller.tasks.refresh(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.45), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.white.withOpacity(0.55), size: 18),
                      suffixIcon:
                          controller.searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    controller.searchController.clear();
                                    controller.tasks.refresh();
                                  },
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.white.withOpacity(0.55),
                                      size: 16),
                                )
                              : const SizedBox.shrink(),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Filter toggle
              Obx(() => GestureDetector(
                    onTap: controller.toggleFilter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: controller.showFilter.value
                            ? Colors.white
                            : Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.20), width: 1),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: controller.showFilter.value
                            ? AppColors.primaryDense
                            : Colors.white,
                      ),
                    ),
                  )),
            ],
          ),

          // Expandable filter chips
          Obx(() => controller.showFilter.value
              ? _FilterSection(controller: controller)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── Filter Section ────────────────────────────────────────────────
class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.controller});
  final TasksScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Due date
          Text('Due Date',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Obx(() => _ChipRow(
                options: const ['Today', 'Tomorrow', 'This Week'],
                selected: controller.selectedDue.value,
                onTap: controller.setDue,
              )),
          const SizedBox(height: 12),
          // Priority
          Text('Priority',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Obx(() => _ChipRow(
                options: const ['Low', 'Medium', 'High'],
                selected: controller.selectedPriority.value,
                onTap: controller.setPriority,
                activeColor: const Color(0xFFFFB300),
              )),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onTap,
    this.activeColor = Colors.white,
  });

  final List<String> options;
  final String selected;
  final void Function(String) onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((o) {
        final bool isActive = selected.toLowerCase() == o.toLowerCase();
        return GestureDetector(
          onTap: () => onTap(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? activeColor
                    : Colors.white.withOpacity(0.20),
                width: 1,
              ),
            ),
            child: Text(
              o,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primaryDense : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Status Tab Bar ────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});
  final TasksScreenController controller;

  static const List<String> _tabs = ['To-Do', 'In Progress', 'Done'];

  int _activeIndex(String status) {
    final String s = status.toLowerCase();
    if (s == 'in progress') return 1;
    if (s == 'done') return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Obx(() {
        final int active = _activeIndex(controller.selectedStatus.value);
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Sliding pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOutCubic,
                alignment: Alignment(
                  -1.0 + (active * (2.0 / (_tabs.length - 1))),
                  0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / _tabs.length,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDense,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDense.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Labels
              Row(
                children: List.generate(_tabs.length, (i) {
                  final bool isActive = active == i;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.setStatus(_tabs[i]),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          child: Text(_tabs[i], textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.task_alt_rounded,
                size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            status.isEmpty ? 'No tasks yet' : 'No "$status" tasks',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "+ Add Task" to create one',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
