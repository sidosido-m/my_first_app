import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'auth_home_screen.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
  await StorageService.init();

  await Future.delayed(const Duration(seconds: 1));

  final token = StorageService.getToken();

  if (!mounted) return;

  if (token != null && token.isNotEmpty) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}