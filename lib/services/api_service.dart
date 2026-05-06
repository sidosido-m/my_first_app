import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';



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
  // ================= uploadImage =================
static Future<String?> uploadImage(File file) async {
  final uri = Uri.parse("$baseUrl/upload");

  final request = http.MultipartRequest("POST", uri);

  request.files.add(
    await http.MultipartFile.fromPath(
      "image",
      file.path,
    ),
  );

  final response = await request.send();

  if (response.statusCode != 200) {
    throw Exception("Upload failed");
  }

  final resBody = await response.stream.bytesToString();

  final data = jsonDecode(resBody);

  return data["url"];
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

  print("STATUS: ${res.statusCode}");
  print("BODY: ${res.body}");

  final data = _safeDecode(res);
  return Map<String, dynamic>.from(data);
}
  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String username,
    String email,
    String password,
    String role,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: jsonHeader(),
      body: jsonEncode({
        "name": name,
        "username": username,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    final data = _safeDecode(res);
    return Map<String, dynamic>.from(data);
  }

  // ================= VERIFY OTP =================
  static Future verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: jsonHeader(),
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    return jsonDecode(res.body);
  }

  // ================= RESEND OTP =================
   static Future resendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/resend-otp"),
      headers: jsonHeader(),
      body: jsonEncode({
        "email": email,
      }),
    );

    return jsonDecode(res.body);
  }

  // ================= PROFILE WITH IMAGE =================
