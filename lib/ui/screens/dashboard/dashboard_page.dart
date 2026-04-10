import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../data/models/product_model.dart';
import '../cart/cart_page.dart';
import '../products/add_product_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());
    final cartController = Get.find<CartController>();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔥 HEADER
              Text(
                "Dashboard",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 💰 STATS CARDS
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: "Total Sales",
                      value: "₹${cartController.total.toStringAsFixed(0)}",
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: "Products",
                      value: "${productController.products.length}",
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📊 FAKE GRAPH (ANIMATED STYLE)
              Container(
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomPaint(
                  painter: _GraphPainter(primary),
                  child: Container(),
                ),
              ),

              const SizedBox(height: 20),

              // 📦 INVENTORY HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Inventory",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.to(() => const AddProductScreen());
                    },
                    icon: Icon(Icons.add, color: primary),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // 📦 PRODUCT LIST
              Obx(() {
                if (productController.products.isEmpty) {
                  return const Center(child: Text("No Products"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productController.products.length,
                  itemBuilder: (context, index) {
                    final product = productController.products[index];

                    return _inventoryCard(
                      context,
                      product,
                      productController,
                    );
                  },
                );
              }),

              const SizedBox(height: 20),

              // 🛒 CART BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const CartScreen());
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Go to Cart"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 💰 STAT CARD
  Widget _statCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 📦 INVENTORY CARD
  Widget _inventoryCard(
      BuildContext context,
      ProductModel product,
      ProductController controller,
      ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // 👉 EDIT (you can navigate to edit screen)
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [

            // 🖼 IMAGE
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image),
            ),

            const SizedBox(width: 10),

            // 📦 DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("₹${product.price}"),
                  Text("Stock: ${product.stockQty}"),
                ],
              ),
            ),

            // ❌ DELETE
            IconButton(
              onPressed: () {
                if (product.pId != null) {
                  controller.deleteProduct(product.pId!);
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}




class _GraphPainter extends CustomPainter {
final Color color;

_GraphPainter(this.color);

@override
void paint(Canvas canvas, Size size) {
final paint = Paint()
..color = color
..strokeWidth = 3
..style = PaintingStyle.stroke;

final path = Path();

final random = Random();
double prevY = size.height / 2;

path.moveTo(0, prevY);

for (int i = 1; i < 6; i++) {
double x = i * size.width / 5;
double y = random.nextDouble() * size.height;
path.lineTo(x, y);
}

canvas.drawPath(path, paint);
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}