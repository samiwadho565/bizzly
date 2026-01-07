import 'package:bizly/views/home/home_screen.dart';
import 'package:bizly/views/nav_bar/custom_nav_bar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tasks_screen/tasks_screen.dart';



class MainScreen extends StatefulWidget {
  int initialIndex;
  MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  @override
  Widget build(context) {
    return Scaffold(
      extendBody: true,
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
        return HomeScreen();
      case 1:
        return  TasksScreen();
      case 2:
        return HomeScreen();
      default:
        return HomeScreen();
    }
  }

}
