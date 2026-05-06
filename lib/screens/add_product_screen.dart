import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';


class AddProductScreen extends StatefulWidget {
  final int sellerId;
  final String token;

  const AddProductScreen({
    super.key,
    required this.sellerId,
    required this.token,
  });

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  File? imageFile;
  bool loading = false;

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // ================= ADD PRODUCT =================
 // ================= ADD PRODUCT =================
Future<void> addProduct() async {
  if (!_formKey.currentState!.validate()) return;

  if (imageFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Choose an image first"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => loading = true);

  try {
    final token = await StorageService.getToken();
    if (token == null) throw Exception("No token found");

    // 🔥 رفع الصورة للسيرفر (بدون Supabase)
    final imageUrl = await ApiService.uploadImage(imageFile!);

    if (imageUrl == null) {
      throw Exception("Image upload failed");
    }

    // 🔥 إرسال المنتج
    final success = await ApiService.addProduct(
      name: nameCtrl.text.trim(),
      price: double.parse(priceCtrl.text.trim()),
      token: token,
      imageUrl: imageUrl,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      throw Exception("Failed to add product");
    }

  } catch (e) {
    
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
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Add Product"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: Stack(
        children: [

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // ================= IMAGE =================
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        image: imageFile != null
                            ? DecorationImage(
                                image: FileImage(imageFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageFile == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo,
                                      size: 50, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text("Tap to choose image")
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= NAME =================
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Product Name",
                      prefixIcon: Icon(Icons.shopping_bag),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter product name" : null,
                  ),

                  const SizedBox(height: 15),

                  // ================= PRICE =================
                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Price (DA)",
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Enter price" : null,
                  ),

                  const SizedBox(height: 25),

                  // ================= BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "PUBLISH PRODUCT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

          // ================= LOADING =================
          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}