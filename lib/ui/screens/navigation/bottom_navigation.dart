import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/bottom_navigation_controller.dart';
import '../../../controllers/cart_controller.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());
    final cartController = Get.put(CartController());

    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),

        body: IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),

        /// 🔥 CUSTOM MODERN NAVBAR
        bottomNavigationBar: SafeArea(
          top: false, // 👈 IMPORTANT (prevents extra top padding)
          child: Container(
            margin: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom > 0 ? 6 : 12,
              // 👆 dynamic bottom (perfect for all devices)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home, "Home", 0, controller),
                _navItem(Icons.inventory_2, "Stock", 1, controller),

                /// 🛒 CART WITH BADGE
                Obx(() {
                  final count = cartController.cartItems.values
                      .fold(0, (sum, qty) => sum + qty);

                  return _navItem(
                    Icons.shopping_cart,
                    "Cart",
                    2,
                    controller,
                    badgeCount: count,
                  );
                }),

                _navItem(Icons.receipt_long, "Orders", 3, controller),
                _navItem(Icons.person, "Profile", 4, controller),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// ===========================
  /// 🔥 NAV ITEM
  /// ===========================
  Widget _navItem(
      IconData icon,
      String label,
      int index,
      BottomNavController controller, {
        int badgeCount = 0,
      }) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            /// ICON + BADGE
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? Colors.white : Colors.grey,
                ),

                /// 🔴 SMALL PERFECT BADGE
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -5,
                    child: Container(
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeCount > 9 ? "9+" : "$badgeCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            /// LABEL (ONLY WHEN SELECTED 🔥)
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}