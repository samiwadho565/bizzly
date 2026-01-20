import 'package:get/get.dart';

class OnboardingController extends GetxController {
  var currentIndex = 0.obs;
  final onboardingData = [
    {
      "title": "Welcome to Bizzly",
      "subtitle":
      "Your smart business assistant to manage daily tasks, finances, and operations in one place.",
    },
    {
      "title": "Manage Invoices\n& Expenses",
      "subtitle":
      "Create invoices, track payments, and manage all your business expenses easily.",
    },
    {
      "title": "Organize your\nBusiness",
      "subtitle":
      "Add services, manage categories, assign tasks, and keep your business organized.",
    },
  ];



  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}
