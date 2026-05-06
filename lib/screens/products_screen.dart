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

  // ================= LOAD PRODUCTS =================
  Future<void> load() async {
    setState(() {
  loading = true;
});

    try {
      final data = await ApiService.getProducts();

      setState(() {
        products = data;
        loading = false;
      });
    } catch (e) {
    setState(() {
  loading = false;
});
    }
  }

  // ================= MESSAGE =================
  void msg(String text, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= ADD TO CART =================
 Future<void> addToCart(product) async {
  final token = await StorageService.getToken();

  if (token == null) {
    Navigator.pushNamed(context, '/login');
    return;
  }

  try {
    await ApiService.addToCart(token, product['id']);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart ✔️")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error ❌")),
    );
  }
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products 🛍️"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: load,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products"))
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
                          children: [

                            // IMAGE
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  "$baseUrl/uploads/${p['image']}",
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    p['name'] ?? "",
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "${p['price']} DA",
                                    style: const TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // CHAT
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/chat',
                                          arguments:
                                              p['seller_id'],
                                        );
                                      },
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.blue,
                                      ),
                                      child: const Text(
                                          "Message 💬"),
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // CART
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: adding
                                          ? null
                                          : () => addToCart(
                                              p['id']),
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.deepPurple,
                                      ),
                                      child:
                                          const Text("Add 🛒"),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}