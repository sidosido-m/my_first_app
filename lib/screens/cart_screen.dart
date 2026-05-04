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
  bool loading = true;
  double total = 0;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  // ================= LOAD CART =================
  Future<void> loadCart() async {
    setState(() => loading = true);

    final token = await StorageService.getToken();

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final data = await ApiService.getCart(token);

      double sum = 0;

      for (var item in data) {
        final price = double.tryParse(item['price'].toString()) ?? 0;
        final qty = int.tryParse(item['qty'].toString()) ?? 0;
        sum += price * qty;
      }

      setState(() {
        cart = data;
        total = sum;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= REMOVE =================
  Future<void> removeItem(int id) async {
    final token = await StorageService.getToken();
    if (token == null) return;

    await ApiService.removeFromCart(token, id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item removed 🗑️")),
    );

    loadCart();
  }

  // ================= UPDATE QTY =================
  Future<void> updateQty(int id, int qty) async {
    if (qty < 1) return;

    final token = await StorageService.getToken();
    if (token == null) return;

    await ApiService.updateCartQty(token, id, qty);

    loadCart();
  }

  // ================= CHECKOUT =================
  Future<void> checkout() async {
    final token = await StorageService.getToken();

    if (token == null) return;

    try {
      await ApiService.checkout(token);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order placed ✔️"),
          backgroundColor: Colors.green,
        ),
      );

      loadCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checkout error ❌")),
      );
    }
  }

  // ================= CART ITEM =================
  Widget cartItem(item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),

        // ✅ صورة من Supabase
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item['image'] != null &&
                  item['image'].toString().isNotEmpty
              ? Image.network(
                  item['image'], // ✅ رابط مباشر
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image),
                )
              : const Icon(Icons.image, size: 40),
        ),

        title: Text(item['name'] ?? ""),

        subtitle: Text(
          "${item['price']} DA",
          style: const TextStyle(color: Colors.green),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ➖
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (item['qty'] > 1) {
                  updateQty(item['id'], item['qty'] - 1);
                }
              },
            ),

            Text(
              "${item['qty']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            // ➕
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                updateQty(item['id'], item['qty'] + 1);
              },
            ),

            // ❌ DELETE
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => removeItem(item['id']),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart 🛒"),
        backgroundColor: Colors.deepPurple,
      ),

      body: RefreshIndicator(
        onRefresh: loadCart,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : cart.isEmpty
                ? const Center(child: Text("Cart is empty 😢"))
                : Column(
                    children: [

                      // ================= LIST =================
                      Expanded(
                        child: ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            return cartItem(cart[index]);
                          },
                        ),
                      ),

                      // ================= TOTAL =================
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "$total DA",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: checkout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Checkout 💳"),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
      ),
    );
  }
}