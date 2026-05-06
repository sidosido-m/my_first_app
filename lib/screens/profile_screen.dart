import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../screens/followers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? user;
  List products = [];
  int followersCount = 0;
  int followingCount = 0;
  double rating = 0;

  bool loading = true;
  String baseUrl = "https://my-server-0xa0.onrender.com";

  late TabController tabController;
  

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadProfile();
  }

  // ================= LOAD DATA =================
  Future<void> loadProfile() async {
  try {
    final token = await StorageService.getToken();

    if (token == null) return;

    final profileRes = await ApiService.getProfile(token);
    final int id = profileRes['user']['id'];

    final sellerRes = await ApiService.getSeller(id);
    final statsRes = await ApiService.getSellerStats(id);

    final Map<String, dynamic> sellerData =
        sellerRes as Map<String, dynamic>;

    final Map<String, dynamic> stats =
        statsRes as Map<String, dynamic>;

    setState(() {
      user = sellerData['seller'];
      products = List.from(sellerData['products']);

      followersCount = int.tryParse(stats['followers'].toString()) ?? 0;
      followingCount = int.tryParse(stats['following'].toString()) ?? 0;
      rating = double.tryParse(stats['rating'].toString()) ?? 0.0;

      loading = false;
    });
  } catch (e) {
    print("PROFILE ERROR ❌ $e");
    setState(() => loading = false);
  }
}
  // ================= IMAGE FIX =================
  String fixImage(String? img) {
    if (img == null || img.isEmpty) return "";
    if (img.startsWith("http")) return img;
    return "$baseUrl/uploads/$img";
  }
  Future<void> refresh() async {
  await loadProfile();
}

  @override
  Widget build(BuildContext context) {
    final bg = user?['background_image'];
    final avatar = user?['image'];

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [

                    // ================= COVER =================
                    Stack(
                      clipBehavior: Clip.none,
                      children: [

                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: (bg != null && bg.toString().isNotEmpty)
                                  ? NetworkImage(fixImage(bg))
                                  : const NetworkImage(
                                      "https://via.placeholder.com/800x200",
                                    ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 40,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        Positioned(
                          bottom: -45,
                          left: 20,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: (avatar != null &&
                                    avatar.toString().isNotEmpty)
                                ? NetworkImage(fixImage(avatar))
                                : const NetworkImage(
                                    "https://ui-avatars.com/api/?name=user",
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 55),

                    // ================= USER INFO =================
                    Text(
                      user?['name'] ?? "",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),

                    Text(
                      "@${user?['username'] ?? 'user'}",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 15),

                    // ================= STATS =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _stat("Followers", followersCount.toString()),
                          _stat("Following", followingCount.toString()),
                          _stat("Rating", rating.toStringAsFixed(1)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ================= EDIT =================
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "/edit-profile");
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ================= TABS =================
                    TabBar(
                      controller: tabController,
                      labelColor: Colors.deepPurple,
                      tabs: const [
                        Tab(text: "Products"),
                        Tab(text: "About"),
                      ],
                    ),

                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: tabController,
                        children: [

                          // ================= PRODUCTS =================
                          ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, i) {
                              final p = products[i];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      fixImage(p['image']),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image),
                                    ),
                                  ),
                                  title: Text(p['name'] ?? ""),
                                  subtitle: Text("${p['price']} DA"),
                                ),
                              );
                            },
                          ),

                          // ================= ABOUT =================
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "About Seller",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Name: ${user?['name']}\n"
                                  "Username: @${user?['username']}\n"
                                  "Rating: ${rating.toStringAsFixed(1)} ⭐",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _stat(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(title),
        ],
      ),
    );
  }
}