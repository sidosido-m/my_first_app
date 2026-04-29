import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/seller_screen.dart';
import 'routes.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ================= START =================
      initialRoute: '/',

      // ================= ROUTES =================
      routes: {
        '/home': (context) => const HomeScreen(),
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/product-details': (context) => ProductDetailsScreen(
          product: ModalRoute.of(context)!.settings.arguments,),
          '/seller-profile': (context) => SellerProfileScreen(
  sellerId: ModalRoute.of(context)!.settings.arguments as int,
),
        '/seller-profile': (context) => const SellerProfileScreen(),
        // CUSTOMER
        '/products': (context) => const ProductsScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),

        // SELLER
        '/seller': (context) => const SellerScreen(),
      },

      // ================= ERROR HANDLING =================
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