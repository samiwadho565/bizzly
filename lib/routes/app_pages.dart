
import 'package:bizly/views/nav_bar/main_screen.dart';
import 'package:bizly/views/onboarding/onboarding.dart';
import 'package:bizly/views/profile_screen/profile_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/bussiness_screen/business_detail_screen.dart';
import 'routes.dart';
import 'bindings.dart';


class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.onBoardingScreen,
      page: () => OnboardingScreen(),
      binding: InitialBindings(),
    ),
    // GetPage(
    //   name: Routes.splash,
    //   page: () => const SplashScreen(),
    //   binding: InitialBindings(),
    // ),
    GetPage(
      name: Routes.loginScreen,
      page: () => const LoginScreen(),
      binding: InitialBindings(),
      transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.sigUpScreen,
      page: () => const SignUpScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),    GetPage(
      name: Routes. businessDetailScreen,
      page: () =>   BusinessDetailScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.profileScreen,
      page: () => const ProfileScreen(),
      binding: InitialBindings(),
    ),    GetPage(
      name: Routes.mainScreen,
      page: () =>  MainScreen(),
      binding: InitialBindings(),
    ),
    // GetPage(
    //   name: Routes.authScreen,
    //   page: () => const AuthScreen(),
    //   binding: InitialBindings(),
    // ),

  // GetPage(
    //   name: Routes.notificationScreen,
    //   page: () => const NotificationScreen(),
    //   binding: InitialBindings(),
    // ),     GetPage(
    //   name: Routes.singleServiceScreen,
    //   page: () => const SingleServiceScreen(),
    //   binding: InitialBindings(),
    // ),     GetPage(
    //   name: Routes.singleOrderScreen,
    //   page: () => const SingleOrderScreenUI(orderId: "1"),
    //   binding: InitialBindings(),
    // ),
    // GetPage(
    //   name: Routes. mainScreen ,
    //   page: () =>  MainScreen(),
    //   binding: InitialBindings(),
    // ),    GetPage(
    //   name: Routes.completeProfileScreen,
    //   page: () =>  CompleteProfileScreen(),
    //   binding: InitialBindings(),
    // ), GetPage(
    //   name: Routes.otpVerificationScreen,
    //   page: () =>  OtpVerificationScreen(),
    //   binding: InitialBindings(),
    // ),
  ];
}
