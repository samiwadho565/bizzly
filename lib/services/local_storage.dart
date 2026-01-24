import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _authTokenKey = 'auth_token';
  static const String _rememberMeKey = 'remember_me';
  static const String _rememberEmailKey = 'remember_email';
  static const String _rememberPasswordKey = 'remember_password';

  static Future<void> saveAuthToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  static Future<void> saveRememberMe(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<void> saveRememberedEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberEmailKey, email);
  }

  static Future<String?> getRememberedEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberEmailKey);
  }

  static Future<void> saveRememberedPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberPasswordKey, password);
  }

  static Future<String?> getRememberedPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberPasswordKey);
  }

  static Future<void> clearRememberedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberEmailKey);
    await prefs.remove(_rememberPasswordKey);
  }
}
