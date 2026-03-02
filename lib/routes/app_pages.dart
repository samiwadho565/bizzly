import 'package:bizly/modules/business/screens/add_new_business_screen.dart';
import 'package:bizly/modules/customers/screens/customers_screen/customers_screen.dart';
import 'package:bizly/modules/expense/screens/add_expense_screen.dart';
import 'package:bizly/modules/expense/screens/expense_screen.dart';
import 'package:bizly/modules/expense/screens/expense_detail_screen.dart';
import 'package:bizly/modules/home/screens/home_screen.dart';
import 'package:bizly/modules/invoice/screens/invoice_detail_screen.dart';
import 'package:bizly/modules/invoice/screens/invoice_payments_screen.dart';
import 'package:bizly/modules/invoice/screens/create_invoice_payment_screen.dart';
import 'package:bizly/modules/nav/screens/main_screen.dart';
import 'package:bizly/modules/onboarding/screens/onboarding.dart';
import 'package:bizly/modules/profile/screens/profile_screen/profile_screen.dart';
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
import 'package:bizly/modules/invoice/bindings/create_invoice_payment_binding.dart';
import 'package:bizly/modules/invoice/bindings/invoice_detail_binding.dart';
import 'package:bizly/modules/invoice/bindings/invoice_payments_binding.dart';
import 'package:bizly/modules/nav/bindings/main_binding.dart';
import 'package:bizly/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:bizly/modules/profile/bindings/invoice_customization_binding.dart';
import 'package:bizly/modules/profile/bindings/tax_settings_binding.dart';
import 'package:bizly/modules/tasks/bindings/task_detail_binding.dart';
import 'package:bizly/modules/tasks/bindings/create_task_binding.dart';
import 'package:bizly/modules/team/bindings/add_employee_binding.dart';
import 'package:bizly/modules/team/bindings/team_screen_binding.dart';
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
import 'package:bizly/modules/vendors/bindings/vendors_binding.dart';
import 'package:bizly/modules/customers/screens/customers_screen/create_customer_screen.dart';
import 'package:bizly/modules/customers/bindings/create_customer_binding.dart';
import 'package:bizly/modules/customers/bindings/customers_binding.dart';
import 'package:bizly/modules/company_assets/bindings/add_company_asset_binding.dart';
import 'package:bizly/modules/company_assets/bindings/company_assets_binding.dart';
import 'package:bizly/modules/categories/screens/categories_screen.dart';
import 'package:bizly/modules/categories/bindings/categories_binding.dart';
import 'package:bizly/modules/profile/bindings/profile_binding.dart';
import 'package:bizly/modules/reports/bindings/balance_sheet_binding.dart';
import 'package:bizly/modules/reports/bindings/trial_balance_binding.dart';
import 'package:bizly/modules/reports/screens/balance_sheet_screen.dart';
import 'package:bizly/modules/reports/screens/trial_balance_screen.dart';
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
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.sigUpScreen,
      page: () => const SignUpScreen(),
      binding: SignupBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.expenseDetailScreen,
      page: () => ExpenseDetailScreen(),
      binding: ExpenseDetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.taskDetailScreen,
      page: () => TaskDetailScreen(),
      binding: TaskDetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.addNewBusiness,
      page: () => AddNewBusinessScreen(),
      binding: CreateBusinessBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.addExpenseScreen,
      page: () => AddExpenseScreen(),
      binding: ExpenseBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.expenseScreen,
      page: () => ExpenseScreen(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.createInvoiceScreen,
      page: () => CreateInvoiceScreen(),
      binding: CreateInvoiceBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.createTaskScreen,
      page: () => CreateTaskScreen(),
      binding: CreateTaskBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.addEmployeeScreen,
      page: () => AddEmployeeScreen(),
      binding: AddEmployeeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.allBusinessScreen,
      page: () => AllBusinessesScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.invoiceDetailScreen,
      page: () => InvoiceDetailScreen(),
      binding: InvoiceDetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.invoicePaymentsScreen,
      page: () => const InvoicePaymentsScreen(),
      binding: InvoicePaymentsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.createInvoicePaymentScreen,
      page: () => const CreateInvoicePaymentScreen(),
      binding: CreateInvoicePaymentBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.businessDetailScreen,
      page: () => BusinessDetailScreen(),
      binding: BusinessDetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.singleBusinessDetailScreen,
      page: () => SingleBusinessDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.customersScreen,
      page: () => CustomersScreen(),
      binding: CustomersBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.profileScreen,
      page: () => const ProfileScreen(showBackButton: true),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.vendorsScreen,
      page: () => VendorsScreen(),
      binding: VendorsBinding(),
    ),
    GetPage(
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
      page: () => AddAssetScreen(),
      binding: AddCompanyAssetBinding(),
    ),
    GetPage(
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
      page: () => CompanyAssetsScreen(),
      binding: CompanyAssetsBinding(),
    ),
    GetPage(
      name: Routes.categoriesScreen,
      page: () => const CategoriesScreen(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: Routes.balanceSheetScreen,
      page: () => const BalanceSheetScreen(),
      binding: BalanceSheetBinding(),
    ),
    GetPage(
      name: Routes.trialBalanceScreen,
      page: () => const TrialBalanceScreen(),
      binding: TrialBalanceBinding(),
    ),
    GetPage(
      name: Routes.businessTabsScreen,
      page: () => const BusinessTabsScreen(),
    ),
    GetPage(
      name: Routes.teamScreen,
      page: () => TeamEmployeesScreen(),
      binding: TeamScreenBinding(),
    ),
    GetPage(
      name: Routes.mainScreen,
      page: () => MainScreen(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.homeScreen,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}
