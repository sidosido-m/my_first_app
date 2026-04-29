import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // ================= INIT =================
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================= TOKEN =================
  static Future<void> saveToken(String token) async {
    await _prefs?.setString("token", token);
  }

  static String? getToken() {
    return _prefs?.getString("token");
  }

  static Future<void> clearToken() async {
    await _prefs?.remove("token");
  }

  // ================= USER ID =================
  static Future<void> saveUserId(int id) async {
    await _prefs?.setInt("userId", id);
  }

  static int? getUserId() {
    return _prefs?.getInt("userId");
  }

  static Future<void> clearUserId() async {
    await _prefs?.remove("userId");
  }

  // ================= ROLE =================
  static Future<void> saveRole(String role) async {
    await _prefs?.setString("role", role);
  }

  static String? getRole() {
    return _prefs?.getString("role");
  }

  static Future<void> clearRole() async {
    await _prefs?.remove("role");
  }

  // ================= USER (احترافي) =================
  static Future<void> saveUser({
    required int id,
    required String token,
    required String role,
  }) async {
    await saveUserId(id);
    await saveToken(token);
    await saveRole(role);
  }

  // ================= LOGOUT =================
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // ================= CHECK LOGIN =================
  static bool isLoggedIn() {
    return _prefs?.getString("token") != null;
  }
}