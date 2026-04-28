import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  final _formKey = GlobalKey<FormState>();

  // ================= MESSAGE =================
  void msg(String text, {bool ok = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= LOGIN =================
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final res = await ApiService.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      // ================= SAFE CHECK =================
      if (res == null) {
        msg("Server error");
        return;
      }

      // 🔥 OTP REQUIRED FLOW
      if (res['needOtp'] == true) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OtpScreen(email: res['email']),
    ),
  );
  return;
}

      // ❌ LOGIN FAILED
      if (res['token'] == null) {
        msg(res['error'] ?? "Login failed");
        return;
      }

      // ================= SAVE SESSION =================
      await StorageService.saveToken(res['token']);
      await StorageService.saveUserId(res['user']['id']);
      await StorageService.saveRole(res['user']['role']);

      msg("Welcome back 👋", ok: true);

      if (!mounted) return;

      // ================= NAVIGATION =================
      final role = res['user']['role'];

      Navigator.pushReplacementNamed(
        context,
        role == "seller" ? '/seller' : '/products',
      );
    } catch (e) {
      setState(() => loading = false);
      msg("Connection error");
    }
  }

  // ================= INPUT STYLE =================
  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ================= VALIDATORS =================
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Email required";
    }
    if (!value.contains("@")) {
      return "Invalid email";
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password required";
    }
    if (value.length < 6) {
      return "Min 6 characters";
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,
          child: Column(
            children: [

              const SizedBox(height: 30),

              const Icon(
                Icons.lock_outline,
                size: 90,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 10),

              const Text(
                "Welcome back 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Login to continue shopping",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // ================= EMAIL =================
              TextFormField(
                controller: emailController,
                validator: emailValidator,
                keyboardType: TextInputType.emailAddress,
                decoration: inputStyle("Email", Icons.email),
              ),

              const SizedBox(height: 15),

              // ================= PASSWORD =================
              TextFormField(
                controller: passwordController,
                validator: passwordValidator,
                obscureText: hidePassword,
                decoration: inputStyle("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "LOGIN",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Don't have an account? Create one",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}