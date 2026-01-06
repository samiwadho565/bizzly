import 'package:get/get.dart';

class OnboardingController extends GetxController {
  var currentIndex = 0.obs;

  final onboardingData = [
    {
      "title": "Welcome to Bizzly",
      "subtitle": "Your Smart Business Assistant",
    },
    {
      "title": "Manage Invoices\n& Expenses",
      "subtitle": "Easily create, send and track invoices and expenses",
    },
    {
      "title": "Organize your\nBusiness",
      "subtitle": "Add Services, categories, and manage your tasks",
    },
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}
