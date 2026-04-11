import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final cartController = Get.find<CartController>();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 10),

            // 🔍 SEARCH + FILTER BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [

                  // 🔍 SEARCH BAR
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          productController.updateSearch(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Search products...",
                          prefixIcon: Icon(Icons.search, color: primary),
                          suffixIcon: Obx(() {
                            if (productController.searchQuery.value.isEmpty) {
                              return const SizedBox();
                            }
                            return IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                productController.updateSearch('');
                              },
                            );
                          }),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🎛 FILTER BUTTON
                  GestureDetector(
                    onTap: () {
                      _openFilterSheet(context, productController);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🛍 PRODUCT GRID
            Expanded(
              child: Obx(() {
                final products = productController.filteredProducts;

                if (products.isEmpty) {
                  return const Center(
                    child: Text("No Products Found 😕"),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: products.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ProductCard(
                      product: product,
                      cartController: cartController,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 🎛 FILTER SHEET WITH RESET
  void _openFilterSheet(
      BuildContext context, ProductController controller) {
    final theme = Theme.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // HANDLE
            Container(
              height: 5,
              width: 40,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // 💰 PRICE
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Max Price",
                  style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 10),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter max price",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                controller.updatePrice(
                    double.tryParse(value) ?? 0);
              },
            ),

            const SizedBox(height: 20),

            // 🔃 SORT
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Sort By",
                  style: theme.textTheme.titleMedium),
            ),

            Obx(() {
              return Column(
                children: [
                  RadioListTile(
                    value: 'low_high',
                    groupValue: controller.sortType.value,
                    title: const Text("Low → High"),
                    onChanged: (v) => controller.updateSort(v!),
                  ),
                  RadioListTile(
                    value: 'high_low',
                    groupValue: controller.sortType.value,
                    title: const Text("High → Low"),
                    onChanged: (v) => controller.updateSort(v!),
                  ),
                ],
              );
            }),

            // 📦 STOCK
            Obx(() {
              return SwitchListTile(
                value: controller.onlyInStock.value,
                title: const Text("In Stock Only"),
                onChanged: controller.toggleStock,
              );
            }),

            const SizedBox(height: 10),

            // 🔥 RESET + APPLY BUTTONS
            Row(
              children: [

                // RESET
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.resetFilters();
                    },
                    child: const Text("Reset"),
                  ),
                ),

                const SizedBox(width: 10),

                // APPLY
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}