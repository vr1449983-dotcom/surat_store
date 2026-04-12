import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/product_controller.dart';
import '../../../data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descController = TextEditingController();

  final controller = Get.find<ProductController>();

  File? selectedImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    /// 🔥 PREFILL (EDIT MODE)
    if (widget.product != null) {
      final p = widget.product!;
      nameController.text = p.name;
      priceController.text = p.price.toString();
      stockController.text = p.stockQty.toString();
      descController.text = p.description;

      if (p.imagePath.isNotEmpty) {
        selectedImage = File(p.imagePath);
      }
    }
  }

  // ===========================
  // 📸 PICK IMAGE
  // ===========================
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (picked != null) {
        setState(() {
          selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Image picking failed");
    }
  }

  // ===========================
  // 🔽 BOTTOM SHEET
  // ===========================
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Image",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _imageOption(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    onTap: () {
                      Get.back();
                      pickImage(ImageSource.camera);
                    },
                  ),
                  _imageOption(
                    icon: Icons.photo,
                    label: "Gallery",
                    onTap: () {
                      Get.back();
                      pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  // ===========================
  // 📦 SUBMIT
  // ===========================
  void submit() {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final price = double.tryParse(priceController.text);
    final stock = int.tryParse(stockController.text);

    if (name.isEmpty || desc.isEmpty || price == null || stock == null) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    final product = ProductModel(
      pId: widget.product?.pId,
      docId: widget.product?.docId,
      name: name,
      price: price,
      stockQty: stock,
      description: desc,
      imagePath: selectedImage?.path ?? "",
      isSynced: 0,
    );

    if (widget.product == null) {
      controller.addProduct(product);
    } else {
      controller.updateProduct(product);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🖼 IMAGE PICKER
            GestureDetector(
              onTap: showImagePickerOptions,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withOpacity(0.3)),
                ),
                child: selectedImage == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo,
                        size: 40, color: primary),
                    const SizedBox(height: 10),
                    Text("Add Product Image",
                        style: TextStyle(color: primary)),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            /// REMOVE IMAGE
            if (selectedImage != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedImage = null;
                  });
                },
                child: const Text("Remove Image"),
              ),

            const SizedBox(height: 20),

            /// NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),

            /// PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            /// STOCK
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stock"),
            ),

            /// DESCRIPTION
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 25),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submit,
                child: Text(
                  widget.product == null ? "ADD PRODUCT" : "UPDATE PRODUCT",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}