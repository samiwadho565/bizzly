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
    RevenueBar(day: "2024", value: 160),
    RevenueBar(day: "2025", value: 220, isSelected: true),
    RevenueBar(day: "2026", value: 190),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  width: 80,
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
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: bar.value,
                    decoration: BoxDecoration(
                      color: bar.isSelected
                          ? AppColors.primaryTeal
                          : AppColors.primaryLightTeal.withOpacity(0.4),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                    ),
                  ),
                ),
                if (bar.isSelected)
                  Positioned(
                    top: 10,
                    child: _tooltip(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(bar.day),
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

  Widget _tooltip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "\$7,302.80",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
