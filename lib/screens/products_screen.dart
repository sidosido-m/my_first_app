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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await ApiService.getProducts();
    setState(() {
      products = data;
      loading = false;
    });
  }

  Future<void> addToCart(int id) async {
    final token = await StorageService.getToken();
    await ApiService.addToCart(token!, id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added 🛒")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
              onPressed: load,
              icon: const Icon(Icons.refresh)),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (c, i) {
                final p = products[i];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [

                      Expanded(
                        child: Image.network(
                          "https://my-server-0xa0.onrender.com/uploads/${p['image']}",
                          fit: BoxFit.cover,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          p['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      Text("${p['price']} DA"),

                      ElevatedButton(
                        onPressed: () => addToCart(p['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text("Add to cart"),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}