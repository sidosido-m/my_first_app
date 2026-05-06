import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() =>
      _MyProductsScreenState();
}

class _MyProductsScreenState
    extends State<MyProductsScreen> {
  List products = [];
  bool loading = true;
  bool deleting = false;

  String? token;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      setState(() {
  loading = true;
});

      token = await StorageService.getToken();

      if (token == null) {
        setState(() {
  loading = false;
});
        return;
      }

      final data =
          await ApiService.getMyProducts(token!);

      setState(() {
        products = data;
        loading = false;
      });
    } catch (e) {
   setState(() {
  loading = false;
});
      debugPrint("MY PRODUCTS ERROR ❌ $e");
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      setState(() => deleting = true);

      await ApiService.deleteProduct(token!, id);

      setState(() {
        products.removeWhere((p) => p['id'] == id);
        deleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deleted successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => deleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Delete failed ❌"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget productCard(dynamic p) {
    final image = p['image'];

    return Card(
      margin:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10),

        // ================= IMAGE =================
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: image != null && image.toString().isNotEmpty
              ? Image.network(
                  image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                )
              : const Icon(Icons.shopping_bag,
                  size: 40),
        ),

        // ================= TITLE =================
        title: Text(
          p['name'] ?? "",
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),

        subtitle: Text("${p['price']} DA"),

        // ================= ACTIONS =================
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ✏️ EDIT
            IconButton(
              icon: const Icon(Icons.edit,
                  color: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-product',
                  arguments: p,
                ).then((value) {
                  if (value == true) {
                    loadProducts();
                  }
                });
              },
            ),

            // 🗑️ DELETE
            IconButton(
              icon: const Icon(Icons.delete,
                  color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Product"),
                    content: const Text(
                        "Are you sure you want to delete this product?"),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          deleteProduct(p['id']);
                        },
                        child: const Text(
                          "Delete",
                          style:
                              TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2,
              size: 80,
              color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No products yet",
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Products 📦"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadProducts,
          )
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator())

          : RefreshIndicator(
              onRefresh: loadProducts,
              child: products.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(context)
                                      .size
                                      .height *
                                  0.7,
                          child: emptyState(),
                        )
                      ],
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        return productCard(
                            products[i]);
                      },
                    ),
            ),
    );
  }
}