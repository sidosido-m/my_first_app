import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool loadingCart = false;
  bool loadingBuy = false;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  void msg(String text, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= ADD TO CART =================
  Future<void> addToCart() async {
    setState(() => loadingCart = true);

    try {
      final token = await StorageService.getToken();

      if (token == null) {
        msg("Please login first");
        return;
      }

      await ApiService.addToCart(token, widget.product['id']);

      msg("Added to cart 🛒", ok: true);
    } catch (e) {
      msg("Failed to add to cart");
    }

    setState(() => loadingCart = false);
  }

  // ================= BUY NOW =================
  Future<void> buyNow() async {
    setState(() => loadingBuy = true);

    try {
      final token = await StorageService.getToken();

      if (token == null) {
        msg("Please login first");
        return;
      }

      await ApiService.addToCart(token, widget.product['id']);
      await ApiService.checkout(token);

      msg("Order placed successfully 🎉", ok: true);
    } catch (e) {
      msg("Purchase failed");
    }

    setState(() => loadingBuy = false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= IMAGE =================
            SizedBox(
              height: 280,
              width: double.infinity,
              child: product['image'] != null
                  ? Image.network(
                      "$baseUrl/uploads/${product['image']}",
                      fit: BoxFit.cover,
                    )
                  : const Center(child: Icon(Icons.image, size: 100)),
            ),

            const SizedBox(height: 15),

            // ================= NAME =================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                product['name'] ?? "",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),


            // ================= PRICE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "${product['price']} DA",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

GestureDetector(
  onTap: () {
    Navigator.pushNamed(
      context,
      '/seller-profile',
      arguments: product['seller_id'],
    );
  },
  child: Text(
    "Seller: ${product['seller_name'] ?? 'Unknown'}",
    style: const TextStyle(
      fontSize: 16,
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
  ),
),

            // ================= BUTTONS =================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [

                  // ADD TO CART
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loadingCart ? null : addToCart,
                      child: loadingCart
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Add to Cart 🛒"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BUY NOW
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: loadingBuy ? null : buyNow,
                      child: loadingBuy
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Buy Now ⚡"),
                          // 💬 CHAT BUTTON (هنا بالضبط)
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/chat',
              arguments: product['seller_id'],
            );
          },
          child: const Text("Chat with Seller 💬"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}