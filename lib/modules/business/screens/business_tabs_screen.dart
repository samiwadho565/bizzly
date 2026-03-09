import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/components/common/custom_tab_bar.dart';
import 'package:bizly/modules/business/controllers/business_activity_controller.dart';
import 'package:bizly/modules/business/screens/tabs/business_invoices_tab.dart';
import 'package:bizly/modules/business/screens/tabs/business_expenses_tab.dart';
import 'package:bizly/modules/business/screens/tabs/business_tasks_tab.dart';

class BusinessTabsScreen extends StatefulWidget {
  const BusinessTabsScreen({super.key});

  @override
  State<BusinessTabsScreen> createState() => _BusinessTabsScreenState();
}

class _BusinessTabsScreenState extends State<BusinessTabsScreen> {
  late final BusinessActivityController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BusinessActivityController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar2(
        title: "Business Details",
        actions: [
          IconButton(
            onPressed: controller.fetchBusinessActivity,
            icon: const Icon(Icons.refresh, color: Colors.black54),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(
                  () => CustomTabBar(
                    options: const [
                      "Invoices",
                      "Expenses",
                      "Tasks",
                    ],
                    selectedOption: controller.selectedTab.value,
                    onSelect: controller.changeTab,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            sliver: Obx(() {
              switch (controller.selectedTab.value) {
                case 'Invoices':
                  return const BusinessInvoicesTab();
                case 'Expenses':
                  return const BusinessExpensesTab();
                case 'Tasks':
                  return const BusinessTasksTab();
                default:
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text("No data available"),
                      ),
                    ),
                  );
              }
            }),
          ),
        ],
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 90.0;

  @override
  double get maxExtent => 90.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant StickyTabBarDelegate oldDelegate) => false;
}
