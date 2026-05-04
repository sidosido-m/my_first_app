import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'seller_profile_screen.dart';
import 'seller_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;
  List products = [];
  List filtered = [];

  bool loading = true;
  bool adding = false;
  bool isLoggedIn = false;
  int cartCount = 0;
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
    final res = await ApiService.getProfile(token!);

setState(() {
  userData = res['user'];
});

    setState(() {
      isLoggedIn = token != null;
      role = userRole;
    });
    await loadCartCount();
    await loadProducts();
  }
   // ================= CART =================
  Future<void> addToCart(int productId) async {
  final token = await StorageService.getToken();

  if (token == null) {
    Navigator.pushNamed(context, '/login');
    return;
  }

  setState(() => adding = true);

  try {
    await ApiService.addToCart(token, productId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart ✔️")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error ❌")),
    );
  }

  setState(() => adding = false);
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

// ================= LOAD CARTCOUNT =================
  Future<void> loadCartCount() async {
  final token = await StorageService.getToken();
  if (token == null) return;

  final cart = await ApiService.getCart(token);
  setState(() {
    cartCount = cart.length;
  });
}

  // ================= DRAWER =================
  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
           UserAccountsDrawerHeader(
  decoration: const BoxDecoration(color: Colors.deepPurple),
  accountName: Text(
  userData != null ? userData!['name'] ?? "User" : "User",
),
  accountEmail: Text(userData?['email'] ?? ""),

  currentAccountPicture: CircleAvatar(
    backgroundImage: userData?['image'] != null
        ? NetworkImage(userData!['image'])
        : null,
    child: userData?['image'] == null
        ? const Icon(Icons.person, color: Colors.deepPurple)
        : null,
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

          role == "seller"
    ? ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text("Dashboard 📊"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SellerDashboardScreen(),
            ),
          );
        },
      )
    : ListTile(
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
    bool liked = product['liked'] ?? false;
    bool isLiked = false;
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
                child: 
  Image.network(
  product['image'] != null &&
          product['image'].toString().isNotEmpty
      ? product['image']
      : "https://via.placeholder.com/150",
  width: double.infinity,
  fit: BoxFit.cover,

  // 🔥 Loading جميل
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return const Center(
      child: CircularProgressIndicator(),
    );
  },

  // 🔥 Error fallback
  errorBuilder: (_, __, ___) {
    return const Center(
      child: Icon(Icons.broken_image, size: 40),
    );
  },
),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // NAME
                  GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellerProfileScreen(
          sellerId: product['seller_id'],
        ),
      ),
    );
  },
  child: Row(
    children: [
      const Icon(Icons.store, size: 14, color: Colors.grey),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          product['seller_name'] ?? "Unknown",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
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
                 // زر View
    SizedBox(
      width: double.infinity,
      height: 30,
      child: ElevatedButton(
        onPressed: () => openProduct(product),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
        ),
        child: const Text("View"),
      ),
    ),

    const SizedBox(height: 5),

    // زر Add to Cart
    SizedBox(
      width: double.infinity,
      height: 30,
      child: ElevatedButton(
        onPressed: adding ? null : () => addToCart(product['id']),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
        ),
        child: adding
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("Add 🛒"),
      ),
    ),
   Positioned(
  top: 5,
  right: 5,
  child: GestureDetector(
    onTap: () async {
      final token = await StorageService.getToken();
      if (token == null) return;

      final result = await ApiService.toggleLike(
        token,
        product['id'],
      );

      setState(() {
        product['liked'] = result;
      });
    },
    child: Icon(
      product['liked'] == true
          ? Icons.favorite
          : Icons.favorite_border,
      color: Colors.red,
    ),
  ),
),
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
               Stack(
  children: [
    IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () async {
        await Navigator.pushNamed(context, '/cart');
        loadCartCount(); // 🔥 تحديث بعد الرجوع
      },
    ),
    if (cartCount > 0)
      Positioned(
        right: 6,
        top: 6,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$cartCount",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      )
  ],
)
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