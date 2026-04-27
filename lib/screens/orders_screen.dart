import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List orders = [];
  String? token;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      token = await StorageService.getToken();

      if (token == null) {
        setState(() {
          loading = false;
          error = "Not logged in";
        });
        return;
      }

      final res = await ApiService.getOrders(token!);

      setState(() {
        orders = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Failed to load orders";
      });
    }
  }

  Future<void> refresh() async {
    await loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders 📦"),
        backgroundColor: Colors.deepPurple,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: loadOrders,
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                )

              : orders.isEmpty
                  ? const Center(
                      child: Text(
                        "No orders yet 🛒",
                        style: TextStyle(fontSize: 18),
                      ),
                    )

                  : RefreshIndicator(
                      onRefresh: refresh,
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final o = orders[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.shopping_bag,
                                color: Colors.deepPurple,
                              ),

                              title: Text(
                                "Order #${o['id']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                "Total: ${o['total_price']} DA",
                              ),

                              trailing: const Icon(Icons.arrow_forward_ios),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}