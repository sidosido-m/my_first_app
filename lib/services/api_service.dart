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
    String email, String password) async {
  final res = await http
      .post(
        Uri.parse("$baseUrl/login"),
        headers: jsonHeader(),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      )
      .timeout(const Duration(seconds: 15));

  return _safeDecode(res);
}

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser(
  String name,
  String email,
  String password,
  String role,
) async {
  final res = await http
      .post(
        Uri.parse("$baseUrl/register"),
        headers: jsonHeader(),
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      )
      .timeout(const Duration(seconds: 15));

  return _safeDecode(res);
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
  final res = await http
      .get(Uri.parse("$baseUrl/products"))
      .timeout(const Duration(seconds: 15));

  final data = _safeDecode(res);
  return data is List ? data : [];
}

  // ✅ FIXED sellerId usage
  static Future<List<dynamic>> getMyProducts(int sellerId) async {
  final res = await http
      .get(Uri.parse("$baseUrl/products?sellerId=$sellerId"))
      .timeout(const Duration(seconds: 15));

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
  await http
      .post(
        Uri.parse("$baseUrl/cart"),
        headers: jsonHeader(token),
        body: jsonEncode({
          "product_id": productId,
          "quantity": 1,
        }),
      )
      .timeout(const Duration(seconds: 15));
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
 static dynamic _safeDecode(http.Response res) {
  try {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    } else {
      throw Exception(body ?? "Unknown API error");
    }
  } catch (e) {
    throw Exception("API parsing error: $e");
  }
}