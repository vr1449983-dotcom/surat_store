import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/buy_now_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/db/db_helper.dart';
import '../../../core/services/sync_manager.dart';

class BuyNowCheckoutScreen extends StatelessWidget {
  const BuyNowCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buyNow = Get.find<BuyNowController>();
    final auth = AuthController.to;
    final theme = Theme.of(context);

    /// 🔥 Prevent multiple clicks
    final isPlacingOrder = false.obs;

    return Scaffold(
      appBar: AppBar(title: const Text("Buy Now")),

      body: Obx(() {
        final product = buyNow.product.value;

        if (product == null) {
          return const Center(child: Text("No product"));
        }

        return Column(
          children: [

            /// 🛍 PRODUCT CARD
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
                        Text(product.name),
                        Text("₹${product.price}"),
                        Text("Stock: ${product.stockQty}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 🔢 QUANTITY
            SafeArea(
              child: Obx(() => Row(
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
              )),
            ),

            const Spacer(),

            /// 💰 BILL
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    _row("Subtotal", buyNow.total),
                    _row("GST", buyNow.gst),

                    const Divider(),

                    _row("Total", buyNow.grandTotal, bold: true),

                    const SizedBox(height: 10),

                    /// 🔥 PLACE ORDER BUTTON
                    Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isPlacingOrder.value
                            ? null
                            : () async {
                          isPlacingOrder.value = true;

                          await _placeOrder(
                            buyNow,
                            auth,
                          );

                          isPlacingOrder.value = false;
                        },
                        child: isPlacingOrder.value
                            ? const CircularProgressIndicator()
                            : const Text("Place Order"),
                      ),
                    ))
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

  // ===========================
  // 🚀 FINAL ORDER FLOW
  // ===========================
  Future<void> _placeOrder(
      BuyNowController buyNow,
      AuthController auth,
      ) async {

    final product = buyNow.product.value!;
    final qty = buyNow.quantity.value;

    /// ❌ STOCK CHECK
    if (qty > product.stockQty) {
      Get.snackbar("Error", "Not enough stock");
      return;
    }

    final db = await DBHelper().db;
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    try {

      // =========================
      // ✅ 1. SAVE ORDER LOCAL
      // =========================
      await db.insert('orders', {
        'o_id': orderId,
        'total_amount': buyNow.grandTotal,
        'order_date': DateTime.now().toString(),
        'is_synced': 0,
      });

      await db.insert('order_items', {
        'order_id': orderId,
        'product_id': product.pId,
        'qty_sold': qty,
        'price_at_sale': product.price,
      });

      // =========================
      // ✅ 2. UPDATE LOCAL STOCK
      // =========================
      await db.update(
        'products',
        {
          'stock_qty': product.stockQty - qty,
          'is_synced': 0,
        },
        where: 'p_id = ?',
        whereArgs: [product.pId],
      );

      // =========================
      // ✅ 3. FIRESTORE (OPTIONAL)
      // =========================
      if (product.docId != null && auth.currentShopId != null) {

        final firestore = FirebaseFirestore.instance;

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

        final productRef = firestore
            .collection('users')
            .doc(auth.currentShopId)
            .collection('products')
            .doc(product.docId);

        batch.update(productRef, {
          'stock_qty': FieldValue.increment(-qty),
        });

        await batch.commit();
      }

      // =========================
      // 🔄 REFRESH UI
      // =========================
      Get.find<ProductController>().loadProducts();

      // =========================
      // 🔄 AUTO SYNC TRIGGER
      // =========================
      SyncManager().scheduleSync();

      Get.snackbar("Success 🎉", "Order placed");
      Get.back();

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}