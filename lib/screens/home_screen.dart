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

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // ================= LOAD PRODUCTS =================
  Future<void> loadProducts() async {
    setState(() => loading = true);

    try {
      final data = await ApiService.getProducts();

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
  final query = text.toLowerCase();

  final result = products.where((p) {
    final name = p['name']?.toLowerCase() ?? '';
    final seller = p['seller_name']?.toLowerCase() ?? '';

    return name.contains(query) || seller.contains(query);
  }).toList();

  setState(() => filtered = result);
}

  // ================= ADD TO CART =================
  Future<void> addToCart(int id) async {
    final token = await StorageService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login first")),
      );
      return;
    }

    await ApiService.addToCart(token, id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Added to cart 🛒"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ================= PRODUCT CARD =================
  Widget productCard(product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-details',
          arguments: product,
        );
      },
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
                  "$baseUrl/uploads/${product['image']}",
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  // SELLER
                  Row(
                    children: [
                      const Icon(Icons.store,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['seller_name'] ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

                  // ADD TO CART
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => addToCart(product['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "Add",
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
        title: const Text("Marketplace 🛒"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadProducts,
        child: Column(
          children: [

            // ================= SEARCH =================
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

            // ================= CATEGORIES =================
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  category("All"),
                  category("Electronics"),
                  category("Clothes"),
                  category("Shoes"),
                  category("Phones"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= PRODUCTS =================
            Expanded(
  child: loading
      ? const Center(child: CircularProgressIndicator())

      : filtered.isEmpty
          ? const Center(
              child: Text(
                "No products found 😢",
                style: TextStyle(fontSize: 18),
              ),
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

  // ================= CATEGORY =================
  Widget category(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(
        label: Text(name),
        backgroundColor: Colors.white,
      ),
    );
  }
}