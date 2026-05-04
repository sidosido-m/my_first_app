import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ FIX
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../servise/supabase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();

  File? profileImage;
  File? coverImage;

  bool loading = false;
  String? token;

  final supabase = Supabase.instance.client;

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
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  // ================= PICK COVER IMAGE =================
  Future<void> pickCover() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        coverImage = File(picked.path);
      });
    }
  }

  // ================= UPLOAD (AVATARS ONLY) =================
  Future<String?> upload(File file, String type) async {
    try {
      final name =
          "${type}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage
          .from('avatars') // 🔥 ثابت كما طلبت
          .upload(name, file);

      return supabase.storage
          .from('avatars')
          .getPublicUrl(name);
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      return null;
    }
  }

  // ================= SAVE =================
 Future<void> save() async {
  setState(() => loading = true);

  String? profileUrl = user?['image'];
  String? bgUrl = user?['background_image'];

  // ================= AVATAR =================
  if (profileImage != null) {
    profileUrl =
        await SupabaseStorage.uploadAvatar(profileImage!);
  }

  // ================= BACKGROUND =================
  if (coverImage != null) {
    bgUrl =
        await SupabaseStorage.uploadBackground(coverImage!);
  }

  await ApiService.updateProfile(
    token!,
    nameCtrl.text.trim(),
    emailCtrl.text.trim(),
    profileUrl,
    bgUrl, // ⚠️ لازم تضيفها في API
  );

  setState(() => loading = false);

  Navigator.pop(context, true);
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final cover = coverImage != null
        ? FileImage(coverImage!)
        : (user?['background_image'] != null
            ? NetworkImage(user!['background_image'])
            : const AssetImage("assets/cover.jpg"))
        as ImageProvider;

    final avatar = profileImage != null
        ? FileImage(profileImage!)
        : (user?['image'] != null
            ? NetworkImage(user!['image'])
            : const AssetImage("assets/user.png"))
        as ImageProvider;

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
                            labelText: "Name"),
                      ),

                      TextField(
                        controller: userCtrl,
                        decoration: const InputDecoration(
                            labelText: "Username"),
                      ),

                      TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                            labelText: "Email"),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: oldPassCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: "Old Password"),
                      ),

                      TextField(
                        controller: newPassCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: "New Password"),
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
                          child: const Text("Save Changes"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= LOADING =================
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