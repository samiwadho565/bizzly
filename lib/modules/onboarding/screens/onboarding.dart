import 'package:bizly/assets/images.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bizly/modules/onboarding/controllers/on_boarding_controller.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/services/local_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final OnboardingController controller = Get.find<OnboardingController>();
  late final PageController _pageCtrl = PageController();

  // Per-page animation
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<_Slide> _slides = [
    _Slide(
      icon: Icons.business_center_rounded,
      iconColor: Color(0xFF64B5F6),
      bgColor: Color(0xFF0A1F5C),
      title: 'Manage Your\nBusinesses',
      subtitle:
          'Add and oversee multiple businesses from a single dashboard — fast and effortless.',
    ),
    _Slide(
      icon: Icons.receipt_long_rounded,
      iconColor: Color(0xFF81C784),
      bgColor: Color(0xFF063A1E),
      title: 'Vouchers &\nAccounting',
      subtitle:
          'Create vouchers, manage Chart of Accounts, and keep your books perfectly balanced.',
    ),
    _Slide(
      icon: Icons.bar_chart_rounded,
      iconColor: Color(0xFFFFB74D),
      bgColor: Color(0xFF3D2000),
      title: 'Reports &\nInsights',
      subtitle:
          'View Trial Balance, Income Statement & Balance Sheet — all in real time.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    controller.onPageChanged(index);
    _animCtrl.reset();
    _animCtrl.forward();
  }

  Future<void> _finish() async {
    await LocalStorage.setOnboardingSeen(true);
    Get.offAllNamed(Routes.loginScreen);
  }

  void _next() {
    final int current = controller.currentIndex.value;
    if (current < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Obx(() {
        final int idx = controller.currentIndex.value;
        final _Slide slide = _slides[idx];
        final bool isLast = idx == _slides.length - 1;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDense,
                slide.bgColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // ── Top bar ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: Image.asset(AppImages.bizzlyLogo,
                                  fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Bizzly',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        // Skip
                        if (!isLast)
                          GestureDetector(
                            onTap: _finish,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Slide content ────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: _slides.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (_, i) => FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: _SlideContent(slide: _slides[i]),
                        ),
                      ),
                    ),
                  ),

                  // ── Dots ─────────────────────────────────────
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: 7,
                            width: controller.currentIndex.value == i ? 24 : 7,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: controller.currentIndex.value == i
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      )),

                  const SizedBox(height: 28),

                  // ── Next / Get Started ───────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: GestureDetector(
                      onTap: _next,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.20),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? 'Get Started' : 'Next',
                              style: TextStyle(
                                color: slide.bgColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLast
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              color: slide.bgColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────
class _Slide {
  const _Slide({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
}

// ── Slide content widget ──────────────────────────────────────────
class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.iconColor.withOpacity(0.10),
                border: Border.all(
                  color: slide.iconColor.withOpacity(0.30),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: slide.iconColor.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(slide.icon, size: 56, color: slide.iconColor),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 15,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
