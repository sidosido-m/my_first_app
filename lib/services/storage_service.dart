import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  /* ================= TOKEN ================= */

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  /* ================= USER ID ================= */

  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userId", id);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userId");
  }
  // ================= ROLE =================

static Future<void> saveRole(String role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("role", role);
}

static Future<String?> getRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("role");
}

static Future<void> clearRole() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("role");
}
}