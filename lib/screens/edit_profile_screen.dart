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
  // ================= CONTROLLERS =================
  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();

  // ================= IMAGES =================
  File? profileImage;
  File? coverImage;

  // ================= STATE =================
  bool loading = false;
  String? token;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ================= LOAD USER =================
  Future<void> loadUser() async {
    token = await StorageService.getToken();

    final res = await ApiService.getProfile(token!);
    user = res['user'];

    setState(() {
      nameCtrl.text = user?['name'] ?? "";
      userCtrl.text = user?['username'] ?? "";
      emailCtrl.text = user?['email'] ?? "";
    });
  }

  // ================= PICK PROFILE IMAGE =================
  Future<void> pickProfile() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  // ================= PICK COVER IMAGE =================
  Future<void> pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        coverImage = File(picked.path);
      });
    }
  }

  // ================= SAVE PROFILE =================
 Future<void> save() async {
  if (loading) return;

  setState(() => loading = true);

  try {
    final token = await StorageService.getToken();
    if (token == null) throw Exception("Not logged in");

    String? profileUrl;
    String? bgUrl;

    // ================= PROFILE =================
    if (profileImage != null) {
      profileUrl = await ApiService.uploadImage(profileImage!);
      print("NEW PROFILE: $profileUrl");
    }

    // ================= COVER =================
    if (coverImage != null) {
      bgUrl = await ApiService.uploadImage(coverImage!);
      print("NEW BG: $bgUrl");
    }

    // ================= API =================
    final success = await ApiService.updateProfileWithImage(
      token: token,
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      username: userCtrl.text.trim(),
      oldPassword: oldPassCtrl.text.trim().isEmpty
          ? null
          : oldPassCtrl.text.trim(),
      newPassword: newPassCtrl.text.trim().isEmpty
          ? null
          : newPassCtrl.text.trim(),
      imageUrl: profileUrl,
      bgUrl: bgUrl,
    );

    if (!success) throw Exception("Update failed");

    if (mounted) Navigator.pop(context, true);

  } catch (e) {
    print("SAVE ERROR ❌ $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }

  setState(() => loading = false);
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final cover = coverImage != null
    ? FileImage(coverImage!)
    : (user?['background_image'] != null &&
            user!['background_image'].toString().isNotEmpty
        ? NetworkImage(user!['background_image'])
        : const AssetImage("assets/cover.jpg")) as ImageProvider;

    final avatar = profileImage != null
    ? FileImage(profileImage!)
    : (user?['image'] != null && user!['image'].toString().isNotEmpty
        ? NetworkImage(user!['image'])
        : const AssetImage("assets/user.png")) as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [

                // ================= COVER =================
                GestureDetector(
                  onTap: pickCover,
                  child: Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: cover,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: pickCover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ================= AVATAR =================
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: avatar,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickProfile,
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(
                            Icons.edit,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= FIELDS =================
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [

                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Name",
                        ),
                      ),

                      TextField(
                        controller: userCtrl,
                        decoration: const InputDecoration(
                          labelText: "Username",
                        ),
                      ),

                      TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "Email",
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: oldPassCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Old Password",
                        ),
                      ),

                      TextField(
                        controller: newPassCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "New Password",
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ================= SAVE =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Save Changes"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= LOADING OVERLAY =================
          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}