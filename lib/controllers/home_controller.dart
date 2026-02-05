import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/enum.dart';
import '../../utils/app_colors.dart';

class HomeScreenController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var viewType = RevenueViewType.weekly.obs;

  late List<RevenueBar> weeklyData;
  late List<RevenueBar> monthlyData;
  late List<RevenueBar> yearlyData;

  @override
  void onInit() {
    super.onInit();

    weeklyData = [
      RevenueBar(day: "Mon", value: 40),
      RevenueBar(day: "Tue", value: 55),
      RevenueBar(day: "Wed", value: 75),
      RevenueBar(day: "Thu", value: 85),
      RevenueBar(day: "Fri", value: 100),
      RevenueBar(day: "Sat", value: 80),
      RevenueBar(day: "Sun", value: 60),
    ];

    monthlyData = [
      RevenueBar(day: "Jan", value: 60),
      RevenueBar(day: "Feb", value: 75),
      RevenueBar(day: "Mar", value: 90),
      RevenueBar(day: "Apr", value: 70),
      RevenueBar(day: "May", value: 110),
      RevenueBar(day: "Jun", value: 95),
      RevenueBar(day: "Jul", value: 85),
      RevenueBar(day: "Aug", value: 75),
      RevenueBar(day: "Sep", value: 70),
      RevenueBar(day: "Oct", value: 110),
      RevenueBar(day: "Nov", value: 95),
      RevenueBar(day: "Dec", value: 90),
    ];

    yearlyData = [
      RevenueBar(day: "2024", value: 80),
      RevenueBar(day: "2025", value: 100),
      RevenueBar(day: "2026", value: 200),
    ];

    // Default first bar selected for each
    weeklyData[0].isSelected.value = true;
    monthlyData[0].isSelected.value = true;
    yearlyData[0].isSelected.value = true;
  }

  List<RevenueBar> get currentData {
    switch (viewType.value) {
      case RevenueViewType.weekly:
        return weeklyData;
      case RevenueViewType.monthly:
        return monthlyData;
      case RevenueViewType.yearly:
        return yearlyData;
    }
  }

  String get title {
    switch (viewType.value) {
      case RevenueViewType.weekly:
        return "Weekly Revenue";
      case RevenueViewType.monthly:
        return "Monthly Revenue";
      case RevenueViewType.yearly:
        return "Yearly Revenue";
    }
  }

  void selectBar(RevenueBar bar) {
    for (var b in currentData) {
      b.isSelected.value = false;
    }
    bar.isSelected.value = true;
    update(); // Update GetX observers
  }

  void changeView(String value) {
    switch (value) {
      case "Weekly":
        viewType.value = RevenueViewType.weekly;
        break;
      case "Monthly":
        viewType.value = RevenueViewType.monthly;
        break;
      case "Yearly":
        viewType.value = RevenueViewType.yearly;
        break;
    }
  }
}



class RevenueBar {
  final String day;
  final double value;
  RxBool isSelected;

  RevenueBar({
    required this.day,
    required this.value,
    bool isSelected = false, // default value
  }) : isSelected = isSelected.obs;
}

