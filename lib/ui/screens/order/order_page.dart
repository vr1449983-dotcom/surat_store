import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../controllers/order_controller.dart';
import '../../widgets/order_card.dart';
import 'order_details_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());

    controller.startListeningOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.orders.isEmpty) {
          return const Center(child: Text("No Orders Found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];

            return OrderCard(
              order: order,
              onTap: () {
                Get.to(() => OrderDetailsScreen(
                  orderId: order.oId, // ✅ FIXED
                ));
              },
            );
          },
        );
      }),
    );
  }
}