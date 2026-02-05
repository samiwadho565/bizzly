import 'package:bizly/controllers/main_screen_controller.dart';
import 'package:bizly/views/home/home_screen.dart';
import 'package:bizly/views/nav_bar/custom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/home_widgets/side_bar.dart';
import '../expense_screen/expense_screen.dart';
import '../invoice_screen/invoice_screen.dart';
import '../tasks_screen/tasks_screen.dart';

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
