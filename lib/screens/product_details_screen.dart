import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProductDetailsScreen extends StatelessWidget {
  final dynamic product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "https://my-server-0xa0.onrender.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // IMAGE
          SizedBox(
            height: 250,
            width: double.infinity,
            child: product['image'] != null
                ? Image.network(
                    "$baseUrl/uploads/${product['image']}",
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 100),
          ),

          const SizedBox(height: 10),

          // NAME
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              product['name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // PRICE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "${product['price']} DA",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // BUTTONS
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [

                // ADD TO CART
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String? token =
                          await StorageService.getToken();

                      await ApiService.addToCart(
                        token!,
                        product['id'],
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Added to cart 🛒"),
                        ),
                      );
                    },
                    child: const Text("Add to Cart"),
                  ),
                ),

                const SizedBox(height: 10),

                // BUY NOW
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () async {
                      String? token =
                          await StorageService.getToken();

                      await ApiService.addToCart(
                        token!,
                        product['id'],
                      );

                      await ApiService.checkout(token);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order placed ✅"),
                        ),
                      );
                    },
                    child: const Text("Buy Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}