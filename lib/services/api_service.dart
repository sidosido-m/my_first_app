import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://my-server-0xa0.onrender.com";

  // ================= HEADERS =================
  static Map<String, String> jsonHeader([String? token]) => {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: jsonHeader(),
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return _handleResponse(res);
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"), // ✅ FIXED
      headers: jsonHeader(),
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    return _handleResponse(res);
  }

  // ================= UPDATE PROFILE =================
  static Future<Map<String, dynamic>> updateProfile(
    String token,
    String name,
    String email,
    String? password,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: jsonHeader(token),
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    return _handleResponse(res);
  }

  // ================= PRODUCTS =================
  static Future<List<dynamic>> getProducts() async {
    final res = await http.get(Uri.parse("$baseUrl/products"));
    return _handleResponse(res);
  }

  // ✅ FIXED sellerId usage
  static Future<List<dynamic>> getMyProducts(int sellerId) async {
    final res =
        await http.get(Uri.parse("$baseUrl/products?sellerId=$sellerId"));
    return _handleResponse(res);
  }

  // ================= ADD PRODUCT =================
  static Future<bool> addProductWithImage({
    required String name,
    required double price,
    required int sellerId,
    required String token,
    required File imageFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/products"),
    );

    request.fields['name'] = name;
    request.fields['price'] = price.toString();
    request.fields['sellerId'] = sellerId.toString();

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    request.headers['Authorization'] = "Bearer $token";

    var res = await request.send();

    return res.statusCode == 200 || res.statusCode == 201;
  }

  // ================= DELETE PRODUCT =================
  static Future<void> deleteProduct(String token, int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/products/$id"),
      headers: jsonHeader(token),
    );

    _handleResponse(res);
  }

  // ================= UPDATE PRODUCT =================
  static Future<void> updateProduct(
    String token,
    int id,
    String name,
    double price,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/products/$id"),
      headers: jsonHeader(token),
      body: jsonEncode({
        "name": name,
        "price": price,
      }),
    );

    _handleResponse(res);
  }

  // ================= CART =================
  static Future<void> addToCart(String token, int productId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/cart"),
      headers: jsonHeader(token),
      body: jsonEncode({
        "product_id": productId,
        "quantity": 1,
      }),
    );

    _handleResponse(res);
  }

  static Future<List<dynamic>> getCart(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/cart"),
      headers: jsonHeader(token),
    );

    return _handleResponse(res);
  }

  static Future<void> checkout(String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/checkout"),
      headers: jsonHeader(token),
    );

    _handleResponse(res);
  }

  // ================= OTP =================
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: jsonHeader(),
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/resend-otp"),
      headers: jsonHeader(),
      body: jsonEncode({
        "email": email,
      }),
    );

    return _handleResponse(res);
  }

  // ================= ORDERS =================
  static Future<List<dynamic>> getOrders(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: jsonHeader(token),
    );

    return _handleResponse(res);
  }

  // ================= SAFE RESPONSE HANDLER =================
  static dynamic _handleResponse(http.Response res) {
    try {
      final data = jsonDecode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return data;
      } else {
        throw Exception(data);
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }
}