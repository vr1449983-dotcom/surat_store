import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../data/models/product_model.dart';
import '../screens/products/product_details_page.dart';


class ProductCard extends StatelessWidget {
  final ProductModel product;
  final CartController cartController;

  const ProductCard({
    super.key,
    required this.product,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Obx(() {
      final isInCart = cartController.cartItems.containsKey(product);

      return GestureDetector(
        onTap: () {
          Get.to(
                () => ProductDetailPage(product: product),
            transition: Transition.rightToLeft,
          );
        },

        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [

              // 🖼 IMAGE
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: product.imagePath.isNotEmpty &&
                    File(product.imagePath).existsSync()
                    ? Image.file(
                  File(product.imagePath),
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  "https://via.placeholder.com/150",
                  fit: BoxFit.cover,
                ),
              ),

              // 🌑 OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 💰 PRICE + STOCK
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${product.price}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product.stockQty > 0
                          ? "${product.stockQty} left"
                          : "Out of stock",
                      style: TextStyle(
                        color: product.stockQty > 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // 🛒 CART BUTTON
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    if (isInCart) {
                      cartController.decrease(product);
                    } else {
                      cartController.addToCart(product);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isInCart ? primary : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isInCart
                          ? Icons.check
                          : Icons.add_shopping_cart,
                      color: isInCart ? Colors.white : primary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}