static Future<bool> updateProfileWithImage({
  required String token,
  required String name,
  required String email,
  required String username,
  String? oldPassword,
  String? newPassword,
  String? imageUrl,
  String? bgUrl,
}) async {

  final Map<String, dynamic> body = {
    "name": name,
    "email": email,
    "username": username,
  };

  if (newPassword != null && newPassword.isNotEmpty) {
    body["newPassword"] = newPassword;
    body["oldPassword"] = oldPassword;
  }

  if (imageUrl != null && imageUrl.isNotEmpty) {
    body["image"] = imageUrl;
  }

  if (bgUrl != null && bgUrl.isNotEmpty) {
    body["background_image"] = bgUrl;
  }

  print("SENDING DATA:");
  print(body);

  final res = await http.put(
    Uri.parse("$baseUrl/profile"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  print("STATUS: ${res.statusCode}");
  print("BODY: ${res.body}");

  final data = jsonDecode(res.body);

  return res.statusCode == 200 && data["success"] == true;
}

  // ================= PRODUCTS =================
  static Future<List<dynamic>> getProducts() async {
  final res = await http.get(Uri.parse("$baseUrl/products"));

  final data = _safeDecode(res);
  return data is List ? data : [];
}
 static Future<List<dynamic>> getMyProducts(String token) async {
  final res = await http.get(
    Uri.parse("$baseUrl/my-products"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(res.body);
}

 // ================= ADD PRODUCT =================
static Future<bool> addProduct({
  required String name,
  required double price,
  required String token,
  String? imageUrl,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/products"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "name": name,
      "price": price,
      "image": imageUrl,
    }),
  );

  return res.statusCode == 200;
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
static Future<bool> updateProduct({
  required String token,
  required int id,
  required String name,
  required double price,
  String? image,
}) async {
  final res = await http.put(
    Uri.parse("$baseUrl/products/$id"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "name": name,
      "price": price,
      "image": image,
    }),
  );

  return res.statusCode == 200;
}

// ================= UPDATE PROFILE =================
static Future<void> updateProfile(
  String token,
  String name,
  String email,
  String? imageUrl,
  String? backgroundUrl,
) async {
  final res = await http.put(
    Uri.parse("$baseUrl/profile"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "name": name,
      "email": email,
      "image": imageUrl,
      "background_image": backgroundUrl,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("Profile update failed");
  }
}
  // ================= SELLER =================
  static Future<Map<String, dynamic>> getSeller(int id) async {
  final res = await http.get(
    Uri.parse("$baseUrl/seller/$id"),
  );

  return jsonDecode(res.body);
}
  // ================= SELLER state =================
static Future<Map> getSellerStats(int id) async {
  final res = await http.get(
    Uri.parse("$baseUrl/seller-stats/$id"),
  );

  return jsonDecode(res.body);
}

 // ================= SELLER PRODUCT =================
 static Future<List<dynamic>> getSellerProducts(int id) async {
  final res = await http.get(
    Uri.parse("$baseUrl/seller/$id/products"),
  );

  final data = jsonDecode(res.body);
  return data is List ? data : [];
}
 // ================= RATE SELLER =================
static Future<void> rateSeller(
    String token,
    int sellerId,
    double rating,
) async {
  final res = await http.post(
    Uri.parse("$baseUrl/seller/rate"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "sellerId": sellerId,
      "rating": rating,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("Rating failed");
  }
}

// ================= SELLER DASHBOARD =================
static Future<Map<String, dynamic>> getSellerDashboard(String token) async {
  final res = await http.get(
    Uri.parse("$baseUrl/seller-dashboard"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(res.body);
}
 // ================= PROFILE =================
static Future<Map<String, dynamic>> getProfile(String token) async {
  final res = await http.get(
    Uri.parse("$baseUrl/profile"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  final data = jsonDecode(res.body);

  return data;
}
// ================= BECOME SELLER =================
static Future<void> becomeSeller(String token) async {
  final res = await http.put(
    Uri.parse("$baseUrl/become-seller"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  final data = jsonDecode(res.body);

  if (data['success'] != true) {
    throw Exception(data['error']);
  }
}

//=============== CHAT =================

// إرسال رسالة
static Future<void> sendMessage(
  String token,
  int receiverId,
  String message,
) async {
  await http.post(
    Uri.parse("$baseUrl/messages"),
    headers: jsonHeader(token),
    body: jsonEncode({
      "receiver_id": receiverId,
      "message": message,
    }),
  );
}
// ==============FOLLOW================
static Future<bool> followSeller(
    String token, int sellerId) async {
  
  final res = await http.post(
    Uri.parse("$baseUrl/follow/$sellerId"),
    headers: jsonHeader(token),
  );

  final data = _safeDecode(res);
  return data['following'];
}

static Future<List<dynamic>> getFollowers(int sellerId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/followers/$sellerId"),
  );

  return jsonDecode(res.body);
}

static Future<List<dynamic>> getFollowing(int userId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/following/$userId"),
  );

  return jsonDecode(res.body);
}
// ==============TOGGLE FOLLOW================
static Future<bool> toggleFollow(String token, int sellerId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/follow/$sellerId"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  final data = jsonDecode(res.body);
  return data['following'];
}

// ============ADD REVIEW===============
static Future<void> addReview(
  String token,
  int sellerId,
  int rating,
  String comment,
) async {
  await http.post(
    Uri.parse("$baseUrl/review/$sellerId"),
    headers: jsonHeader(token),
    body: jsonEncode({
      "rating": rating,
      "comment": comment,
    }),
  );
}
 // ================= CHAT =================
static Future<List<dynamic>> getMessages(
  String token,
  int userId,
) async {
  final res = await http.get(
    Uri.parse("$baseUrl/messages/$userId"),
    headers: jsonHeader(token),
  );

  final data = _safeDecode(res);
  return data is List ? data : [];
}
  // ================= CART =================
 static Future<void> addToCart(String token, int productId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/cart"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "productId": productId,
      "qty": 1,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("Cart error");
  }
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
  // ❌ REMOVE
static Future<void> removeFromCart(
    String token, int productId) async {
  await http.delete(
    Uri.parse("$baseUrl/cart/$productId"),
    headers: jsonHeader(token),
  );
}

static Future<void> updateCartQty(
    String token, int productId, int qty) async {
  await http.put(
    Uri.parse("$baseUrl/cart"),
    headers: jsonHeader(token),
    body: jsonEncode({
      "productId": productId,
      "qty": qty,
    }),
  );
}
// ================= TOGGLELIKE =================
static Future<Map<String, dynamic>> toggleLike(
  String token,
  int productId,
) async {
  final res = await http.post(
    Uri.parse("$baseUrl/like/$productId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(res.body);
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

    final data = _safeDecode(res);
    return Map<String, dynamic>.from(data);
  }

  // ================= SAFE HANDLER =================
  static dynamic _safeDecode(http.Response res) {
  try {
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

    return body;
  } catch (e) {
    print("PARSE ERROR: $e");
    return {
      "success": false,
      "error": "Invalid JSON from server"
    };
  }
}
}