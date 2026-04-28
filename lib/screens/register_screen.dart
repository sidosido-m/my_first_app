import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool loading = false;
  bool agree = false;
  bool notRobot = false;
  bool hidePass = true;

  void msg(String text, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@gmail\.com$").hasMatch(email);
  }

  Future<void> register() async {
    if (name.text.isEmpty ||
        username.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      msg("Fill all fields ❌");
      return;
    }

    if (!isValidEmail(email.text)) {
      msg("Email must be valid Gmail ❌");
      return;
    }

    if (password.text != confirmPassword.text) {
      msg("Passwords not match ❌");
      return;
    }

    if (!agree) {
      msg("You must accept terms ❌");
      return;
    }

    if (!notRobot) {
      msg("Confirm you are not a robot ❌");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiService.registerUser(
        name.text.trim(),
        username.text.trim(),
        email.text.trim(),
        password.text.trim(),
        "user",
      );

      setState(() => loading = false);

      if (res['success'] == true) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => OtpScreen(email: res['email']),
    ),
  );
}else {
  print(res);
}

    } catch (e) {
      setState(() => loading = false);
      msg("Server error: $e");
    }
  }

  InputDecoration input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(controller: name, decoration: input("Full Name", Icons.person)),
            const SizedBox(height: 10),

            TextField(controller: username, decoration: input("Username", Icons.alternate_email)),
            const SizedBox(height: 10),

            TextField(controller: email, decoration: input("Email (@gmail.com)", Icons.email)),
            const SizedBox(height: 10),

            TextField(
              controller: password,
              obscureText: hidePass,
              decoration: input("Password", Icons.lock).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(hidePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => hidePass = !hidePass),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: confirmPassword,
              obscureText: true,
              decoration: input("Confirm Password", Icons.lock_outline),
            ),

            const SizedBox(height: 15),

            // TERMS
            CheckboxListTile(
              value: agree,
              onChanged: (v) => setState(() => agree = v!),
              title: const Text("I agree to terms & conditions"),
            ),

            // ROBOT CHECK (simple version)
            CheckboxListTile(
              value: notRobot,
              onChanged: (v) => setState(() => notRobot = v!),
              title: const Text("I am not a robot 🤖"),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CREATE ACCOUNT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}