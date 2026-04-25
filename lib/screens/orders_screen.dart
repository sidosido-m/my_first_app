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

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    token = await StorageService.getToken();

    final res = await ApiService.getOrders(token!);

    setState(() {
      orders = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders 📦"),
        backgroundColor: Colors.deepPurple,
      ),

      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final o = orders[index];

          return Card(
            child: ListTile(
              title: Text("Order #${o['id']}"),
              subtitle: Text("Total: ${o['total_price']} DA"),
            ),
          );
        },
      ),
    );
  }
}