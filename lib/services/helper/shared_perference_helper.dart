import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // Save a token
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('auth_token', token);
  }

  // Retrieve a token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Remove a token
  static Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('auth_token');
  }
}
