import 'package:bizly/modules/nav/controllers/main_screen_controller.dart';
import 'package:bizly/modules/home/screens/home_screen.dart';
import 'package:bizly/modules/nav/screens/custom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/home/side_bar.dart';
import 'package:bizly/modules/expense/screens/expense_screen.dart';
import 'package:bizly/modules/invoice/screens/invoice_screen.dart';
import 'package:bizly/modules/tasks/screens/tasks_screen.dart';

class MainScreen extends GetView<MainScreenController> {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.setInitialIndex(initialIndex);
    return Scaffold(
      key: controller.scaffoldKey,
      extendBody: true,
      drawer: const CustomSideBar(),
      body: Obx(() => _getCurrentScreen(controller.currentIndex)),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          currentIndex: controller.currentIndex,
          onTap: controller.setIndex,
        ),
      ),
    );
  }

  Widget _getCurrentScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          //openDrawer: () => controller.scaffoldKey.currentState?.openDrawer(),
        );
      case 1:
        return ExpenseScreen();
      case 2:
        return InvoiceScreen();
      default:
        return TasksScreen();
    }
  }
}
