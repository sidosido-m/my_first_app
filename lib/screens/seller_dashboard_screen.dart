import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../screens/edit_product_screen.dart';
import '../screens/add_product_screen.dart';


class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState
    extends State<SellerDashboardScreen> {
      final ScrollController scrollController = ScrollController();
  Map<String, dynamic>? user;
  List latestProducts = [];
  String productsCount = "0";
  List filtered = [];
List products = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        setState(() {
          loading = false;
          error = "No token found";
        });
        return;
      }

      final res = await ApiService.getSellerDashboard(token);

      setState(() {
        user = res['user'];
        latestProducts = res['latestProducts'] ?? [];
        productsCount = res['productsCount'].toString();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Dashboard error";
      });
    }
  }
  Future<void> addToCart(int productId) async {
  final token = await StorageService.getToken();
  if (token == null) return;

  await ApiService.addToCart(token, productId);
}

Future<void> loadCartCount() async {
  final token = await StorageService.getToken();
  if (token == null) return;

  final cart = await ApiService.getCart(token);

  setState(() {
    // إذا عندك cart badge
  });
}

Future<void> loadProducts() async {
  final token = await StorageService.getToken();
  if (token == null) return;

  final userId = await StorageService.getUserId();
    if (userId == null) return;
final data = await ApiService.getSellerProducts(userId);
  setState(() {
    products = data;
    filtered = data; // 🔴 مهم
  });
}

  Widget statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget productCard(dynamic product) {
  bool liked = product['liked'] ?? false;

  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(
        context,
        '/product-details',
        arguments: product,
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= SELLER HEADER =================
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/seller-profile',
                      arguments: product['seller_id'],
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: product['seller_image'] != null
                        ? NetworkImage(product['seller_image'])
                        : const AssetImage("assets/user.png")
                            as ImageProvider,
                  ),
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
                        ),
                      ),
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
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              product['image'] ??
                  "https://via.placeholder.com/300",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          // ================= PRICE =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "${product['price']} DA",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ================= ACTIONS =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                      final index = filtered.indexOf(product);
                      if (index != -1) {
                        filtered[index] = {
                          ...product,
                          'liked': result['liked'],
                          'likes_count': result['likes_count'],
                        };
                      }
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
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () async {
                    await addToCart(product['id']);
                    await loadCartCount();
                  },
                ),

                // ✏️ EDIT (إذا أنت صاحب المنتج فقط)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductScreen(
                          product: product,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        loadProducts();
                      }
                    });
                  },
                ),

                // 🗑 DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final token = await StorageService.getToken();
                    if (token == null) return;

                    await ApiService.deleteProduct(
                        token, product['id']);

                    loadProducts();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final image = user?['image'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard 🏪"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadDashboard,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : error != null
              ? Center(child: Text(error!))

              : user == null
                  ? const Center(child: Text("No data"))

                  : RefreshIndicator(
                      onRefresh: loadDashboard,
                      child: SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [

                            const SizedBox(height: 20),

                            // ================= PROFILE =================
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Colors.deepPurple,
                              backgroundImage:
                                  (image != null &&
                                          image.isNotEmpty)
                                      ? NetworkImage(image)
                                      : null,
                              child: image == null
                                  ? const Icon(Icons.store,
                                      size: 40,
                                      color: Colors.white)
                                  : null,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              user?['name'] ?? "",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold),
                            ),

                            const SizedBox(height: 20),

                            // ================= STATS =================
                            Row(
                              children: [
                                statCard(
                                    "Products",
                                    productsCount,
                                    Icons.inventory),
                                statCard(
                                    "Seller",
                                    user?['name'] ?? "",
                                    Icons.person),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ================= BUTTONS =================
                            Padding(
                              padding:
                                  const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  ElevatedButton.icon(
  onPressed: () async {
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();

    if (token == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    if (userId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("User not loaded")),
  );
  return;
}

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AddProductScreen(
      sellerId: userId,
      token: token,
    ),
  ),
);
  },
  icon: const Icon(Icons.add),
  label: const Text("Add Product"),
),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context,
                                          '/my-products');
                                    },
                                    icon:
                                        const Icon(Icons.list),
                                    label: const Text(
                                        "My Products"),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(),

                            // ================= PRODUCTS =================
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft,
                                child: Text(
                                  "Latest Products",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                              ),
                            ),

                            latestProducts.isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(20),
                                    child:
                                        Text("No products"),
                                  )
                                : Column(
                                    children:
                                        latestProducts
                                            .map((p) =>
                                                productCard(
                                                    p))
                                            .toList(),
                                  ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
    );
  }
}