import 'package:flutter/material.dart';
import 'screens/seller_profile_screen.dart';
import 'screens/chat_screen.dart'; // ✅ مهم جدا

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {

    // ================= SELLER PROFILE =================
    case '/seller-profile':
      final id = settings.arguments as int;
      return MaterialPageRoute(
        builder: (_) => SellerProfileScreen(sellerId: id),
      );

    // ================= CHAT =================
    case '/chat':
      final id = settings.arguments as int;
      return MaterialPageRoute(
        builder: (_) => ChatScreen(receiverId: id),
      );

    // ================= DEFAULT =================
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text("Route not found")),
        ),
      );
  }
}