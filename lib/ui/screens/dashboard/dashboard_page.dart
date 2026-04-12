import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../data/models/product_model.dart';
import '../products/add_product_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// STATS
            Text("Total Products: ${controller.products.length}"),

            const SizedBox(height: 20),

            /// ADD BUTTON
            ElevatedButton(
              onPressed: () => Get.to(() => const AddProductScreen()),
              child: const Text("Add Product"),
            ),

            const SizedBox(height: 20),

            /// LIST
            ...controller.products.map((p) => _item(p, controller))
          ],
        );
      }),
    );
  }

  Widget _item(ProductModel p, ProductController controller) {
    return Card(
      child: ListTile(
        leading: p.imagePath.isNotEmpty
            ? Image.file(File(p.imagePath), width: 50)
            : const Icon(Icons.image),
        title: Text(p.name),
        subtitle: Text("₹${p.price} | Stock: ${p.stockQty}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Get.to(() => AddProductScreen(product: p));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                controller.deleteProduct(p.pId!);
              },
            ),
          ],
        ),
      ),
    );
  }
}