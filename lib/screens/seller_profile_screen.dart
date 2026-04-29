import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SellerProfileScreen extends StatefulWidget {
  final int sellerId;

  const SellerProfileScreen({super.key, required this.sellerId});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  Map<String, dynamic>? seller;
  List products = [];

  bool loading = true;

  final String baseUrl = "https://my-server-0xa0.onrender.com";

  @override
  void initState() {
    super.initState();
    loadSeller();
  }

  // ================= LOAD SELLER =================
  Future<void> loadSeller() async {
    try {
      final data = await ApiService.getSeller(widget.sellerId);

      setState(() {
        seller = data['seller'];
        products = data['products'];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= PRODUCT CARD =================
  Widget buildProduct(p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: p['image'] != null
            ? Image.network(
                "$baseUrl/uploads/${p['image']}",
                width: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image),

        title: Text(p['name'] ?? ""),

        subtitle: Text(
          "${p['price']} DA",
          style: const TextStyle(color: Colors.green),
        ),

        onTap: () {
          Navigator.pushNamed(
            context,
            '/product-details',
            arguments: p,
          );
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(seller?['name'] ?? "Seller"),
        backgroundColor: Colors.deepPurple,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : Column(
              children: [

                const SizedBox(height: 20),

                // ================= IMAGE =================
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage: seller?['image'] != null
                      ? NetworkImage(
                          "$baseUrl/uploads/${seller!['image']}",
                        )
                      : null,
                  child: seller?['image'] == null
                      ? const Icon(Icons.store,
                          size: 40, color: Colors.white)
                      : null,
                ),

                const SizedBox(height: 10),

                // ================= NAME =================
                Text(
                  seller?['name'] ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // ================= EMAIL =================
                Text(
                  seller?['email'] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 10),

                // ================= RATING (مؤقت) =================
                const Text("⭐ 4.5 Rating"),

                const SizedBox(height: 15),

                // ================= PRODUCTS COUNT =================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Products"),
                      Text(
                        "${products.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ================= CHAT BUTTON =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: widget.sellerId,
                        );
                      },
                      child: const Text("Chat with Seller 💬"),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Divider(),

                // ================= PRODUCTS TITLE =================
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Products",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ================= PRODUCTS LIST =================
                Expanded(
                  child: products.isEmpty
                      ? const Center(
                          child: Text("No products yet"),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return buildProduct(products[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}