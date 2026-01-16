import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/widgets/invoice_screen_widgets/invoice_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/business_controller.dart';
import '../../widgets/business_screen_widgets/status_card.dart';
import '../../widgets/custom_app_bar_2.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../widgets/drop_down_menu/drop_down_menu.dart';
import '../../widgets/task_card_widget.dart';

class BusinessDetailScreen extends StatelessWidget {
  BusinessDetailScreen({super.key});

  final controller = Get.put(BusinessDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(title: "Service"),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40),
          ),
        ),
        child: CustomScrollView(
          slivers: [
            /// --- Top Section ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    addDropdownButton(leftText: 'Quick Actions', title: "Add"),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        StatCard(
                          title: "Total Revenue",
                          value: "\$4,250,000",
                          icon: Icon(Icons.attach_money, color: Colors.green),
                          backgroundColor: Color(0xFFF7FBF7),
                          contentColor: Colors.green,
                        ),
                        StatCard(
                          title: "Team Members",
                          value: "2",
                          icon: Icon(
                            Icons.groups,
                            color: Colors.blue,
                          ),
                          backgroundColor: Color(0xFFF1F7FF),
                          contentColor: Colors.blue,
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatCard(
                          title: "Total Expenses",
                          value: "\$1,250",
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: Colors.red,
                          ),
                          backgroundColor: const Color(0xFFFFF5F5),
                          contentColor: Colors.red.shade400,
                        ),

                        StatCard(
                          title: "Pending Tasks",
                          value: "2",
                          icon: const Icon(
                            Icons.assignment_outlined,
                            color: Colors.orange,
                          ),
                          backgroundColor: const Color(0xFFFFF9F0),
                          contentColor: Colors.orange.shade400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            /// --- Sticky TabBar ---
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabBarDelegate(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(
                    () => CustomTabBar(
                      options: const [
                        // "Overview",
                        "Invoices",
                        "Expenses",
                        "Tasks",
                        "Team",
                      ],
                      selectedOption: controller.selectedTab.value,
                      onSelect: controller.changeTab,
                    ),
                  ),
                ),
              ),
            ),

            /// --- Dynamic Content ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: Obx(() {
                if (controller.selectedTab.value == 'Tasks') {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = controller.tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCardWidget(
                          priority: task.priority,
                          title: task.title,
                          subtitle: task.description,
                          date: task.dueDate.toString(),
                          assignTo: task.assignedTo,
                          status: task.status,
                        ),
                      );
                    }, childCount: controller.tasks.length),
                  );
                }
                if (controller.selectedTab.value == 'Invoices') {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final  invoices  = controller.invoices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InvoiceCard(
                          // title: task["title"]!,
                          // subtitle: task["subtitle"]!,
                          // date: task["date"]!,
                          // userName: task["user"]!,

                          status:  invoices["status"]!,
                          clientName: invoices['client']!,
                          businessName: invoices['business']!,
                          itemName:  invoices['item']!,
                          amount: '2000',
                        ),
                      );
                    }, childCount: controller.invoices.length),
                  );
                }
                /// Default empty state (for now)
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("No data available"),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 90.0; // TabBar ki height + padding
  @override
  double get maxExtent => 90.0;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Colors.white, // Sticky hone par background color
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant StickyTabBarDelegate oldDelegate) => false;
}
