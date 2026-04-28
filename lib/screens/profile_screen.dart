import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? token;
  int? userId;
  String? role;

  bool loading = false;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    token = await StorageService.getToken();
    userId = await StorageService.getUserId();
    role = await StorageService.getRole();

    setState(() {
      isFetching = false;
    });
  }

  void showMsg(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> updateProfile() async {
    if (token == null) return;

    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      showMsg("Fill required fields ❌");
      return;
    }

    setState(() => loading = true);

    try {
      await ApiService.updateProfile(
        token!,
        nameController.text = "User";
        emailController.text = "";
        passwordController.text.trim().isEmpty
            ? null
            : passwordController.text.trim(),
      );

      setState(() => loading = false);

      showMsg("Profile updated ✔️", ok: true);
    } catch (e) {
      setState(() => loading = false);
      showMsg("Update failed ❌");
    }
  }

  Future<void> logout() async {
    await StorageService.clearToken();
    await StorageService.clearUserId();
    await StorageService.clearRole();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile 👤"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Role: ${role ?? 'user'}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // NAME
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // EMAIL
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "New Password (optional)",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 25),

                  // UPDATE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text("Update Profile"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: logout,
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}