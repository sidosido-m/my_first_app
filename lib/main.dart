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
import 'services/storage_service.dart';
import 'screens/splash_router.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/my_products_screen.dart';
import 'screens/seller_dashboard_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/add_product_screen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  runApp( MyApp());
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
        '/': (context) => const SplashRouter(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // ================= HOME =================
        '/home': (context) => const HomeScreen(),

        // ================= PRODUCTS =================
        '/products': (context) => const ProductsScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/seller': (context) => const SellerScreen(),

        // ================= PROFILE =================
        '/profile': (context) => const ProfileScreen(),
        '/seller-dashboard': (_) => const SellerDashboardScreen(),
      
      '/edit-profile': (context) => const EditProfileScreen(),
      '/my-products': (context) => const MyProductsScreen(),
      '/edit-product': (context) {
  final product =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  return EditProductScreen(
    product: product,
  );
  
},

  
},
      // ================= PRODUCT DETAILS =================
      onGenerateRoute: (settings) {
        if (settings.name == '/product-details') {
          final product = settings.arguments;
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          );
        }

        if (settings.name == '/seller-profile') {
          final sellerId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => SellerProfileScreen(sellerId: sellerId),
          );
        }

        if (settings.name == '/chat') {
          final sellerId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => ChatScreen(receiverId: sellerId),
          );
        }

        return null;
      },

      // ================= UNKNOWN ROUTE =================
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found ❌")),
          ),
        );
      },
    );
  }
}