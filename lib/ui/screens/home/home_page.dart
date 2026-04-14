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

    /// 🎨 DEEP PURPLE THEME BASE
    const primary = Colors.deepPurple;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FF),

      /// 🎨 APPBAR (DEEP PURPLE)
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primary,
        title: const Text(
          "Surat Store",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 10),

            /// 🔍 SEARCH + FILTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [

                  /// SEARCH BAR
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          productController.updateSearch(value);
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Search products...",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.deepPurple, size: 20),
                          suffixIcon: Obx(() {
                            if (productController
                                .searchQuery.value.isEmpty) {
                              return const SizedBox();
                            }
                            return IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                productController.updateSearch('');
                              },
                            );
                          }),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// FILTER BUTTON
                  InkWell(
                    onTap: () {
                      _openFilterSheet(context, productController);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// 🛍 PRODUCT GRID
            Expanded(
              child: Obx(() {
                final products = productController.filteredProducts;

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No Products Found",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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

  /// 🎛 FILTER SHEET
  void _openFilterSheet(
      BuildContext context, ProductController controller) {

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HANDLE
            Center(
              child: Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text("Filters",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            /// PRICE
            const Text("Max Price"),
            const SizedBox(height: 8),

            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter max price",
                filled: true,
                fillColor: const Color(0xFFF4F2FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                controller.updatePrice(
                    double.tryParse(value) ?? 0);
              },
            ),

            const SizedBox(height: 20),

            /// SORT
            const Text("Sort By"),

            Obx(() {
              return Column(
                children: [
                  RadioListTile(
                    activeColor: Colors.deepPurple,
                    contentPadding: EdgeInsets.zero,
                    value: 'low_high',
                    groupValue: controller.sortType.value,
                    title: const Text("Low → High"),
                    onChanged: (v) => controller.updateSort(v!),
                  ),
                  RadioListTile(
                    activeColor: Colors.deepPurple,
                    contentPadding: EdgeInsets.zero,
                    value: 'high_low',
                    groupValue: controller.sortType.value,
                    title: const Text("High → Low"),
                    onChanged: (v) => controller.updateSort(v!),
                  ),
                ],
              );
            }),

            /// STOCK
            Obx(() {
              return SwitchListTile(
                activeColor: Colors.deepPurple,
                contentPadding: EdgeInsets.zero,
                value: controller.onlyInStock.value,
                title: const Text("In Stock Only"),
                onChanged: controller.toggleStock,
              );
            }),

            const SizedBox(height: 14),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.resetFilters,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
