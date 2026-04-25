import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProductsScreen extends StatefulWidget {
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {

  List products = [];
  bool isLoading = true;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      setState(() => isLoading = true);

      final data = await ApiService.getProducts();

      setState(() {
        products = data;
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading products ❌")),
      );
    }
  }

  Future<void> addToCart(int productId) async {
    String? token = await StorageService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login first ❗")),
      );
      return;
    }

    await ApiService.addToCart(token, productId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart 🛒")),
    );
  }

  Future<void> logout() async {
  await StorageService.clearToken();
  await StorageService.clearUserId();
  await StorageService.clearRole();

  if (!mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}
  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
  title: const Text("Products 🛒"),
  backgroundColor: Colors.deepPurple,
  centerTitle: true,
  actions: [

    IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () => Navigator.pushNamed(context, '/cart'),
    ),
    IconButton(
  icon: const Icon(Icons.person),
  onPressed: () {
    Navigator.pushNamed(context, '/profile');
  },
     ),

    // 🟢 زر الخروج
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: logout,
    ),
  ],
),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : products.isEmpty
              ? const Center(
                  child: Text(
                    "No products yet 😢",
                    style: TextStyle(fontSize: 18),
                  ),
                )

              : RefreshIndicator(
                  onRefresh: loadProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final p = products[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // 🔥 IMAGE
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: p['image'] != null
                                    ? Image.network(
                                        "$baseUrl/uploads/${p['image']}",
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                                child: Icon(Icons.broken_image)),
                                      )
                                    : const Center(
                                        child: Icon(Icons.image, size: 50),
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
                                    p['name'] ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // PRICE
                                  Text(
                                    "${p['price']} DA",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => addToCart(p['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text("Add"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}