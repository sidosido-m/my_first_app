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
    if (token != null) {
  final res = await ApiService.getProfile(token);

  setState(() {
    userData = res['user'];
  });
}

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
  if (!mounted) return;
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
     setState(() {
  loading = false;
});
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
  userData?['name'] ?? "User",
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

accountEmail: Text(
  "@${userData?['username'] ?? ''}",
  style: const TextStyle(color: Colors.white70),
),
  currentAccountPicture: GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, '/profile');
    },
    child: CircleAvatar(
     backgroundImage: (userData?['image'] != null &&
        userData!['image'].toString().isNotEmpty)
    ? NetworkImage(userData!['image'])
    : const AssetImage("assets/user.png") as ImageProvider,
    ),
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

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ================= HEADER (SELLER) =================
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [

              CircleAvatar(
                radius: 18,
                backgroundImage: product['seller_image'] != null
                    ? NetworkImage(product['seller_image'])
                    : const AssetImage("assets/user.png") as ImageProvider,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      product['seller_name'] ?? "Unknown",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // 🟢 DATE (NEW)
                    Text(
                      product['created_at'] ?? "recently",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.more_vert),
            ],
          ),
        ),

        // ================= IMAGE =================
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product['image'] ??
                "https://via.placeholder.com/300",
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 10),

        // ================= PRICE + VIEW BUTTON =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [

              // PRICE
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${product['price']} DA",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

              const Spacer(),

              // VIEW BUTTON (🔥 stylish)
              ElevatedButton(
                onPressed: () => openProduct(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                ),
                child: const Text("View"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ================= ACTIONS (LIKE + CART) =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [

              // ❤️ LIKE
              IconButton(
                onPressed: () async {
                  final token = await StorageService.getToken();
                  if (token == null) return;

                  final result = await ApiService.toggleLike(
                    token,
                    product['id'],
                  );

                  setState(() {
                    product['liked'] = result['liked'];
                    product['likes_count'] = result['likes_count'];
                  });
                },
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),

              Text("${product['likes_count'] ?? 0}"),

              const Spacer(),

              // 🛒 CART
              ElevatedButton.icon(
                onPressed: adding
                    ? null
                    : () => addToCart(product['id']),
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: const Text("Cart"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        title: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    // 🔥 زر البروفايل الصغير
    GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/profile');
      },
      child: CircleAvatar(
        radius: 16,
        backgroundImage: (userData?['image'] != null &&
        userData!['image'].toString().isNotEmpty)
    ? NetworkImage(userData!['image'])
    : const AssetImage("assets/user.png") as ImageProvider,
      ),
    ),

    const SizedBox(width: 10),

    const Text("Marketplace 🛒"),
  ],
),

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