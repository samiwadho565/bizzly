// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:bizly/utils/app_colors.dart';
//
// import '../custom_drop_down.dart';
//
// // Enum for chart type
// enum ChartViewType { weekly, monthly, yearly }
//
// class AnalyticsLineChart extends StatefulWidget {
//   const AnalyticsLineChart({super.key});
//
//   @override
//   State<AnalyticsLineChart> createState() => _AnalyticsLineChartState();
// }
//
// class _AnalyticsLineChartState extends State<AnalyticsLineChart> {
//   ChartViewType viewType = ChartViewType.monthly; // default
//
//   // Labels for bottom axis
//   final List<String> weeklyLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
//   final List<String> monthlyLabels = [
//     'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'
//   ];
//   final List<String> yearlyLabels = ['2024','2025','2026'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Dropdown
//         Padding(
//           padding: const EdgeInsets.symmetric( vertical: 8),
//           child: Container(
//             decoration: BoxDecoration(
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ]
//             ),
//             child: CustomSearchDropdown(
//               width: 120,
//               hintText: "Select View",
//               items: const ["Weekly", "Monthly", "Yearly"],
//               selectedItem: _selectedText(),
//                 onChanged: (value) {
//                 setState(() {
//                   if (value == "Weekly") {
//                     viewType = ChartViewType.weekly;
//                   } else if (value == "Monthly") {
//                     viewType = ChartViewType.monthly;
//                   } else if (value == "Yearly") {
//                     viewType = ChartViewType.yearly;
//                   }
//                 });
//               },
//             ),
//           ),
//         ),
//
//
//         // Chart
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: LineChart(
//               _chartData(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   LineChartData _chartData() {
//     List<String> labels;
//     int maxX;
//
//     switch (viewType) {
//       case ChartViewType.weekly:
//         labels = weeklyLabels;
//         maxX = weeklyLabels.length - 1;
//         break;
//       case ChartViewType.monthly:
//         labels = monthlyLabels;
//         maxX = monthlyLabels.length - 1;
//         break;
//       case ChartViewType.yearly:
//         labels = yearlyLabels;
//         maxX = yearlyLabels.length - 1;
//         break;
//     }
//
//     return LineChartData(
//       gridData: FlGridData(
//         show: true,
//         drawVerticalLine: true,
//         horizontalInterval: 10,
//         verticalInterval: 1,
//         getDrawingHorizontalLine: (value) => FlLine(
//           color: Colors.white.withOpacity(0.1),
//           strokeWidth: 1,
//         ),
//         getDrawingVerticalLine: (value) => FlLine(
//           color: Colors.white.withOpacity(0.1),
//           strokeWidth: 1,
//         ),
//       ),
//       titlesData: FlTitlesData(
//         show: true,
//         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 30,
//             interval: 1,
//             getTitlesWidget: (value, meta) {
//               int index = value.toInt();
//               String text = (index >= 0 && index <= maxX) ? labels[index] : '';
//               return SideTitleWidget(
//                 axisSide: meta.axisSide,
//                 space: 8.0,
//                 child: Text(
//                   text,
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 10,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       borderData: FlBorderData(show: false),
//       minX: 0,
//       maxX: maxX.toDouble(),
//       minY: 0,
//       maxY: 60,
//       lineBarsData: [_lineBar(maxX)],
//     );
//   }
//
//   LineChartBarData _lineBar(int maxX) {
//     // Generate sample spots
//     List<FlSpot> spots = List.generate(
//       maxX + 1,
//           (index) => FlSpot(index.toDouble(), (10 + index * 5) % 60),
//     );
//
//     return LineChartBarData(
//       spots: spots,
//       isCurved: true,
//       curveSmoothness: 0.35,
//       color: AppColors.primaryLightTeal,
//       barWidth: 4,
//       isStrokeCapRound: true,
//       dotData: const FlDotData(show: false),
//       belowBarData: BarAreaData(
//         show: true,
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF075C61).withOpacity(0.4),
//             const Color(0xFF075C61).withOpacity(0.0),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//     );
//   }
//
//   String _selectedText() {
//     switch (viewType) {
//       case ChartViewType.weekly:
//         return "Weekly";
//       case ChartViewType.monthly:
//         return "Monthly";
//       case ChartViewType.yearly:
//         return "Yearly";
//     }
//   }
//
// }
