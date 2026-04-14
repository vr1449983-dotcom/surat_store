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

  bool isLoading = false;
  bool isImageRemoved = false;

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descController.dispose();
    super.dispose();
  }

  // ================= IMAGE PICK =================
  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        isImageRemoved = false;
      });
    }
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _imageOption(Icons.camera_alt, "Camera",
                      () => pickImage(ImageSource.camera)),
              _imageOption(Icons.photo, "Gallery",
                      () => pickImage(ImageSource.gallery)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Get.back();
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF6C5CE7).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF6C5CE7)),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final price = double.tryParse(priceController.text);
    final stock = int.tryParse(stockController.text);

    if (name.isEmpty || desc.isEmpty) {
      Get.snackbar("Error", "Name & description required");
      return;
    }

    if (price == null || price <= 0) {
      Get.snackbar("Error", "Enter valid price");
      return;
    }

    if (stock == null || stock < 0) {
      Get.snackbar("Error", "Enter valid stock");
      return;
    }

    if (widget.product == null && selectedImage == null) {
      Get.snackbar("Error", "Product image required");
      return;
    }

    setState(() => isLoading = true);

    try {
      String imagePath = "";

      if (selectedImage != null) {
        imagePath = selectedImage!.path;
      } else if (isImageRemoved) {
        imagePath = "";
      } else {
        imagePath = widget.product?.imagePath ?? "";
      }

      final product = ProductModel(
        pId: widget.product?.pId,
        docId: widget.product?.docId,
        shopId: widget.product?.shopId,
        name: name,
        price: price,
        stockQty: stock,
        description: desc,
        imagePath: imagePath,
        isSynced: 0,
      );

      if (widget.product == null) {
        await controller.addProduct(product);
      } else {
        await controller.updateProduct(product);
      }

      Get.back();
      Get.snackbar("Success", "Product saved");

    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ================= IMAGE CARD =================
            Stack(
              children: [
                GestureDetector(
                  onTap: showImagePickerOptions,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C5CE7).withOpacity(0.2),
                          const Color(0xFF8E7CFF).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 40),
                        SizedBox(height: 8),
                        Text("Tap to add image"),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),

                /// REMOVE BUTTON
                if (selectedImage != null)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = null;
                          isImageRemoved = true;
                        });
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            /// ================= FORM =================
            _input(nameController, "Product Name", Icons.inventory),
            _input(priceController, "Price", Icons.currency_rupee, isNumber: true),
            _input(stockController, "Stock", Icons.layers, isNumber: true),
            _input(descController, "Description", Icons.description, maxLines: 3),

            const SizedBox(height: 25),

            /// ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  widget.product == null ? "ADD PRODUCT" : "UPDATE PRODUCT",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= INPUT =================
  Widget _input(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isNumber = false,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}