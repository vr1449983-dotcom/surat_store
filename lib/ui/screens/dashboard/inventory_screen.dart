import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../data/models/product_model.dart';
import '../products/add_product_page.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({super.key});

  final controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Inventory"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Obx(() {
        if (controller.filteredProducts.isEmpty) {
          return const Center(child: Text("No Products"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: controller.filteredProducts.length,
          itemBuilder: (context, index) {
            final p = controller.filteredProducts[index];
            return _item(p);
          },
        );
      }),
    );
  }

  Widget _item(ProductModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: p.imagePath.isNotEmpty && File(p.imagePath).existsSync()
                ? Image.file(File(p.imagePath), height: 60, width: 60, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 50),
          ),

          const SizedBox(width: 10),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text("₹${p.price}"),
                Text("Stock: ${p.stockQty}",
                    style: TextStyle(
                      color: p.stockQty > 0 ? Colors.green : Colors.red,
                    )),
              ],
            ),
          ),

          /// ACTIONS
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  await Get.to(() => AddProductScreen(product: p));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Delete",
                    middleText: "Delete this product?",
                    onConfirm: () {
                      Get.back();
                      controller.deleteProduct(p);
                    },
                    textConfirm: "Yes",
                    textCancel: "No",
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}