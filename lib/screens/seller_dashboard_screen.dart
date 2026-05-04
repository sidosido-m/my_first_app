import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState
    extends State<SellerDashboardScreen> {
  Map<String, dynamic>? user;
  List latestProducts = [];
  String productsCount = "0";

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        setState(() {
          loading = false;
          error = "No token found";
        });
        return;
      }

      final res = await ApiService.getSellerDashboard(token);

      setState(() {
        user = res['user'];
        latestProducts = res['latestProducts'] ?? [];
        productsCount = res['productsCount'].toString();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Dashboard error";
      });
    }
  }

  Widget statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget productCard(dynamic product) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      child: ListTile(
        leading: product['image'] != null
            ? Image.network(
                product['image'],
                width: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image),

        title: Text(product['name'] ?? ""),
        subtitle: Text("${product['price']} DA"),

        // ================= ACTIONS =================
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ✏️ EDIT BUTTON
            IconButton(
              icon: const Icon(Icons.edit,
                  color: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-product',
                  arguments: product, // 🔥 هنا الإضافة
                ).then((value) {
                  // refresh بعد التعديل
                  if (value == true) {
                    loadDashboard();
                  }
                });
              },
            ),

            // 🗑️ DELETE BUTTON (اختياري)
            IconButton(
              icon: const Icon(Icons.delete,
                  color: Colors.red),
              onPressed: () async {
                final token =
                    await StorageService.getToken();

                if (token == null) return;

                await ApiService.deleteProduct(
                    token, product['id']);

                loadDashboard();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = user?['image'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard 🏪"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadDashboard,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : error != null
              ? Center(child: Text(error!))

              : user == null
                  ? const Center(child: Text("No data"))

                  : RefreshIndicator(
                      onRefresh: loadDashboard,
                      child: SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [

                            const SizedBox(height: 20),

                            // ================= PROFILE =================
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Colors.deepPurple,
                              backgroundImage:
                                  (image != null &&
                                          image.isNotEmpty)
                                      ? NetworkImage(image)
                                      : null,
                              child: image == null
                                  ? const Icon(Icons.store,
                                      size: 40,
                                      color: Colors.white)
                                  : null,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              user?['name'] ?? "",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold),
                            ),

                            const SizedBox(height: 20),

                            // ================= STATS =================
                            Row(
                              children: [
                                statCard(
                                    "Products",
                                    productsCount,
                                    Icons.inventory),
                                statCard(
                                    "Seller",
                                    user?['name'] ?? "",
                                    Icons.person),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ================= BUTTONS =================
                            Padding(
                              padding:
                                  const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context,
                                          '/add-product');
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                        "Add Product"),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context,
                                          '/my-products');
                                    },
                                    icon:
                                        const Icon(Icons.list),
                                    label: const Text(
                                        "My Products"),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(),

                            // ================= PRODUCTS =================
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft,
                                child: Text(
                                  "Latest Products",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                              ),
                            ),

                            latestProducts.isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(20),
                                    child:
                                        Text("No products"),
                                  )
                                : Column(
                                    children:
                                        latestProducts
                                            .map((p) =>
                                                productCard(
                                                    p))
                                            .toList(),
                                  ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
    );
  }
}