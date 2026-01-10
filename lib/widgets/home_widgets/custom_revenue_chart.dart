import 'package:bizly/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_colors.dart';
import '../custom_drop_down.dart';


class WeeklyRevenueChart extends StatelessWidget {
  WeeklyRevenueChart({super.key});

  final HomeScreenController controller = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
                    controller.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 90,
                    height: 30,
                    child: CustomSearchDropdown(
                      hintText: "Select",
                      items: const ["Weekly", "Monthly", "Yearly"],
                      selectedItem: controller.viewType.value
                          .name
                          .capitalizeFirst ?? "Weekly",
                      onChanged: (value) {
                        controller.changeView(value??"Weekly");
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              /// Bars
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: controller.currentData
                    .map((bar) => Obx(()=> _buildBar(bar)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(RevenueBar bar) {
    double maxValue = controller.currentData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    const double chartDisplayHeight = 100;
    double calculatedHeight =
    maxValue > 0 ? (bar.value / maxValue) * chartDisplayHeight : 0;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectBar(bar),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
         Obx(()=> SizedBox(
                height: chartDisplayHeight + 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: calculatedHeight,
                        decoration: BoxDecoration(
                          color: bar.isSelected.value
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                      ),
                    ),
                    if (bar.isSelected.value)
                      Positioned(
                        bottom: calculatedHeight + 8,
                        child: _tooltip(bar.value.toString()),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(bar.day, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _tooltip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "\$$value",
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
