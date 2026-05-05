import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../screens/followers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? user;
  List products = [];
  int followersCount = 0;
int followingCount = 0;
double rating = 0;
List followers = [];

  bool loading = true;
  String baseUrl =
      "https://my-server-0xa0.onrender.com";

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadProfile();
  }

 Future<void> loadProfile() async {
  final token = await StorageService.getToken();

  final res = await ApiService.getProfile(token!);
  final id = res['user']['id'];

  final seller = await ApiService.getSeller(id);
  final stats = await ApiService.getSellerStats(id);
  final followersRes = await ApiService.getFollowers(id);

  setState(() {
    user = seller['seller'];
    products = seller['products'];

    followers = followersRes;

    followersCount = int.parse(stats['followers'].toString());
    followingCount = int.parse(stats['following'].toString());
    rating = double.parse(stats['rating'].toString());

    loading = false;
  });
}

  // ================= IMAGE HELPER =================
  String fixImage(String? img) {
    if (img == null || img.isEmpty) return "";

    if (img.startsWith("http")) return img;

    return "$baseUrl/uploads/$img";
  }

  @override
  Widget build(BuildContext context) {
                      final bg = user?['background_image'];
                      final avatar = user?['image'];
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // ================= COVER =================
                Stack(
                  clipBehavior: Clip.none,
                  children: [

                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
  image: DecorationImage(
    image: bg != null
        ? NetworkImage(bg)
        : const AssetImage("assets/cover.jpg")
            as ImageProvider,
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
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                    ),

                    Positioned(
                      bottom: -40,
                      left: 20,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage:
                            user?['image'] != null
                                ? NetworkImage(
                                    fixImage(user!['image']))
                                : const AssetImage(
                                        "assets/user.png")
                                    as ImageProvider,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // ================= NAME =================
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
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [

    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FollowersScreen(sellerId: user!['id'],),
          ),
        );
      },
      child: _stat("Followers", followersCount.toString()),
    ),

    _stat("Following", followingCount.toString()),

    _stat("Rating", rating.toStringAsFixed(1) + " ⭐"),
  ],
),

                const SizedBox(height: 10),

                // ================= EDIT BUTTON =================
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, "/edit-profile");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      const Text("Edit Profile ✏️"),
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

                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [

                      // ================= PRODUCTS =================
                      ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, i) {
                          final p = products[i];

                          return Card(
                            margin:
                                const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: Image.network(
                                  fixImage(p['image']),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              title: Text(p['name'] ?? ""),

                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text("${p['price']} DA"),
                                  Text(
                                    "Added: ${p['created_at'] ?? 'unknown'}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // ================= ABOUT =================
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "About Seller",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "This seller is active on the marketplace and sells quality products.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        Text(title),
      ],
    );
  }
}