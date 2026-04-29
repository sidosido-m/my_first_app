import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/seller_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/seller_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        // ================= AUTH =================
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // ================= HOME =================
        '/home': (context) => HomeScreen(),

        // ================= PRODUCTS =================
        '/products': (context) => const ProductsScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),

        // ================= SELLER =================
        '/seller': (context) => const SellerScreen(),

        // ================= PRODUCT DETAILS =================
        '/product-details': (context) {
          final product =
              ModalRoute.of(context)!.settings.arguments as dynamic;

          return ProductDetailsScreen(product: product);
        },

        // ================= SELLER PROFILE =================
        '/seller-profile': (context) {
          final sellerId =
              ModalRoute.of(context)!.settings.arguments as int;

          return SellerProfileScreen(sellerId: sellerId);
        },
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text(
                "404 - Page Not Found",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}