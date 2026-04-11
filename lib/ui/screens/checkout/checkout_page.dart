import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/buy_now_controller.dart';

class BuyNowCheckoutScreen extends StatelessWidget {
  const BuyNowCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buyNow = Get.find<BuyNowController>();
    final auth = AuthController.to;
    final firestore = FirebaseFirestore.instance;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Buy Now")),

      body: Obx(() {
        final product = buyNow.product.value;

        if (product == null) {
          return const Center(child: Text("No product"));
        }

        return Column(
          children: [

            // 🛍 PRODUCT
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [

                  const Icon(Icons.shopping_bag, size: 50),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: theme.textTheme.titleMedium),
                        Text("₹${product.price}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔢 QUANTITY SELECTOR
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  IconButton(
                    onPressed: buyNow.decreaseQty,
                    icon: const Icon(Icons.remove),
                  ),

                  Text("${buyNow.quantity.value}",
                      style: const TextStyle(fontSize: 18)),

                  IconButton(
                    onPressed: buyNow.increaseQty,
                    icon: const Icon(Icons.add),
                  ),
                ],
              );
            }),

            const Spacer(),

            // 💰 BILL
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                ),
                child: Column(
                  children: [
              
                    _row("Subtotal", buyNow.total),
                    _row("GST", buyNow.gst),
              
                    const Divider(),
              
                    _row("Total", buyNow.grandTotal, bold: true),
              
                    const SizedBox(height: 10),
              
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _placeOrder(
                            buyNow,
                            auth,
                            firestore,
                          );
                        },
                        child: const Text("Place Order"),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _row(String title, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // 🔥 ORDER + STOCK DEDUCTION
  Future<void> _placeOrder(
      BuyNowController buyNow,
      AuthController auth,
      FirebaseFirestore firestore,
      ) async {
    final product = buyNow.product.value!;
    final qty = buyNow.quantity.value;

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final orderRef = firestore
        .collection('users')
        .doc(auth.currentShopId)
        .collection('orders')
        .doc(orderId);

    final batch = firestore.batch();

    batch.set(orderRef, {
      'o_id': orderId,
      'total_amount': buyNow.grandTotal,
      'order_date': DateTime.now().toString(),
    });

    batch.set(orderRef.collection('items').doc(), {
      'product_name': product.name,
      'qty': qty,
      'price': product.price,
    });

    // 🔥 STOCK UPDATE
    final productRef = firestore
        .collection('users')
        .doc(auth.currentShopId)
        .collection('products')
        .doc(product.pId.toString());

    batch.update(productRef, {
      'stock_qty': FieldValue.increment(-qty),
    });

    await batch.commit();

    Get.snackbar("Success 🎉", "Order placed");

    Get.back();
  }
}