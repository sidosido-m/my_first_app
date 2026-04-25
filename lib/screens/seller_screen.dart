import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'add_product_screen.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  List products = [];
  bool isLoading = true;
  bool isActionLoading = false;

  String? token;
  int? sellerId;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    initData();
  }

  // ================= INIT =================
  Future<void> initData() async {
    token = await StorageService.getToken();
    sellerId = await StorageService.getUserId();

    if (sellerId == null) {
      setState(() => isLoading = false);
      return;
    }

    await loadProducts();
  }

  // ================= LOAD =================
  Future<void> loadProducts() async {
    try {
      setState(() => isLoading = true);

      final data = await ApiService.getMyProducts(sellerId!);

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= DELETE =================
  Future<void> deleteProduct(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => isActionLoading = true);

      await ApiService.deleteProduct(token!, id);

      await loadProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted 🗑")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed ❌")),
      );
    } finally {
      setState(() => isActionLoading = false);
    }
  }

  // ================= EDIT =================
  void editProduct(dynamic product) {
    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Product ✏️"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.updateProduct(
                  token!,
                  product['id'],
                  nameController.text,
                  double.parse(priceController.text),
                );

                Navigator.pop(context);
                loadProducts();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Updated ✔️")),
                );
              } catch (e) {
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await StorageService.clearToken();
    await StorageService.clearUserId();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard 🏪"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          if (token == null || sellerId == null) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(
                sellerId: sellerId!,
                token: token!,
              ),
            ),
          );

          if (result == true) loadProducts();
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products yet 😢"))
              : RefreshIndicator(
                  onRefresh: loadProducts,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(

                          leading: p['image'] != null
                              ? Image.network(
                                  "$baseUrl/uploads/${p['image']}",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),

                          title: Text(p['name']),
                          subtitle: Text("${p['price']} DA"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editProduct(p),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteProduct(p['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}