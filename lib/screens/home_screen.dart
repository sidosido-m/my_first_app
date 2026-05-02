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
  String? role;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    init();
  }

  // ================= INIT =================
  Future<void> init() async {
    final token = await StorageService.getToken();
    final userRole = await StorageService.getRole();

    setState(() {
      isLoggedIn = token != null;
      role = userRole;
    });

    await loadProducts();
  }

  // ================= LOAD PRODUCTS =================
  Future<void> loadProducts() async {
    setState(() => loading = true);

    try {
      final data = await ApiService.getProducts();

    print("PRODUCTS DATA: $data");
      setState(() {
        products = data;
        filtered = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= SEARCH =================
  void search(String text) {
    final q = text.toLowerCase();

    setState(() {
      filtered = products.where((p) {
        final name = p['name']?.toLowerCase() ?? '';
        final seller = p['seller_name']?.toLowerCase() ?? '';
        return name.contains(q) || seller.contains(q);
      }).toList();
    });
  }

  // ================= OPEN PRODUCT =================
  void openProduct(product) {
    Navigator.pushNamed(
      context,
      '/product-details',
      arguments: product,
    );
  }

  // ================= DRAWER =================
  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            accountName: Text("Welcome 👋"),
            accountEmail: Text("User account"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.deepPurple),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Cart 🛒"),
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),

          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text("Orders 📦"),
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile 👤"),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),

          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("Messages 💬"),
            onTap: () => Navigator.pushNamed(context, '/chat'),
          ),

          const Divider(),

          if (role == "seller")
            ListTile(
              leading: const Icon(Icons.store, color: Colors.green),
              title: const Text("Seller Dashboard 🏪"),
              onTap: () {
                Navigator.pushNamed(context, '/seller');
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.store, color: Colors.orange),
              title: const Text("Become a Seller 🏪"),
              onTap: () async {
                final token = await StorageService.getToken();

                if (token == null) return;

                try {
                  await ApiService.becomeSeller(token);

                  await StorageService.saveRole("seller");

                  setState(() {
                    role = "seller";
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You are now a seller 🎉"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error ❌")),
                  );
                }
              },
            ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              await StorageService.clearAll();

              setState(() {
                isLoggedIn = false;
              });

              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT CARD =================
  Widget productCard(product) {
    return GestureDetector(
      onTap: () => openProduct(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  product['image'] != null
                      ? "$baseUrl/uploads/${product['image']}"
                      : "https://via.placeholder.com/150",
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // NAME
                  Text(
                    product['name'] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // 🔥 SELLER NAME
                  Text(
                    product['seller_name'] ?? "Unknown seller",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // PRICE
                  Text(
                    "${product['price']} DA",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => openProduct(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "View",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        title: const Text("Marketplace 🛒"),

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
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, '/login');

                    if (result == true) {
                      final token = await StorageService.getToken();

                      setState(() {
                        isLoggedIn = token != null;
                      });

                      await loadProducts();
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/register');
                    await init();
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
      ),

      drawer: isLoggedIn ? buildDrawer() : null,

      body: RefreshIndicator(
        onRefresh: init,
        child: Column(
          children: [

            // SEARCH
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: search,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // PRODUCTS
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(
                          child: Text("No products 😢"),
                        )
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
      ),
    );
  }
}