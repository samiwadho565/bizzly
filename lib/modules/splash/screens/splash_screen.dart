import 'package:bizly/assets/images.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 3));
    final bool onboardingSeen = await LocalStorage.getOnboardingSeen();
    final bool rememberMe = await LocalStorage.getRememberMe();
    final String? token = await LocalStorage.getAuthToken();

    String next = Routes.onBoardingScreen;
    if (onboardingSeen) {
      if (rememberMe && token != null && token.isNotEmpty) {
        next = Routes.homeScreen;
      } else {
        next = Routes.loginScreen;
      }
    }

    if (!mounted) return;
    Get.offAllNamed(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Image.asset(
            AppImages.logo,
            width: 180,
          ),
        ),
      ),
    );
  }
}
