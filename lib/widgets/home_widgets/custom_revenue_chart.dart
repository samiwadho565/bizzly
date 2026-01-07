import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';
import '../../utils/enum.dart';
import '../custom_drop_down.dart';


class WeeklyRevenueChart extends StatefulWidget {
  const WeeklyRevenueChart({super.key});

  @override
  State<WeeklyRevenueChart> createState() => _WeeklyRevenueChartState();
}

class _WeeklyRevenueChartState extends State<WeeklyRevenueChart> {
  RevenueViewType viewType = RevenueViewType.weekly;

  /// ---------------- DATA ----------------

  List<RevenueBar> get _weeklyData => [
    RevenueBar(day: "Mon", value: 40),
    RevenueBar(day: "Tue", value: 55),
    RevenueBar(day: "Wed", value: 75),
    RevenueBar(day: "Thu", value: 85),
    RevenueBar(day: "Fri", value: 100),
    RevenueBar(day: "Sat", value: 80, isSelected: true),
    RevenueBar(day: "Sun", value: 60),
  ];

  List<RevenueBar> get _monthlyData => [
    RevenueBar(day: "Jan", value: 60),
    RevenueBar(day: "Feb", value: 75),
    RevenueBar(day: "Mar", value: 90),
    RevenueBar(day: "Apr", value: 70),
    RevenueBar(day: "May", value: 110, isSelected: true),
    RevenueBar(day: "Jun", value: 95),
    RevenueBar(day: "Jul", value: 85),
  ];

  List<RevenueBar> get _yearlyData => [
    RevenueBar(day: "2024", value: 80),
    RevenueBar(day: "2025", value: 100, ),
    RevenueBar(day: "2026", value: 200,isSelected: true),
  ];

  List<RevenueBar> get _currentData {
    switch (viewType) {
      case RevenueViewType.weekly:
        return _weeklyData;
      case RevenueViewType.monthly:
        return _monthlyData;
      case RevenueViewType.yearly:
        return _yearlyData;
    }
  }

  String get _title {
    switch (viewType) {
      case RevenueViewType.weekly:
        return "Weekly Revenue";
      case RevenueViewType.monthly:
        return "Monthly Revenue";
      case RevenueViewType.yearly:
        return "Yearly Revenue";
    }
  }

  /// ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   // color: Colors.red,
            //   child: CustomSearchDropdown(
            //     height: 50,
            //   horizontalPadding: 12,
            //    verticalPadding: 20,
            //    iconSize: 25,
            //    textStyle: TextStyle(fontSize: 16, color: Colors.black),
            //    enableSearch: true,
            //     hintText: "Select Business",
            //     items: const ["Fixonto", "SilverSpoon", "TechNova", "GreenLeaf"],
            //     selectedItem: _selectedText(),
            //     onChanged: (value) {
            //       setState(() {
            //         if (value == "Weekly") {
            //           viewType = RevenueViewType.weekly;
            //         } else if (value == "Monthly") {
            //           viewType = RevenueViewType.monthly;
            //         } else {
            //           viewType = RevenueViewType.yearly;
            //         }
            //       });
            //     },
            //   ),
            // ),
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                /// ✅ Custom Dropdown
                SizedBox(
                  width: 90,
                  height: 30,
                  child: CustomSearchDropdown(
                    hintText: "Select",
                    items: const ["Weekly", "Monthly", "Yearly"],
                    selectedItem: _selectedText(),
                    onChanged: (value) {
                      setState(() {
                        if (value == "Weekly") {
                          viewType = RevenueViewType.weekly;
                        } else if (value == "Monthly") {
                          viewType = RevenueViewType.monthly;
                        } else {
                          viewType = RevenueViewType.yearly;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            /// Bars
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _currentData.map(_buildBar).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- BAR ----------------

  Widget _buildBar(RevenueBar bar) {
    // 1. Pehle data mein se maximum value nikalen
    double maxValue = _currentData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // 2. Chart ki total available height define karein
    const double chartDisplayHeight = 100;

    // 3. Current bar ki height calculate karein (Percentage wise)
    // Formula: (Current Value / Max Value) * Total Height
    double calculatedHeight = maxValue > 0
        ? (bar.value / maxValue) * chartDisplayHeight
        : 0;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: chartDisplayHeight + 30, // 30px extra space tooltip ke liye
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer( // Smooth height change ke liye
                    duration: const Duration(milliseconds: 300),
                    height: calculatedHeight,
                    decoration: BoxDecoration(
                      color: bar.isSelected
                          ? AppColors.primaryTeal
                          : AppColors.primaryLightTeal.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
                if (bar.isSelected)
                  Positioned(
                    // Bar ki actual height se 8 pixel upar tooltip dikhao
                    bottom: calculatedHeight + 8,
                    child: _tooltip(bar.value.toString()), // Dynamic value tooltip mein
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(bar.day, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  String _selectedText() {
    switch (viewType) {
      case RevenueViewType.weekly:
        return "Weekly";
      case RevenueViewType.monthly:
        return "Monthly";
      case RevenueViewType.yearly:
        return "Yearly";
      default:
        return "Weekly";
    }
  }

  Widget _tooltip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "\$$value",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}

/// ---------------- MODEL ----------------

class RevenueBar {
  final String day;
  final double value;
  final bool isSelected;

  RevenueBar({
    required this.day,
    required this.value,
    this.isSelected = false,
  });
}
