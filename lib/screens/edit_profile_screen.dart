import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? token;
  File? imageFile;
  String? imageUrl;

  bool loading = false;
  bool isFetching = true;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    token = await StorageService.getToken();

    if (token != null) {
      final res = await ApiService.getProfile(token!);
      final user = res['user'];

      setState(() {
        nameController.text = user['name'] ?? "";
        emailController.text = user['email'] ?? "";
        imageUrl = user['image'];
        isFetching = false;
      });
    }
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

  Future<void> updateProfile() async {
    if (token == null) return;

    setState(() => loading = true);

    try {
      await ApiService.updateProfileWithImage(
        token!,
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.isEmpty
            ? null
            : passwordController.text.trim(),
        imageFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated ✅"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // رجوع للبروفايل
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Update failed ❌"),
        ),
      );
    }

    setState(() => loading = false);
  }

  ImageProvider _buildImage() {
    if (imageFile != null) return FileImage(imageFile!);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage("$baseUrl/uploads/$imageUrl");
    }

    return const AssetImage("assets/default_user.png");
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile ✏️"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          : const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}