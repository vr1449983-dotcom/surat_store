import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/ui/screens/checkout/checkout_page.dart';
import '../../../controllers/buy_now_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../data/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        title: Text(product.name),
      ),

      body: Column(
        children: [

          // 🖼 PRODUCT IMAGE (LOCAL FILE)
          Container(
            height: 260,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: product.imagePath.isNotEmpty
                ? Image.file(
              File(product.imagePath),
              fit: BoxFit.cover,
            )
                : const Icon(Icons.image, size: 80),
          ),

          // 📄 DETAILS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🏷 NAME
                  Text(
                    product.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 💰 PRICE
                  Text(
                    "₹${product.price}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📦 STOCK STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: product.stockQty > 0
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.stockQty > 0
                          ? "In Stock (${product.stockQty})"
                          : "Out of Stock",
                      style: TextStyle(
                        color: product.stockQty > 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📝 DESCRIPTION TITLE
                  Text(
                    "Description",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 📝 DESCRIPTION TEXT
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : "No description available",
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // 🔥 BOTTOM BAR (FLIPKART STYLE)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [

                // 🛒 ADD TO CART
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: product.stockQty == 0
                        ? null
                        : () {
                      cartController.addToCart(product);
                      Get.snackbar(
                        "Success",
                        "Added to cart",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: const Text("Add to Cart"),
                  ),
                ),

                const SizedBox(width: 10),

                // ⚡ BUY NOW
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: product.stockQty == 0
                        ? null
                        : () {
                      final buyNow = Get.put(BuyNowController());

                      buyNow.setProduct(product);

                      Get.to(
                            () => const BuyNowCheckoutScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                    child: const Text("Buy Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}