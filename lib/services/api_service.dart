import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://my-server-0xa0.onrender.com";

  // ================= HEADERS =================
  static Map<String, String> jsonHeader([String? token]) {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: jsonHeader(),
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return _safeDecode(res);
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: jsonHeader(),
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    return _safeDecode(res);
  }

  // ================= VERIFY OTP =================
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

    return _safeDecode(res);
  }

  // ================= RESEND OTP =================
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/resend-otp"),
      headers: jsonHeader(),
      body: jsonEncode({
        "email": email,
      }),
    );

    return _safeDecode(res);
  }

  // ================= PROFILE =================
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
        if (password != null && password.isNotEmpty)
          "password": password,
      }),
    );

    return _safeDecode(res);
  }

  // ================= PRODUCTS =================
  static Future<List<dynamic>> getProducts() async {
    final res = await http.get(Uri.parse("$baseUrl/products"));

    final data = _safeDecode(res);
    return data is List ? data : [];
  }

  static Future<List<dynamic>> getMyProducts(int sellerId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/products?sellerId=$sellerId"),
    );

    final data = _safeDecode(res);
    return data is List ? data : [];
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
    request.fields['seller_id'] = sellerId.toString();

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    request.headers['Authorization'] = "Bearer $token";

    final response = await request.send();

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ================= DELETE PRODUCT =================
  static Future<bool> deleteProduct(String token, int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/products/$id"),
      headers: jsonHeader(token),
    );

    return res.statusCode >= 200 && res.statusCode < 300;
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

    _safeDecode(res);
  }

  // ================= CART =================
  static Future<bool> addToCart(String token, int productId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/cart"),
      headers: jsonHeader(token),
      body: jsonEncode({
        "product_id": productId,
        "quantity": 1,
      }),
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<List<dynamic>> getCart(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/cart"),
      headers: jsonHeader(token),
    );

    final data = _safeDecode(res);
    return data is List ? data : [];
  }

  static Future<void> checkout(String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/checkout"),
      headers: jsonHeader(token),
    );

    _safeDecode(res);
  }

  // ================= ORDERS =================
  static Future<List<dynamic>> getOrders(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: jsonHeader(token),
    );

    final data = _safeDecode(res);
    return data is List ? data : [];
  }

  static Future<Map<String, dynamic>> getOrderById(
    String token,
    int id,
  ) async {
    final res = await http.get(
      Uri.parse("$baseUrl/orders/$id"),
      headers: jsonHeader(token),
    );

    return _safeDecode(res);
  }

  // ================= SAFE HANDLER =================
  static dynamic _safeDecode(http.Response res) {
    try {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return body;
      } else {
        throw Exception(body ?? "Server Error");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }
}