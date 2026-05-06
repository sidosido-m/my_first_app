import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';


class EditProductScreen extends StatefulWidget {
  final Map product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  File? newImage;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    nameCtrl.text = widget.product['name'] ?? "";
    priceCtrl.text =
        widget.product['price'].toString();
  }

  // ================= PICK IMAGE =================
Future<void> pickImage() async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (picked != null) {
    setState(() {
      newImage = File(picked.path);
    });
  }
}
// ================= PRODUCT =================
  Future<void> save() async {
  if (loading) return;

  setState(() => loading = true);

  try {
    final token = await StorageService.getToken();
    if (token == null) throw Exception("Not logged in");

    // ================= IMAGE =================
    String? imageUrl = widget.product['image']?.toString();

    if (newImage != null) {
      imageUrl = await ApiService.uploadImage(newImage!);
    }

    // ================= UPDATE PRODUCT =================
    final success = await ApiService.updateProduct(
      id: widget.product['id'],
      name: nameCtrl.text.trim(),
      price: double.tryParse(priceCtrl.text.trim()) ?? 0,
      image: imageUrl,
      token: token,
    );

    if (!success) throw Exception("Update failed");

    if (mounted) {
      Navigator.pop(context, true);
    }

  } catch (e) {
    print("SAVE ERROR ❌ $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }

  setState(() => loading = false);
}
  @override
  Widget build(BuildContext context) {
    final image = newImage != null
        ? FileImage(newImage!)
        : (widget.product['image'] != null
            ? NetworkImage(widget.product['image'])
            : const AssetImage("assets/user.png"))
            as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Edit Product"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // ================= IMAGE =================
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(20),
                      image: DecorationImage(
                        image: image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= FORM =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [

                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Product Name",
                          prefixIcon:
                              Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: priceCtrl,
                        keyboardType:
                            TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price (DA)",
                          prefixIcon:
                              Icon(Icons.monetization_on),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ================= BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "SAVE CHANGES",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= LOADING =================
          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}