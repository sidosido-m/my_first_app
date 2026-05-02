import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List products = [];
  bool loading = true;

  String? token;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    token = await StorageService.getToken();

    if (token != null) {
      final data = await ApiService.getMyProducts(token!);

      setState(() {
        products = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Products 📦"),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products yet"))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];

                    return ListTile(
                      title: Text(p['name']),
                      subtitle: Text("${p['price']} DA"),
                    );
                  },
                ),
    );
  }
}