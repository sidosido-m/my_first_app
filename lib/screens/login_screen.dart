import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'otp_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  void showMsg(String text, {bool ok = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= LOGIN =================
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

   setState(() {
  loading = true;
});

    try {
      final res = await ApiService.loginUser(
  emailController.text.trim(),
  passwordController.text.trim(),
);

print("LOGIN RESPONSE: $res");

     setState(() {
  loading = false;
});

      if (res == null) {
        showMsg("Server error ❌");
        return;
      }

      // ================= OTP REQUIRED =================
      if (res['needOtp'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: res['email'],
              
            ),
          ),
        );
        return;
      }

      // ================= ERROR =================
      if (res['success'] != true || res['token'] == null) {
        showMsg(res['error'] ?? "Login failed ❌");
        return;
      }

      // ================= SAVE SESSION =================
      await StorageService.saveToken(res['token']);
      await StorageService.saveUserId(res['user']['id']);
      await StorageService.saveRole(res['user']['role']);

      showMsg("Welcome back 👋", ok: true);

      if (!mounted) return;

      // ================= NAVIGATION =================
     Navigator.of(context).pushNamedAndRemoveUntil(
  '/home',
  (route) => false,
);

    } catch (e) {
      setState(() {
  loading = false;
});
      showMsg("Connection error ❌");
    }
  }

  // ================= UI INPUT =================
  InputDecoration input(String label, IconData icon) {
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

  String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return "Email required";
    if (!v.contains("@")) return "Invalid email";
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return "Password required";
    if (v.length < 6) return "Min 6 characters";
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

      body: Stack(
        children: [

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  const SizedBox(height: 40),

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
                    "Login to continue",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // ================= EMAIL =================
                  TextFormField(
                    controller: emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: input("Email", Icons.email),
                  ),

                  const SizedBox(height: 15),

                  // ================= PASSWORD =================
                  TextFormField(
                    controller: passwordController,
                    validator: validatePassword,
                    obscureText: hidePassword,
                    decoration: input("Password", Icons.lock).copyWith(
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

                  // ================= LOGIN BUTTON =================
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("LOGIN"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      "Create new account",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= LOADING OVERLAY =================
          if (loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}