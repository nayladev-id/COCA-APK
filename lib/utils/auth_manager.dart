// lib/utils/auth_manager.dart
// Mengelola data sesi pengguna lokal (shared_preferences)

import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyProfilePic = 'profile_pic';

  static Future<void> saveUser(int id, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
    await prefs.setString(_keyUsername, username);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<void> saveProfilePicture(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfilePic, base64Image);
  }

  static Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfilePic);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyProfilePic);
  }

  static Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null && userId > 0;
  }
}
