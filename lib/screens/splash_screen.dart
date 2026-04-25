import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    String? token = await StorageService.getToken();
    String? role = await StorageService.getRole(); // 🔥 جديد

    if (token != null) {
      if (role == "seller") {
        Navigator.pushReplacementNamed(context, '/seller');
      } else {
        Navigator.pushReplacementNamed(context, '/products');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}