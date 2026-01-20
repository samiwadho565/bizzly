import 'package:bizly/views/home/home_screen.dart';
import 'package:bizly/views/nav_bar/custom_nav_bar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/home_widgets/side_bar.dart';
import '../expense_screen/expense_screen.dart';
import '../invoice_screen/invoice_screen.dart';
import '../projects/projects_screen.dart';
import '../tasks_screen/tasks_screen.dart';



class MainScreen extends StatefulWidget {
  int initialIndex;

  MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(context) {
    return Scaffold(
        key: _mainScaffoldKey, // 1. Key yahan lagayein
        extendBody: true,
        drawer: const CustomSideBar(),
      body: getCurrentScreen(_currentIndex),

      bottomNavigationBar: CustomBottomNavBar(
        //
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      // floatingActionButton: CustomSupportFAB(
      //
      // ),
    );

  }
  Widget getCurrentScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(openDrawer: () => _mainScaffoldKey.currentState?.openDrawer());
      case 1:
        return  ExpenseScreen();
      case 2:
        return InvoiceScreen();
      default:
        return TasksScreen();
    }
  }

}
