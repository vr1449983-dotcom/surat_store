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
        /// 🔄 LOADING
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadProducts();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// 📊 STATS
              Card(
                child: ListTile(
                  title: const Text("Total Products"),
                  trailing: Text(
                    controller.products.length.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ➕ ADD BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Get.to(() => const AddProductScreen());

                    /// ❌ REMOVE THIS (not needed)
                    // controller.loadProducts();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Product"),
                ),
              ),

              const SizedBox(height: 20),

              /// 📦 EMPTY STATE
              if (controller.filteredProducts.isEmpty)
                const Center(child: Text("No Products Found")),

              /// 📦 LIST (🔥 FIXED)
              ...controller.filteredProducts.map((p) => _item(p)),
            ],
          ),
        );
      }),
    );
  }

  Widget _item(ProductModel p) {
    return Card(
      child: ListTile(
        leading: p.imagePath.isNotEmpty &&
            File(p.imagePath).existsSync()
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
              onPressed: () async {
                await Get.to(() => AddProductScreen(product: p));

                /// ❌ REMOVE THIS (not needed)
                // controller.loadProducts();
              },
            ),

            /// ❌ DELETE
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Get.defaultDialog(
                  title: "Delete",
                  middleText: "Are you sure you want to delete this product?",
                  textConfirm: "Yes",
                  textCancel: "No",
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    Get.back();

                    /// 🔥 FINAL DELETE CALL
                    controller.deleteProduct(p);
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