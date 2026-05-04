import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String token;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.token,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController priceController;

  File? newImageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.product['name']);
    priceController = TextEditingController(
        text: widget.product['price'].toString());
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        newImageFile = File(picked.path);
      });
    }
  }

  Future<void> updateProduct() async {
    if (isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    final price =
        double.tryParse(priceController.text.trim());

    if (price == null) {
      _showMsg("Invalid price ❌", false);
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl;

      // ✅ إذا اختار صورة جديدة
      if (newImageFile != null) {
        imageUrl =
            await ApiService.uploadImage(newImageFile!);
      }

      await ApiService.updateProduct(
        widget.token,
        widget.product['id'],
        nameController.text.trim(),
        price.toString(),
        imageUrl, // ممكن null
      );

      setState(() => isLoading = false);

      _showMsg("Updated successfully ✅", true);

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isLoading = false);
      _showMsg("Error: $e", false);
    }
  }

  void _showMsg(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final oldImage = widget.product['image'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product ✏️"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // ================= IMAGE =================
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(15),
                            child: newImageFile != null
                                ? Image.file(
                                    newImageFile!,
                                    fit: BoxFit.cover,
                                  )
                                : (oldImage != null &&
                                        oldImage
                                            .toString()
                                            .isNotEmpty)
                                    ? Image.network(
                                        oldImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __,
                                                ___) =>
                                            const Icon(
                                                Icons
                                                    .image_not_supported),
                                      )
                                    : const Icon(Icons.image,
                                        size: 50),
                          ),
                        ),
                      ),

                      // زر تغيير الصورة
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white),
                            onPressed: pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= NAME =================
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Product Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  // ================= PRICE =================
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Price (DA)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 25),

                  // ================= BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "UPDATE PRODUCT",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= LOADING =================
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                    color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}