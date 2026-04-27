import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cart = [];
  String? token;
  bool isLoading = true;

  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() => isLoading = true);

    token = await StorageService.getToken();

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final data = await ApiService.getCart(token!);

    double total = 0;

    for (var item in data) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }

    setState(() {
      cart = data;
      totalPrice = total;
      isLoading = false;
    });
  }

  Future<void> checkout() async {
    try {
      await ApiService.checkout(token!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order placed successfully 🎉"),
          backgroundColor: Colors.green,
        ),
      );

      loadCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildCartItem(item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag,
                size: 40, color: Colors.deepPurple),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${item['price']} DA",
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "x${item['quantity']}",
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart 🛒"),
        backgroundColor: Colors.deepPurple,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? const Center(
                  child: Text(
                    "Your cart is empty 🛒",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          return buildCartItem(cart[index]);
                        },
                      ),
                    ),

                    // TOTAL SECTION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ${totalPrice.toStringAsFixed(2)} DA",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ElevatedButton(
                            onPressed: checkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: const Text("Checkout 💳"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}