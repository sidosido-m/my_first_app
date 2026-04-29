import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String? role;

  bool loading = false;
  bool isFetching = true;

  File? imageFile;
  String? imageUrl;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    token = await StorageService.getToken();
    role = await StorageService.getRole();

    if (token != null) {
      try {
        final user = await ApiService.getProfile(token!);

        nameController.text = user['name'] ?? "";
        emailController.text = user['email'] ?? "";
        imageUrl = user['image'];
      } catch (e) {}
    }

    setState(() => isFetching = false);
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
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
      await ApiService.updateProfileWithImage(
        token!,
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim().isEmpty
            ? null
            : passwordController.text.trim(),
        imageFile,
      );

      showMsg("Profile updated ✔️", ok: true);
    } catch (e) {
      showMsg("Update failed ❌");
    }

    setState(() => loading = false);
  }

  Future<void> logout() async {
    await StorageService.clearToken();
    await StorageService.clearUserId();
    await StorageService.clearRole();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  ImageProvider _buildImage() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage("$baseUrl/uploads/$imageUrl");
    }

    return const AssetImage("assets/default_user.png");
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

                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _buildImage(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text("Role: ${role ?? 'user'}"),

                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : updateProfile,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("Update Profile"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/orders');
                      },
                      child: const Text("My Orders 🧾"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: logout,
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}