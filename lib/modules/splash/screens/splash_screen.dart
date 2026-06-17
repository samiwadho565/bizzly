import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo: scale + fade
  late final AnimationController _logoCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  );
  late final Animation<double> _logoScale = Tween<double>(begin: 0.5, end: 1.0)
      .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
  late final Animation<double> _logoFade = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
          parent: _logoCtrl,
          curve: const Interval(0.0, 0.45, curve: Curves.easeIn)));

  // Text: slide-up + fade
  late final AnimationController _textCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _textFade = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
  late final Animation<Offset> _textSlide =
      Tween<Offset>(begin: const Offset(0, 0.45), end: Offset.zero).animate(
          CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
  late final Animation<double> _taglineFade =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _textCtrl,
          curve: const Interval(0.45, 1.0, curve: Curves.easeIn)));

  // Pulsing dots
  late final AnimationController _dotCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _logoCtrl.forward().then((_) {
      if (mounted) _textCtrl.forward();
    });
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    final bool onboardingSeen = await LocalStorage.getOnboardingSeen();
    final bool rememberMe = await LocalStorage.getRememberMe();
    final String? token = await LocalStorage.getAuthToken();

    String next = Routes.onBoardingScreen;
    if (onboardingSeen) {
      if (rememberMe && token != null && token.isNotEmpty) {
        next = Routes.mainScreen;
      } else {
        next = Routes.loginScreen;
      }
    }

    if (!mounted) return;
    Get.offAllNamed(next);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D1B4B),
                Color(0xFF0D47A1),
                Color(0xFF1565C0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative circles ──────────────────────────────
              const Positioned(
                  top: -90, right: -70, child: _CircleDecor(size: 280)),
              const Positioned(
                  bottom: -110, left: -90, child: _CircleDecor(size: 340)),
              const Positioned(
                  top: 180, left: -50, child: _CircleDecor(size: 160)),

              // ── Centre content ──────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo bubble
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Image.asset(AppImages.logo),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // App name + tagline
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            const Text(
                              'Bizly',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 7),
                            FadeTransition(
                              opacity: _taglineFade,
                              child: Text(
                                'Smart Accounting, Simplified',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white.withOpacity(0.60),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom loading dots ─────────────────────────────
              Positioned(
                bottom: 64,
                left: 0,
                right: 0,
                child: _PulsingDots(controller: _dotCtrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────

class _CircleDecor extends StatelessWidget {
  final double size;
  const _CircleDecor({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.04),
        border:
            Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
    );
  }
}

class _PulsingDots extends StatelessWidget {
  final AnimationController controller;
  const _PulsingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final double delay = i * 0.32;
            final double raw = (controller.value - delay) % 1.0;
            final double t = raw < 0 ? raw + 1.0 : raw;
            final double pulse =
                1.0 - (((t * 2.0) - 1.0) * ((t * 2.0) - 1.0));
            final double s = 0.45 + 0.55 * pulse.clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8 * s,
              height: 8 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.35 + 0.65 * s),
              ),
            );
          }),
        );
      },
    );
  }
}
