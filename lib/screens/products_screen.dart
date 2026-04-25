import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // 🔄 تحميل المنتجات
  Future<void> loadProducts() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.getProducts();

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showMsg("Error loading products ❌");
    }
  }

  // 🛒 إضافة للسلة
  Future<void> addToCart(int productId) async {
    String? token = await StorageService.getToken();

    if (token == null) {
      showMsg("You must login first ❌");
      return;
    }

    await ApiService.addToCart(token, productId);

    showMsg("Added to cart 🛒", success: true);
  }

  // 🚪 تسجيل الخروج
  Future<void> logout() async {
    await StorageService.clearToken();
    await StorageService.clearUserId();
    await StorageService.clearRole();

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  // 📢 رسالة
  void showMsg(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // 🖼️ صورة المنتج
  Widget buildImage(String? image) {
    if (image == null || image.isEmpty) {
      return const Icon(Icons.image, size: 80, color: Colors.grey);
    }

    return Image.network(
      "https://my-server-0xa0.onrender.com/uploads/$image",
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 80),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products 🛒"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () =>
                Navigator.pushNamed(context, '/cart'),
          ),
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
                    itemBuilder: (context, i) {
                      var p = products[i];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [

                            // 🖼️ IMAGE
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: buildImage(p['image']),
                              ),
                            ),

                            // 📦 NAME
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                p['name'] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 💰 PRICE
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                "${p['price']} DA",
                                style: const TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            // 🛒 BUTTON
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: ElevatedButton(
                                onPressed: () =>
                                    addToCart(p['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurple,
                                ),
                                child: const Text("Add to cart"),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}