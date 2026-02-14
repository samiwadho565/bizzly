
import 'package:bizly/modules/business/screens/add_new_business_screen.dart';
import 'package:bizly/modules/customers/screens/customers_screen/customers_screen.dart';
import 'package:bizly/modules/expense/screens/add_expense_screen.dart';
import 'package:bizly/modules/expense/screens/expense_screen.dart';
import 'package:bizly/modules/expense/screens/expense_detail_screen.dart';
import 'package:bizly/modules/home/screens/home_screen.dart';
import 'package:bizly/modules/invoice/screens/invoice_detail_screen.dart';
import 'package:bizly/modules/nav/screens/main_screen.dart';
import 'package:bizly/modules/onboarding/screens/onboarding.dart';
import 'package:bizly/modules/profile/screens/profile_screen/profile_screen.dart';
import 'package:bizly/modules/profile/controllers/profile_controller.dart';
import 'package:bizly/modules/tasks/screens/task_detail_screen.dart';
import 'package:bizly/modules/team/screens/team_screen/team_screen.dart';
import 'package:bizly/modules/auth/bindings/login_binding.dart';
import 'package:bizly/modules/auth/bindings/signup_binding.dart';
import 'package:bizly/modules/business/bindings/create_business_binding.dart';
import 'package:bizly/modules/business/bindings/business_detail_binding.dart';
import 'package:bizly/modules/expense/bindings/expense_binding.dart';
import 'package:bizly/modules/expense/bindings/expense_detail_binding.dart';
import 'package:bizly/modules/home/bindings/home_binding.dart';
import 'package:bizly/modules/invoice/bindings/create_invoice_binding.dart';
import 'package:bizly/modules/invoice/bindings/invoice_binding.dart';
import 'package:bizly/modules/invoice/bindings/invoice_detail_binding.dart';
import 'package:bizly/modules/nav/bindings/main_binding.dart';
import 'package:bizly/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:bizly/modules/profile/bindings/invoice_customization_binding.dart';
import 'package:bizly/modules/profile/bindings/tax_settings_binding.dart';
import 'package:bizly/modules/tasks/bindings/task_detail_binding.dart';
import 'package:bizly/modules/tasks/bindings/tasks_binding.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import 'package:bizly/modules/auth/screens/login_screen.dart';
import 'package:bizly/modules/auth/screens/signup_screen.dart';
import 'package:bizly/modules/business/screens/all_business_screen.dart';
import 'package:bizly/modules/business/screens/business_detail_screen.dart';
import 'package:bizly/modules/business/screens/single_business_detail_screen.dart';
import 'package:bizly/modules/company_assets/screens/company_assets/add_company_asset.dart';
import 'package:bizly/modules/company_assets/screens/company_assets/company_assets_screen.dart';
import 'package:bizly/modules/invoice/screens/create_ivoice_screen.dart';
import 'package:bizly/modules/profile/screens/profile_screen/invoice_customization/invoice_cstomization_screen.dart';
import 'package:bizly/modules/profile/screens/profile_screen/tax_settings_screen/tax_settings_screen.dart';
import 'package:bizly/modules/tasks/screens/create_task_screen.dart';
import 'package:bizly/modules/team/screens/team_screen/create_team_member.dart';
import 'package:bizly/modules/vendors/screens/vendors/vendors_screen.dart';
import 'package:bizly/modules/business/screens/business_tabs_screen.dart';
import 'package:bizly/modules/splash/screens/splash_screen.dart';
import 'package:bizly/modules/vendors/screens/vendors/create_vendor_screen.dart';
import 'package:bizly/modules/vendors/bindings/create_vendor_binding.dart';
import 'package:bizly/modules/vendors/controllers/vendors_controller.dart';
import 'package:bizly/modules/customers/screens/customers_screen/create_customer_screen.dart';
import 'package:bizly/modules/customers/bindings/create_customer_binding.dart';
import 'package:bizly/modules/customers/controllers/customers_controller.dart';
import 'package:bizly/modules/categories/screens/categories_screen.dart';
import 'package:bizly/modules/categories/bindings/categories_binding.dart';
import 'routes.dart';


class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.onBoardingScreen,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.sigUpScreen,
      page: () => const SignUpScreen(),
      binding: SignupBinding(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.expenseDetailScreen,
      page: () =>  ExpenseDetailScreen(),
      binding: ExpenseDetailBinding(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes. taskDetailScreen,
      page: () =>   TaskDetailScreen(),
      binding: TaskDetailBinding(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.addNewBusiness,
      page: () => AddNewBusinessScreen(),
      binding: CreateBusinessBinding(),
      transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.addExpenseScreen,
      page: () => AddExpenseScreen(),
      binding: ExpenseBinding(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.expenseScreen,
      page: () => ExpenseScreen(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.createInvoiceScreen,
      page: () =>  CreateInvoiceScreen(),
  binding: CreateInvoiceBinding(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.createTaskScreen,
      page: () =>   CreateTaskScreen(),
        transition: Transition.fadeIn
    ),     GetPage(
      name: Routes.addEmployeeScreen,
      page: () =>   AddEmployeeScreen(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.allBusinessScreen,
      page: () =>   AllBusinessesScreen(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.invoiceDetailScreen,
      page: () =>  InvoiceDetailScreen(),
      binding: InvoiceDetailBinding(),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes. businessDetailScreen,
      page: () =>   BusinessDetailScreen(),
      binding: BusinessDetailBinding(),
        transition: Transition.fadeIn
    ),    GetPage(
      name: Routes. singleBusinessDetailScreen,
      page: () =>   SingleBusinessDetailScreen(),
        transition: Transition.fadeIn
    ),GetPage(
      name: Routes. customersScreen,
      page: () =>   CustomersScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomersController>(() => CustomersController());
      }),
        transition: Transition.fadeIn
    ),
    GetPage(
      name: Routes.profileScreen,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: Routes.vendorsScreen,
      page: () =>  VendorsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<VendorsController>(() => VendorsController());
      }),
    ),    GetPage(
      name: Routes.createVendorScreen,
      page: () => CreateVendorScreen(),
      binding: CreateVendorBinding(),
    ),
    GetPage(
      name: Routes.createCustomerScreen,
      page: () => CreateCustomerScreen(),
      binding: CreateCustomerBinding(),
    ),
    GetPage(
      name: Routes.addCompanyAssetScreen,
      page: () =>  AddAssetScreen(),
    ), GetPage(
      name: Routes.invoiceCustomizationScreen,
      page: () => InvoiceCustomizationScreen(),
  binding: InvoiceCustomizationBinding(),
    ),
    GetPage(
      name: Routes.taxSettingsScreen,
      page: () => TaxSettingsScreen(),
      binding: TaxSettingsBinding(),
    ),
    GetPage(
      name: Routes.companyAssetsScreen,
      page: () =>  CompanyAssetsScreen(),
    ),
    GetPage(
      name: Routes.categoriesScreen,
      page: () => const CategoriesScreen(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: Routes.businessTabsScreen,
      page: () => const BusinessTabsScreen(),
    ),
  GetPage(
      name: Routes.teamScreen,
      page: () => TeamEmployeesScreen(),
    ),
    GetPage(
      name: Routes.mainScreen,
      page: () =>  MainScreen(),
      bindings: [
        MainBinding(),
        HomeBinding(),
        ExpenseBinding(),
        InvoiceBinding(),
        TasksBinding(),
      ],
    ),
    GetPage(
      name: Routes.homeScreen,
      page: () => HomeScreen(),
      binding: HomeBinding(),
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
