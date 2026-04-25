import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "https://my-server-0xa0.onrender.com";

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser(
  String name,
  String email,
  String password,
  String role,
) async {
  final res = await http.post(
    Uri.parse("https://my-server-0xa0.onrender.com"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "role": role,
    }),
  );

  return jsonDecode(res.body);
}
  // ================= updateProfile =================
  static Future<Map<String, dynamic>> updateProfile(
  String token,
  String name,
  String email,
  String? password,
) async {
  final res = await http.put(
    Uri.parse("$baseUrl/profile"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
    }),
  );

  return jsonDecode(res.body);
}
  // ================= PRODUCTS =================
  static Future<List<dynamic>> getProducts() async {
    final res = await http.get(Uri.parse("$baseUrl/products"));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMyProducts(int sellerId) async {
    final res = await http.get(Uri.parse("$baseUrl/products"));
    return jsonDecode(res.body);
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

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    request.headers['Authorization'] = "Bearer $token";

    var res = await request.send();
    return res.statusCode == 200;
  }

  // ================= DELETE =================
  static Future<void> deleteProduct(String token, int id) async {
    await http.delete(
      Uri.parse("$baseUrl/products/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  // ================= UPDATE =================
  static Future<void> updateProduct(
      String token, int id, String name, double price) async {
    await http.put(
      Uri.parse("$baseUrl/products/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "name": name,
        "price": price,
      }),
    );
  }

  // ================= CART =================
  static Future<void> addToCart(String token, int productId) async {
    await http.post(
      Uri.parse("$baseUrl/cart"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "product_id": productId,
        "quantity": 1,
      }),
    );
  }

  static Future<List<dynamic>> getCart(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/cart"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(res.body);
  }

  static Future<void> checkout(String token) async {
    await http.post(
      Uri.parse("$baseUrl/checkout"),
      headers: {"Authorization": "Bearer $token"},
    );
  }
   // ================= verifyOtp =================
static Future<Map<String, dynamic>> verifyOtp(
  String email,
  String otp,
) async {
  final res = await http.post(
    Uri.parse("$baseUrl/verify-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp,
    }),
  );

  return jsonDecode(res.body);
}

// 🔥 مهم جديد
static Future<Map<String, dynamic>> resendOtp(String email) async {
  final res = await http.post(
    Uri.parse("$baseUrl/resend-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
    }),
  );

  return jsonDecode(res.body);
}
  // ================= ORDERS =================
  static Future<List<dynamic>> getOrders(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(res.body);
  }
}