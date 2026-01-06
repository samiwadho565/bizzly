import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/on_boarding_controller.dart';
import '../../widgets/vertical_widget.dart';
class OnboardingScreen extends StatelessWidget {
  final controller = Get.put(OnboardingController());
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          /// 👇 Swipe detector (invisible)
          PageView.builder(
            controller: pageController,
            itemCount: controller.onboardingData.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (_, __) => const SizedBox(),
          ),

          /// 👇 UI (ignore touches so swipe passes through)
          const IgnorePointer(
            child: OnboardingContent(),
          ),
        ],
      ),
    );
  }
}


class OnboardingContent extends StatelessWidget {
  const OnboardingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 200,
          child: Image.asset(AppImages.logo, width: 200),
        ),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(left: 30, right: 30, top: 80, ),

            child: Obx(() {
              final data =
              controller.onboardingData[controller.currentIndex.value];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔥 TITLE (animated swap)
                  /// 🔥 TITLE
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      data['title']!,
                      key: ValueKey(data['title']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  /// 🔥 SUBTITLE
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      data['subtitle']!,
                      key: ValueKey(data['subtitle']),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  /// 🔥 DOTS
                  Row(
                    children: List.generate(
                      controller.onboardingData.length,
                          (i) => Obx(() => Container(
                        height: 8,
                        width: controller.currentIndex.value == i ? 24 : 8,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: controller.currentIndex.value == i
                              ? Colors.white
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      )),
                    ),
                  ),

                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      VerticalIndicatorWidget(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () => Get.offAllNamed('/login'),
                          child: const Text(
                            "Skip",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),


                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
