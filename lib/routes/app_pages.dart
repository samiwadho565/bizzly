
import 'package:bizly/views/bussiness_screen/add_new_business_screen.dart';
import 'package:bizly/views/customers_screen/customers_screen.dart';
import 'package:bizly/views/expense_screen/add_expense_screen.dart';
import 'package:bizly/views/expense_screen/expense_detail_screen.dart';
import 'package:bizly/views/home/home_screen.dart';
import 'package:bizly/views/invoice_screen/invoice_detail_screen.dart';
import 'package:bizly/views/nav_bar/main_screen.dart';
import 'package:bizly/views/onboarding/onboarding.dart';
import 'package:bizly/views/profile_screen/invoice_customization/invoice_preview_screen.dart';
import 'package:bizly/views/profile_screen/profile_screen.dart';
import 'package:bizly/views/tasks_screen/task_detail_screen.dart';
import 'package:bizly/views/team_screen/team_screen.dart';
import 'package:bizly/views/vendors/vendor_detail_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/bussiness_screen/all_business_screen.dart';
import '../views/bussiness_screen/business_detail_screen.dart';
import '../views/bussiness_screen/single_business_detail_screen.dart';
import '../views/company_assets/add_company_asset.dart';
import '../views/company_assets/company_assets_screen.dart';
import '../views/invoice_screen/create_ivoice_screen.dart';
import '../views/profile_screen/invoice_customization/invoice_cstomization_screen.dart';
import '../views/tasks_screen/create_task_screen.dart';
import '../views/team_screen/create_team_member.dart';
import '../views/vendors/vendors_screen.dart';
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
    ),
    GetPage(
      name: Routes.expenseDetailScreen,
      page: () =>  ExpenseDetailScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes. taskDetailScreen,
      page: () =>   TaskDetailScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.addNewBusiness,
      page: () => AddNewBusinessScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.addExpenseScreen,
      page: () => AddExpenseScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.createInvoiceScreen,
      page: () =>  CreateInvoiceScreen(),
  binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.createTaskScreen,
      page: () =>   CreateTaskScreen(),
  binding: InitialBindings(),
        transition: Transition.fadeIn
    ),     GetPage(
      name: Routes.addEmployeeScreen,
      page: () =>   AddEmployeeScreen(),
  binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.allBusinessScreen,
      page: () =>   AllBusinessesScreen(),
  binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.invoiceDetailScreen,
      page: () =>  InvoiceDetailScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes. businessDetailScreen,
      page: () =>   BusinessDetailScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),    GetPage(
      name: Routes. singleBusinessDetailScreen,
      page: () =>   SingleBusinessDetailScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),GetPage(
      name: Routes. customersScreen,
      page: () =>   CustomersScreen(),
      binding: InitialBindings(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.profileScreen,
      page: () => const ProfileScreen(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.vendorsScreen,
      page: () =>  VendorsScreen(),
      binding: InitialBindings(),
    ),    GetPage(
      name: Routes.addCompanyAssetScreen,
      page: () =>  AddAssetScreen(),
  binding: InitialBindings(),
    ), GetPage(
      name: Routes.invoiceCustomizationScreen,
      page: () => InvoiceCustomizationScreen(),
  binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.companyAssetsScreen,
      page: () =>  CompanyAssetsScreen(),
      binding: InitialBindings(),
    ),
  GetPage(
      name: Routes.teamScreen,
      page: () => TeamEmployeesScreen(),
    binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.mainScreen,
      page: () =>  MainScreen(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.homeScreen,
      page: () => HomeScreen(),
      binding: InitialBindings(),
    ),

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
