import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../controllers/product_controller.dart';
import 'add_product_page.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => AddProductScreen());
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),

      body: Obx(() {
        if (controller.products.isEmpty) {
          return const Center(child: Text("No Products"));
        }

        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];

            return ListTile(
              title: Text(product.name),
              subtitle: Text("₹${product.price} | Stock: ${product.stockQty}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  controller.deleteProduct(product.pId!);
                },
              ),
            );
          },
        );
      }),
    );
  }
}