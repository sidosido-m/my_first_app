import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  List filtered = [];
  bool loading = true;

  bool isLoggedIn = false;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final token = await StorageService.getToken();

    setState(() {
      isLoggedIn = token != null;
    });

    final data = await ApiService.getProducts();

    setState(() {
      products = data;
      filtered = data;
      loading = false;
    });
  }

  void search(String text) {
    final q = text.toLowerCase();

    setState(() {
      filtered = products.where((p) {
        final name = p['name']?.toLowerCase() ?? '';
        return name.contains(q);
      }).toList();
    });
  }

  // ================= DRAWER (for logged in only) =================
  Widget buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            accountName: Text("User"),
            accountEmail: Text("Welcome back"),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
          ),

          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Cart"),
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("Orders"),
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),

          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("Messages"),
            onTap: () => Navigator.pushNamed(context, '/chat'),
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              await StorageService.clearAll();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT CARD =================
  Widget productCard(product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              "$baseUrl/uploads/${product['image']}",
              fit: BoxFit.cover,
            ),
          ),
          Text(product['name'] ?? ""),
          Text("${product['price']} DA"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ================= APPBAR DYNAMIC =================
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Marketplace"),

        actions: isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              ]
            : [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
      ),

      // ================= DRAWER ONLY IF LOGGED IN =================
      drawer: isLoggedIn ? buildDrawer() : null,

      body: Column(
        children: [

          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: search,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // ================= PRODUCTS =================
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return productCard(filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}