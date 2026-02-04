import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class PreferencesService {
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Save user data
  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(user.toMap()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Get user data
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        return UserModel.fromMap(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear user data (on logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Clear all preferences
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


