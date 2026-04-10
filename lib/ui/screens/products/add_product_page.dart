import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../controllers/product_controller.dart';
import '../../../data/models/product_model.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  final controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stock"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0;
                final stock = int.tryParse(stockController.text) ?? 0;

                // ✅ VALIDATION (PDF requirement)
                if (name.isEmpty) {
                  Get.snackbar("Error", "Product name required");
                  return;
                }

                if (price < 0 || stock < 0) {
                  Get.snackbar("Error", "Invalid price or stock");
                  return;
                }

                controller.addProduct(
                  ProductModel(
                    name: name,
                    price: price,
                    stockQty: stock,
                    imagePath: '',
                  ),
                );

                Get.back();
              },
              child: const Text("Add Product"),
            )
          ],
        ),
      ),
    );
  }
}