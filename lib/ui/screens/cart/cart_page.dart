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
  static const Color primary = Colors.deepPurple;

  final TextEditingController nameController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FF),
      appBar: AppBar(
        backgroundColor: primary,
        centerTitle: true,
        title: const Text("My Cart", style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (cart.cartItems.isEmpty) {
          return Center(child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// ICON
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              const Text(
                "Your Cart is Empty",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              /// SUBTITLE
              const Text(
                "Looks like you haven’t added anything yet",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              /// OPTIONAL BUTTON (GO SHOP)
              ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // or navigate to products screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.store, color: Colors.white),
                label: const Text(
                  "Start Shopping",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),);
        }

        final items = cart.cartItems.entries.toList();

        return Column(
          children: [

            /// CART LIST
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index].key;
                  final qty = items[index].value;

                  return ListTile(
                    leading: (product.imagePath.isNotEmpty &&
                        File(product.imagePath).existsSync())
                        ? Image.file(File(product.imagePath), width: 60)
                        : Image.network("https://via.placeholder.com/100"),
                    title: Text(product.name),
                    subtitle: Text("₹${product.price}"),
                    trailing: Text("x$qty"),
                  );
                },
              ),
            ),

            /// BOTTOM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Customer Name *",
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _row("Total", cart.grandTotal, bold: true),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isPlacingOrder
                          ? null
                          : () async {
                        final name = nameController.text.trim();

                        if (name.isEmpty) {
                          Get.snackbar(
                              "Required", "Enter customer name");
                          return;
                        }

                        await _placeOrder(cart, name);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                      ),
                      child: const Text("Place Order",
                          style: TextStyle(color: Colors.white)),
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

  Widget _row(String title, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
              fontWeight:
              bold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  /// 🚀 FAST ORDER (DIALOG FIRST)
  Future<void> _placeOrder(
      CartController cart, String customerName) async {

    if (_isPlacingOrder) return;
    _isPlacingOrder = true;

    final orderId =
    DateTime.now().millisecondsSinceEpoch.toString();

    /// ✅ SHOW DIALOG IMMEDIATELY
    Get.dialog(
      Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ICON
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 28),
              ),

              const SizedBox(height: 12),

              /// TITLE
              const Text(
                "Order Placed",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              /// MESSAGE
              const Text(
                "Your order has been placed successfully",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              /// BUTTON
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                ),
                child: const Text("OK",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    /// ⚡ BACKGROUND PROCESS
    _processOrder(cart, customerName, orderId);
  }

  /// 🔥 BACKGROUND LOGIC
  Future<void> _processOrder(
      CartController cart,
      String customerName,
      String orderId) async {

    final db = await DBHelper().db;
    final auth = AuthController.to;

    try {
      await db.insert('orders', {
        'o_id': orderId,
        'shop_id': auth.currentShopId,
        'customer_name': customerName,
        'total_amount': cart.grandTotal,
        'order_date': DateTime.now().toString(),
        'is_synced': 0,
      });

      for (var entry in cart.cartItems.entries) {
        final product = entry.key;
        final qty = entry.value;

        await db.insert('order_items', {
          'shop_id': auth.currentShopId,
          'order_id': orderId,
          'product_id': product.pId,
          'qty_sold': qty,
          'price_at_sale': product.price,
        });

        final newStock = product.stockQty - qty;

        await db.update(
          'products',
          {'stock_qty': newStock, 'is_synced': 0},
          where: 'p_id = ?',
          whereArgs: [product.pId],
        );
      }

      await Get.find<ProductController>().loadProducts();

      _syncToCloud(orderId, cart, auth, customerName);

      SyncManager().scheduleSync();

      await cart.clearCart();

    } catch (_) {}

    _isPlacingOrder = false;
  }

  /// ☁️ FIRESTORE
  Future<void> _syncToCloud(
      String orderId,
      CartController cart,
      AuthController auth,
      String customerName) async {

    try {
      final firestore = FirebaseFirestore.instance;

      final orderRef = firestore
          .collection('users')
          .doc(auth.currentShopId)
          .collection('orders')
          .doc(orderId);

      final batch = firestore.batch();

      batch.set(orderRef, {
        'customer_name': customerName,
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

          final newStock = e.key.stockQty - e.value;

          batch.update(productRef, {
            'stock_qty': newStock,
          });
        }
      }

      await batch.commit();
    } catch (_) {}
  }
}