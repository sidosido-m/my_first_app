import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List products = [];
  bool loading = true;
  bool adding = false;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    load();
  }

  void msg(String text, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= LOAD PRODUCTS =================
  Future<void> load() async {
    setState(() => loading = true);

    try {
      final data = await ApiService.getProducts();

      setState(() {
        products = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      msg("Failed to load products");
    }
  }

  // ================= ADD TO CART =================
  Future<void> addToCart(int id) async {
    setState(() => adding = true);

    try {
      final token = await StorageService.getToken();

      if (token == null) {
        msg("Please login first");
        return;
      }

      await ApiService.addToCart(token, id);

      msg("Added to cart 🛒", ok: true);
    } catch (e) {
      msg("Error adding to cart");
    }

    setState(() => adding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop 🛍️"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : products.isEmpty
              ? const Center(
                  child: Text("No products available"),
                )

              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: products.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, i) {
                    final p = products[i];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(product: p),
                          ),
                        );
                      },

                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ================= IMAGE =================
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: p['image'] != null
                                    ? Image.network(
                                        "$baseUrl/uploads/${p['image']}",
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : const Center(
                                        child: Icon(Icons.image),
                                      ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                p['name'] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "${p['price']} DA",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            // ================= BUTTON =================
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: adding
                                    ? null
                                    : () => addToCart(p['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                child: adding
                                    ? const SizedBox(
                                        height: 15,
                                        width: 15,
                                        child:
                                            CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("Add to cart"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}