import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/sync_service.dart';
import '../../widgets/common_card.dart';
import '../cart/cart_page.dart';
import '../order/order_page.dart';
import '../products/product_list_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _card(
            "Products",
            Icons.inventory,
            Colors.blue,
                () => Get.to(() => const ProductScreen()),
          ),

          _card(
            "Orders",
            Icons.shopping_cart,
            Colors.green,
                () => Get.to(() => const OrderScreen()),
          ),

          _card(
            "Cart",
            Icons.shopping_bag,
            Colors.orange,
                () => Get.to(() => const CartScreen()),
          ),

          _card(
            "Sync",
            Icons.sync,
            Colors.purple,
                () async {
              await SyncService().syncData();
              Get.snackbar("Success", "Data synced");
            },
          ),
        ],
      ),
    );
  }

  Widget _card(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap, // ✅ added action
      ) {
    return CommonCard(
      onTap: onTap, // ✅ makes it clickable
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}