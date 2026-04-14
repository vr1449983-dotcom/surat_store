import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/db/db_helper.dart';
import '../../../core/services/sync_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: Obx(() {
        if (cart.cartItems.isEmpty) {
          return _emptyState();
        }

        return Column(
          children: [

            /// ===========================
            /// 🛍 CART LIST
            /// ===========================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      children: [

                        /// 🖼 IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: product.imagePath.isNotEmpty &&
                              File(product.imagePath).existsSync()
                              ? Image.file(
                            File(product.imagePath),
                            height: 75,
                            width: 75,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            "https://via.placeholder.com/100",
                            height: 75,
                            width: 75,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// 📦 DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "₹${product.price}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
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

                        /// 🔢 QTY CONTROL
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed:
                                isMin ? null : () => cart.decrease(product),
                                icon: const Icon(Icons.remove, size: 18),
                              ),
                              Text(
                                qty.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed:
                                isMax ? null : () => cart.increase(product),
                                icon: const Icon(Icons.add, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// ===========================
            /// 💰 TOTAL SECTION
            /// ===========================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  _row("Subtotal", cart.total),
                  _row("GST (5%)", cart.gst),

                  const Divider(height: 20),

                  _row("Total", cart.grandTotal, bold: true),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _placeOrder(cart);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Place Order",
                        style: TextStyle(
                          fontSize: 16,
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

  /// ===========================
  /// 🛒 EMPTY STATE
  /// ===========================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// ===========================
  /// 💰 ROW
  /// ===========================
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

  /// ===========================
  /// 🚀 PLACE ORDER (UNCHANGED LOGIC)
  /// ===========================
  Future<void> _placeOrder(CartController cart) async {
    final db = await DBHelper().db;
    final auth = AuthController.to;
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      for (var e in cart.cartItems.entries) {
        if (e.value > e.key.stockQty) {
          Get.back();
          Get.snackbar("Error", "${e.key.name} out of stock");
          return;
        }
      }

      await db.insert('orders', {
        'o_id': orderId,
        'total_amount': cart.grandTotal,
        'order_date': DateTime.now().toString(),
        'is_synced': 0,
      });

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
              'stock_qty': FieldValue.increment(-e.value),
            });
          }
        }

        await batch.commit();
      }

      await Get.find<ProductController>().loadProducts();
      SyncManager().scheduleSync();
      await cart.clearCart();

      Get.back();

      await Get.defaultDialog(
        title: "Success 🎉",
        middleText: "Order placed successfully",
        textConfirm: "OK",
        onConfirm: () {
          Get.back();
          Get.back();
        },
      );
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }
}