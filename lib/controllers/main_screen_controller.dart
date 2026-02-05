import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreenController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _initialized = false;

  int get currentIndex => _currentIndex.value;

  void setInitialIndex(int index) {
    if (_initialized) {
      return;
    }
    _currentIndex.value = index;
    _initialized = true;
  }

  void setIndex(int index) {
    _currentIndex.value = index;
  }
}
