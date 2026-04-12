import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/db/db_helper.dart';
import '../../../core/services/sync_manager.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),

      body: Obx(() {
        if (cart.cartItems.isEmpty) {
          return const Center(child: Text("🛒 Your cart is empty"));
        }

        return Column(
          children: [
            // ===========================
            // 🛍 CART ITEMS
            // ===========================
            Expanded(
              child: ListView.builder(
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  final entry = cart.cartItems.entries.toList()[index];
                  final product = entry.key;
                  final qty = entry.value;

                  final isMin = qty <= 1;
                  final isMax = qty >= product.stockQty;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        /// 🖼 IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product.imagePath.isNotEmpty &&
                              File(product.imagePath).existsSync()
                              ? Image.file(
                            File(product.imagePath),
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            "https://via.placeholder.com/100",
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// 📦 DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("₹${product.price}"),

                              if (isMax)
                                const Text(
                                  "Max stock reached",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        /// 🔢 QTY CONTROLS
                        Row(
                          children: [
                            IconButton(
                              onPressed: isMin
                                  ? null
                                  : () => cart.decrease(product),
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color:
                                isMin ? Colors.grey : null,
                              ),
                            ),

                            Text(
                              qty.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),

                            IconButton(
                              onPressed: isMax
                                  ? null
                                  : () => cart.increase(product),
                              icon: Icon(
                                Icons.add_circle_outline,
                                color:
                                isMax ? Colors.grey : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ===========================
            // 💰 TOTAL + ORDER
            // ===========================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                children: [
                  _row("Subtotal", cart.total),
                  _row("GST (5%)", cart.gst),

                  const Divider(),

                  _row("Total", cart.grandTotal, bold: true),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _placeOrder(cart);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Place Order",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  // ===========================
  // 💰 ROW
  // ===========================
  Widget _row(String title, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight:
            bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ===========================
  // 🚀 DIRECT ORDER FUNCTION
  // ===========================
  Future<void> _placeOrder(CartController cart) async {
    final db = await DBHelper().db;
    final auth = AuthController.to;
    final orderId =
    DateTime.now().millisecondsSinceEpoch.toString();

    /// 🔄 LOADER
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      /// ❌ STOCK CHECK
      for (var e in cart.cartItems.entries) {
        if (e.value > e.key.stockQty) {
          Get.back();
          Get.snackbar("Error", "${e.key.name} out of stock");
          return;
        }
      }

      /// ✅ INSERT ORDER
      await db.insert('orders', {
        'o_id': orderId,
        'total_amount': cart.grandTotal,
        'order_date': DateTime.now().toString(),
        'is_synced': 0,
      });

      /// ✅ ITEMS + STOCK UPDATE
      for (var e in cart.cartItems.entries) {
        final product = e.key;
        final qty = e.value;

        await db.insert('order_items', {
          'order_id': orderId,
          'product_id': product.pId,
          'qty_sold': qty,
          'price_at_sale': product.price,
        });

        await db.update(
          'products',
          {
            'stock_qty': product.stockQty - qty,
            'is_synced': 0,
          },
          where: 'p_id = ?',
          whereArgs: [product.pId],
        );
      }

      /// ☁️ FIRESTORE
      if (auth.currentShopId != null) {
        final firestore = FirebaseFirestore.instance;

        final orderRef = firestore
            .collection('users')
            .doc(auth.currentShopId)
            .collection('orders')
            .doc(orderId);

        final batch = firestore.batch();

        batch.set(orderRef, {
          'o_id': orderId,
          'total_amount': cart.grandTotal,
          'order_date': DateTime.now().toString(),
        });

        for (var e in cart.cartItems.entries) {
          batch.set(orderRef.collection('items').doc(), {
            'product_name': e.key.name,
            'qty': e.value,
            'price': e.key.price,
          });

          if (e.key.docId != null) {
            final productRef = firestore
                .collection('users')
                .doc(auth.currentShopId)
                .collection('products')
                .doc(e.key.docId);

            batch.update(productRef, {
              'stock_qty':
              FieldValue.increment(-e.value),
            });
          }
        }

        await batch.commit();
      }

      /// 🔄 REFRESH + SYNC
      Get.find<ProductController>().loadProducts();
      SyncManager().scheduleSync();

      /// 🧹 CLEAR CART
      cart.cartItems.clear();

      Get.back();
      Get.snackbar("Success 🎉", "Order placed");

    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }
}