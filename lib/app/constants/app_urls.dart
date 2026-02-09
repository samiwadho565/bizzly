class AppUrls {
  AppUrls._();

  static const String baseUrl = 'https://rosybrown-ant-846135.hostingersite.com';
  static const Duration timeout = Duration(seconds: 20);

  static const String signUp = '/api/auth/signup';
  static const String signIn = '/api/auth/login';
  static const String createBusiness = '/api/businesses';
  static const String getAllBusinesses = '/api/businesses';
  static const String updateBusiness = '/api/businesses';
  static const String profile = '/api/profile';
  static const String deleteAccount = '/api/profile/delete-account';
  static const String logout = '/api/auth/logout';
  static const String createVendor = '/api/vendors';
  static const String updateVendor = '/api/vendors';
  static const String createCustomer = '/api/customers';
  static const String updateCustomer = '/api/customers';
}
