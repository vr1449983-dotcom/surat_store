import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../data/models/product_model.dart';
import '../products/add_product_page.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),

      body: Obx(() {

        /// 🔄 LOADING STATE (IMPORTANT)
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// 📊 STATS
            Card(
              child: ListTile(
                title: const Text("Total Products"),
                trailing: Text(
                  controller.products.length.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ➕ ADD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Get.to(() => const AddProductScreen()),
                icon: const Icon(Icons.add),
                label: const Text("Add Product"),
              ),
            ),

            const SizedBox(height: 20),

            /// 📦 EMPTY STATE
            if (controller.products.isEmpty)
              const Center(child: Text("No Products Found")),

            /// 📦 PRODUCT LIST
            ...controller.products.map(
                  (p) => _item(p),
            ),
          ],
        );
      }),
    );
  }

  Widget _item(ProductModel p) {
    return Card(
      child: ListTile(
        leading: p.imagePath.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(p.imagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        )
            : const Icon(Icons.image),

        title: Text(p.name),

        subtitle: Text(
          "₹${p.price} | Stock: ${p.stockQty}",
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// ✏️ EDIT
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Get.to(() => AddProductScreen(product: p));
              },
            ),

            /// ❌ DELETE
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Get.defaultDialog(
                  title: "Delete",
                  middleText: "Are you sure?",
                  textConfirm: "Yes",
                  textCancel: "No",
                  onConfirm: () {
                    Get.back();
                    controller.deleteProduct(p.pId!);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}