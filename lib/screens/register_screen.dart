import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "customer";
  bool isHuman = false;
  bool isLoading = false;

  void showMsg(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMsg("Fill all fields ❌");
      return;
    }

    if (!isHuman) {
      showMsg("Confirm you're not robot 🤖");
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.registerUser(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      role,
    );

    setState(() => isLoading = false);

    if (result['success'] != true) {
      showMsg(result['error'] ?? "Error ❌");
      return;
    }

    showMsg("OTP sent ✅", success: true);

    // ✅ إرسال البيانات لصفحة OTP
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          role: role, // 🔥 نفس المتغير
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 20),

              const Icon(Icons.person_add, size: 80, color: Colors.deepPurple),

              const SizedBox(height: 10),

              const Text(
                "Join Us 🚀",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              _buildInput(nameController, "Full Name", Icons.person),
              const SizedBox(height: 15),

              _buildInput(emailController, "Email", Icons.email),
              const SizedBox(height: 15),

              _buildInput(passwordController, "Password", Icons.lock, obscure: true),

              const SizedBox(height: 20),

              _buildRoleSelector(),

              CheckboxListTile(
                value: isHuman,
                onChanged: (v) => setState(() => isHuman = v!),
                title: const Text("I am not a robot"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: role,
        isExpanded: true,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: "customer", child: Text("Customer 🛒")),
          DropdownMenuItem(value: "seller", child: Text("Seller 🏪")),
        ],
        onChanged: (v) => setState(() => role = v!),
      ),
    );
  }
}