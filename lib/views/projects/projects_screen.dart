import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controllers/projects_screen_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_search_field.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/home_widgets/custom_app_bar.dart';
import '../../widgets/projects_screen_widgets/project_detail_card.dart';

class ProjectsScreen extends StatelessWidget {
  ProjectsScreen({super.key});

  final ProjectsScreenController controller =
  Get.put(ProjectsScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Projects"),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              addButton("Add Project"),
              const SizedBox(height: 20),

              /// 🔍 Search + Filter
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

                  /// Filter Button
                  Obx(() => GestureDetector(
                    onTap: controller.toggleFilter,
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),

              /// Filters Section
              Obx(() => controller.showFilter.value
                  ? Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Due Date",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            CustomTabBar(
                              isSmall: true,
                              options: const [
                                "Today",
                                "Tomorrow",
                                "This Week"
                              ],
                              selectedOption:
                              controller.selectedDue.value,
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
                            const Text(
                              "Priority",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            CustomTabBar(
                              isSmall: true,
                              options: const [
                                "Low",
                                "Medium",
                                "High"
                              ],
                              selectedOption:
                              controller.selectedPriority.value,
                              onSelect: controller.setPriority,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : const SizedBox()),

              const SizedBox(height: 20),

              /// Status Tabs
              Obx(() => CustomTabBar(
                options: const ["Active", "Completed"],
                selectedOption: controller.selectedStatus.value,
                onSelect: controller.setStatus,
              )),

              // const SizedBox(height: 20),

              /// Projects List
              Expanded(
                child: Obx(() => ListView.builder(
                  padding:
                  const EdgeInsets.only(top: 20, bottom: 70),
                  itemCount: controller.projects.length,
                  itemBuilder: (context, index) {
                    final project = controller.projects[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProjectDetailCard(
                        title: project["title"]!,
                        ownerName: project["owner"]!,
                        status: project["status"]!,
                        dateRange: project["date"]!,
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
