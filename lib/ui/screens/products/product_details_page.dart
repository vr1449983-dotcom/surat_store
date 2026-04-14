import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/ui/screens/checkout/buy_now_checkout_page.dart';

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
      backgroundColor: const Color(0xFFF6F7FB),

      body: Column(
        children: [

          /// ===========================
          /// 🔥 HERO IMAGE + APPBAR
          /// ===========================
          Stack(
            children: [
              Hero(
                tag: "product_${product.pId}",
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  child: product.imagePath.isNotEmpty
                      ? Image.file(
                    File(product.imagePath),
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image, size: 80),
                ),
              ),

              /// 🔙 BACK BUTTON
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// ===========================
          /// 📄 DETAILS CARD
          /// ===========================
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🏷 NAME + PRICE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "₹${product.price}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// 📦 STOCK CHIP
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: product.stockQty > 0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
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

                    const SizedBox(height: 22),

                    /// 📝 DESCRIPTION TITLE
                    Text(
                      "Description",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 📝 DESCRIPTION BOX
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FD),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        product.description.isNotEmpty
                            ? product.description
                            : "No description available",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),

          /// ===========================
          /// 🔥 MODERN BOTTOM ACTION BAR
          /// ===========================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [

                  /// 🛒 ADD TO CART
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: product.stockQty == 0
                          ? null
                          : () {
                        cartController.addToCart(product);

                        Get.snackbar(
                          "Added",
                          "Product added to cart",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(10),
                          borderRadius: 10,
                        );
                      },
                      label: const Text(
                        "Cart",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// ⚡ BUY NOW
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: product.stockQty == 0
                          ? null
                          : () {
                        final buyNow = Get.put(BuyNowController());
                        buyNow.setProduct(product);

                        Get.to(
                              () => const BuyNowCheckoutScreen(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 400),
                        );
                      },
                      label: const Text(
                        "Buy Now",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}