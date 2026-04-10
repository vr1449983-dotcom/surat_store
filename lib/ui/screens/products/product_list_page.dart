import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_page.dart';
import 'add_product_page.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          // 🛒 CART BUTTON
          IconButton(
            onPressed: () {
              Get.to(() => const CartScreen());
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),

          // ➕ ADD PRODUCT
          IconButton(
            onPressed: () {
              Get.to(() => const AddProductScreen());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      body: Obx(() {
        if (productController.products.isEmpty) {
          return const Center(child: Text("No Products Available"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: productController.products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final product = productController.products[index];

            return ProductCard(
              product: product,
              cartController: cartController,
            );
          },
        );
      }),
    );
  }
}