import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

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
    if (!_formKey.currentState!.validate()) return;

    if (!agree) {
      msg("Accept terms first ❌");
      return;
    }

    if (!notRobot) {
      msg("Confirm you're not a robot ❌");
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: email.text.trim(),
              otpFromServer: res['otp'].toString(),
            ),
          ),
        );
      } else {
        msg(res['error'] ?? "Registration failed ❌");
      }
    } catch (e) {
      setState(() => loading = false);
      msg("Server error ❌");
    }
  }

  InputDecoration input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // 🔥 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔥 Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const SizedBox(height: 60),

                const Text(
                  "Create Account 🚀",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        TextFormField(
                          controller: name,
                          validator: (v) =>
                              v!.isEmpty ? "Enter name" : null,
                          decoration: input("Full Name", Icons.person),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: username,
                          validator: (v) =>
                              v!.isEmpty ? "Enter username" : null,
                          decoration: input("Username", Icons.alternate_email),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: email,
                          validator: (v) {
                            if (v!.isEmpty) return "Enter email";
                            if (!isValidEmail(v)) return "Gmail only";
                            return null;
                          },
                          decoration: input("Email", Icons.email),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: password,
                          obscureText: hidePass,
                          validator: (v) =>
                              v!.length < 6 ? "Min 6 chars" : null,
                          decoration: input("Password", Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() => hidePass = !hidePass);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: confirmPassword,
                          obscureText: true,
                          validator: (v) {
                            if (v != password.text) {
                              return "Passwords not match";
                            }
                            return null;
                          },
                          decoration: input(
                              "Confirm Password", Icons.lock_outline),
                        ),

                        const SizedBox(height: 10),

                        CheckboxListTile(
                          value: agree,
                          onChanged: (v) => setState(() => agree = v!),
                          title: const Text("Agree to terms"),
                        ),

                        CheckboxListTile(
                          value: notRobot,
                          onChanged: (v) => setState(() => notRobot = v!),
                          title: const Text("I'm not a robot 🤖"),
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text("REGISTER"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (loading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}