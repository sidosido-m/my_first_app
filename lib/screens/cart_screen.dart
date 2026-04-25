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

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    token = await StorageService.getToken();
    final data = await ApiService.getCart(token!);

    setState(() {
      cart = data;
    });
  }

  Future<void> checkout() async {
    await ApiService.checkout(token!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully 🎉")),
    );

    loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart 🛒"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];

                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("${item['price']} DA"),
                  trailing: Text("x${item['quantity']}"),
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: checkout,
            child: const Text("Checkout 💳"),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}