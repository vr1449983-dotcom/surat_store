import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/order_controller.dart';
import '../../widgets/order_card.dart';
import 'order_details_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());

    controller.startListeningOrders();

    const primary = Colors.deepPurple;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FF),

      /// 🎨 COLORED APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        centerTitle: true,
        title: const Text(
          "Orders",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.orders.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OrderCard(
                order: order,
                onTap: () {
                  Get.to(() => OrderDetailsScreen(
                    orderId: order.oId,
                  ));
                },
              ),
            );
          },
        );
      }),
    );
  }

  /// 📭 EMPTY STATE (MODERN)
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 70, color: Colors.deepPurple.shade100),
          const SizedBox(height: 12),
          Text(
            "No Orders Found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
