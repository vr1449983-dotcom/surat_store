import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final auth = AuthController.to;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          Text("Total: ₹${cart.total}"),
          Text("GST: ₹${cart.gst}"),

          ElevatedButton(
            onPressed: () async {
              final orderId = DateTime.now().millisecondsSinceEpoch.toString();

              final orderData = {
                'o_id': orderId,
                'total_amount': cart.total + cart.gst,
                'order_date': DateTime.now().toString(),
              };

              await firestore
                  .collection('users')
                  .doc(auth.currentShopId)
                  .collection('orders')
                  .doc(orderId)
                  .set(orderData);

              // ORDER ITEMS
              for (var item in cart.cartItems.entries) {
                await firestore
                    .collection('users')
                    .doc(auth.currentShopId)
                    .collection('orders')
                    .doc(orderId)
                    .collection('items')
                    .add({
                  'product_name': item.key.name,
                  'qty': item.value,
                  'price': item.key.price,
                });
              }

              Get.snackbar("Success", "Order placed successfully");

              cart.cartItems.clear();
              Get.back();
            },
            child: const Text("Place Order"),
          )
        ],
      ),
    );
  }
}