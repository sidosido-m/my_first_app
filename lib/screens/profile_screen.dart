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
  setState(() => isFetching = true);

  token = await StorageService.getToken();
  role = await StorageService.getRole();

  if (token != null) {
    try {
      final res = await ApiService.getProfile(token!);
      final user = res['user']; // 👈 هنا التعديل

      setState(() {
        nameController.text = user['name'] ?? "";
        emailController.text = user['email'] ?? "";
        imageUrl = user['image'];
      });
    } catch (e) {
      showMsg("Failed to load profile ❌");
    }
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
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.pushNamed(context, '/edit-profile');
          },
        )
      ],
    ),

    body: isFetching
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // ================= IMAGE =================
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.deepPurple,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _buildImage(),
                  ),
                ),

                const SizedBox(height: 10),

                // ================= NAME =================
                Text(
                  nameController.text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // ================= EMAIL =================
                Text(
                  emailController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                // ================= ROLE =================
                Chip(
                  label: Text("Role: ${role ?? 'user'}"),
                ),

                const SizedBox(height: 30),
                SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.pushNamed(context, '/my-products');
    },
    icon: const Icon(Icons.inventory_2),
    label: const Text("My Products 📦"),
  ),
),

                // ================= BUTTONS =================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/orders');
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("My Orders"),
                  ),
                ),


                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ),
  );
}
}