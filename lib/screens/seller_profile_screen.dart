import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/image_helper.dart';
import '../services/supabase_storage.dart';

class SellerProfileScreen extends StatefulWidget {
  final int sellerId;

  const SellerProfileScreen({super.key, required this.sellerId});

  @override
  State<SellerProfileScreen> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  Map<String, dynamic>? seller;
  List products = [];
  List followers = [];
  List following = [];

  bool loading = true;
  bool isFollowing = false;

  int followersCount = 0;
  int followingCount = 0;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ================= LOAD =================
  Future<void> loadData() async {
    try {
      final data = await ApiService.getSeller(widget.sellerId);

      final followersData =
          await ApiService.getFollowers(widget.sellerId);

      final followingData =
          await ApiService.getFollowing(widget.sellerId);

      setState(() {
        seller = data['seller'];
        products = data['products'];

        followers = followersData;
        following = followingData;

        followersCount = followersData.length;
        followingCount = followingData.length;

        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => loading = false);
    }
  }

  // ================= IMAGE SAFE (IMPROVED + SUPABASE READY) =================
  String imageUrl(String? img) {
    if (img == null || img.isEmpty) return "";

    // ✅ إذا رابط Supabase كامل
    if (img.startsWith("http")) return img;

    // ✅ إذا من السيرفر
    return "$baseUrl/uploads/$img";
  }

  // ================= FOLLOWERS SHEET =================
  void showUsers(List list, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ...list.map((u) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: u['image'] != null
                      ? NetworkImage(imageUrl(u['image']))
                      : null,
                  child: u['image'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(u['name'] ?? ""),
                subtitle: Text("@${u['username'] ?? 'user'}"),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/seller-profile',
                    arguments: u['id'],
                  );
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // ================= PRODUCT CARD =================
  Widget productCard(p) {
    return ListTile(
      leading: Image.network(
        imageUrl(p['image']),
        width: 55,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image),
      ),
      title: Text(p['name'] ?? ""),
      subtitle: Text("${p['price']} DA"),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    // 🔥 SUPABASE + SERVER SAFE HANDLING
    final bg = imageUrl(seller?['background_image']);
    final avatar = imageUrl(seller?['image']); // ممكن تغيرها avatar لاحقاً

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [

                // ================= BACKGROUND (IMPROVED SAFE LOAD) =================
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: bg.isNotEmpty
                      ? Image.network(
                          bg,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.deepPurple),
                        )
                      : Container(color: Colors.deepPurple),
                ),

                Container(
                  height: 260,
                  color: Colors.black.withOpacity(0.4),
                ),

                // ================= CONTENT =================
                SingleChildScrollView(
                  child: Column(
                    children: [

                      const SizedBox(height: 180),

                      // ================= CARD =================
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [

                            // PROFILE IMAGE (IMPROVED)
                            CircleAvatar(
                              radius: 45,
                              backgroundImage: avatar.isNotEmpty
                                  ? NetworkImage(avatar)
                                  : null,
                              child: avatar.isEmpty
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              seller?['name'] ?? "",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),

                            Text(
                              "@${seller?['username'] ?? 'user'}",
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 15),

                            // ================= STATS =================
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [

                                Column(
                                  children: [
                                    Text("${products.length}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const Text("Products"),
                                  ],
                                ),

                                GestureDetector(
                                  onTap: () =>
                                      showUsers(followers, "Followers"),
                                  child: Column(
                                    children: [
                                      Text("$followersCount",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const Text("Followers"),
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () =>
                                      showUsers(following, "Following"),
                                  child: Column(
                                    children: [
                                      Text("$followingCount",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const Text("Following"),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // ================= BUTTONS =================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Follow"),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/chat',
                                      arguments: widget.sellerId,
                                    );
                                  },
                                  child: const Text("Message"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Products",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      ...products.map(productCard),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}